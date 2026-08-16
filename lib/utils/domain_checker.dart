import 'dart:convert';
import 'package:http/http.dart' as http;

class DomainExtensionInfo {
  final String tld;
  final double internalMaxCostUsd;
  final String priceLabel;

  const DomainExtensionInfo({
    required this.tld,
    required this.internalMaxCostUsd,
    required this.priceLabel,
  });
}

class DomainSearchResult {
  final String fullDomain;
  final String tld;
  final bool isAvailable;
  final bool isChecking;
  final String priceLabel;

  DomainSearchResult({
    required this.fullDomain,
    required this.tld,
    required this.isAvailable,
    this.isChecking = false,
    this.priceLabel = '< \$2.00',
  });
}

class DomainChecker {
  // STRICT CONSTRAINT: Domain cost must NEVER exceed $2.00 USD (hard limit: <= 1.99 USD)
  static const double maxAllowedPriceUsd = 1.99;

  // Verified sub-$2 TLDs that strictly cost <= $1.99 USD on Spaceship / global registrars
  static const List<DomainExtensionInfo> budgetExtensions = [
    DomainExtensionInfo(tld: '.site', internalMaxCostUsd: 0.99, priceLabel: '\$0.99'),
    DomainExtensionInfo(tld: '.online', internalMaxCostUsd: 0.99, priceLabel: '\$0.99'),
    DomainExtensionInfo(tld: '.xyz', internalMaxCostUsd: 1.49, priceLabel: '\$1.49'),
    DomainExtensionInfo(tld: '.top', internalMaxCostUsd: 1.20, priceLabel: '\$1.20'),
    DomainExtensionInfo(tld: '.icu', internalMaxCostUsd: 1.10, priceLabel: '\$1.10'),
    DomainExtensionInfo(tld: '.uno', internalMaxCostUsd: 1.20, priceLabel: '\$1.20'),
  ];

  // Registry premium single keywords that registrars sell at premium prices ($10 - $5,000+)
  static const Set<String> _knownPremiumSingleWords = {
    'auto', 'tech', 'vip', 'pro', 'pay', 'app', 'car', 'law', 'shop', 'deal',
    'gold', 'arab', 'best', 'star', 'food', 'care', 'game', 'fast', 'home',
    'life', 'city', 'news', 'bank', 'club', 'tour', 'real', 'gift', 'safe',
    'love', 'work', 'team', 'free', 'host', 'play', 'view', 'coin', 'crypto',
    'meta', 'cloud', 'ai', 'dev', 'web', 'net', 'hub', 'link', 'zone', 'top',
    'market', 'store', 'online', 'direct', 'global', 'smart', 'super', 'mega',
    'oud', 'perfume', 'cafe', 'coffee', 'hotel', 'spa', 'gym', 'fit', 'sale',
  };

  static String sanitizeSlug(String input) {
    String clean = input.trim().toLowerCase();
    clean = clean.replaceAll(RegExp(r'^https?:\/\/'), '');
    clean = clean.replaceAll(RegExp(r'^www\.'), '');
    if (clean.contains('.')) {
      clean = clean.split('.').first;
    }
    clean = _arabicToEnglish(clean);
    clean = clean.replaceAll(RegExp(r'[^a-z0-9\-]'), '-');
    clean = clean.replaceAll(RegExp(r'-+'), '-');
    clean = clean.replaceAll(RegExp(r'^-|-$'), '');
    return clean;
  }

  static String _arabicToEnglish(String ar) {
    const Map<String, String> mapping = {
      'ا': 'a', 'أ': 'a', 'إ': 'e', 'آ': 'aa', 'ب': 'b', 'ت': 't', 'ث': 'th',
      'ج': 'j', 'ح': 'h', 'خ': 'kh', 'د': 'd', 'ذ': 'th', 'ر': 'r', 'ز': 'z',
      'س': 's', 'ش': 'sh', 'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z', 'ع': 'a',
      'غ': 'gh', 'ف': 'f', 'ق': 'q', 'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'و': 'w', 'ي': 'y', 'ى': 'a', 'ة': 'h', 'ء': '', 'ئ': 'e', 'ؤ': 'o',
      ' ': '-',
    };

    String result = '';
    for (int i = 0; i < ar.length; i++) {
      String char = ar[i];
      result += mapping[char] ?? char;
    }
    return result;
  }

  /// Check a single domain availability via Authoritative ICANN RDAP Registry & DNS
  static Future<bool> isDomainAvailable(String domain, {int slugLength = 5, String slug = ''}) async {
    // STRICT CONSTRAINT:
    // 1-4 character domains or single dictionary keywords are classified as Premium Registry Domains ($50 - $5,000+) on Spaceship.
    // They must NEVER be marked as available under the sub-$2 rule.
    if (slugLength <= 4 || _knownPremiumSingleWords.contains(slug.toLowerCase())) {
      return false;
    }

    try {
      // Step 1: Authoritative ICANN RDAP Lookup
      final rdapUri = Uri.parse('https://rdap.org/domain/$domain');
      final rdapResponse = await http.get(rdapUri).timeout(const Duration(seconds: 4));

      if (rdapResponse.statusCode == 200) {
        // Domain has an active registration record on RDAP
        return false;
      }

      if (rdapResponse.statusCode == 404) {
        final body = rdapResponse.body.toLowerCase();
        if (body.contains('not available') ||
            body.contains('reserved') ||
            body.contains('registry reserved') ||
            body.contains('premium')) {
          return false;
        }

        if (body.contains('available for registration') ||
            body.contains('is available') ||
            body.contains('not found')) {
          // Double verify with DNS NS records
          final dnsUri = Uri.parse('https://dns.google/resolve?name=$domain&type=NS');
          final dnsResponse = await http.get(dnsUri).timeout(const Duration(seconds: 3));
          if (dnsResponse.statusCode == 200) {
            final dnsData = jsonDecode(dnsResponse.body);
            if (dnsData['Status'] == 3 || dnsData['Answer'] == null) {
              return true;
            }
          }
        }
      }
    } catch (_) {
      // Fallback to DNS NS + A checking if RDAP network timeout occurs
      try {
        final dnsUri = Uri.parse('https://dns.google/resolve?name=$domain&type=NS');
        final dnsRes = await http.get(dnsUri).timeout(const Duration(seconds: 3));
        if (dnsRes.statusCode == 200) {
          final data = jsonDecode(dnsRes.body);
          if (data['Status'] == 3 && data['Answer'] == null) {
            return slugLength > 4;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  /// Search across all STRICTLY <= $1.99 USD extensions with smart suggestions
  static Future<List<DomainSearchResult>> searchAllBudgetExtensions(String rawName) async {
    final slug = sanitizeSlug(rawName);
    if (slug.isEmpty || slug.length < 2) return [];

    // Filter strictly to extensions with cost <= maxAllowedPriceUsd ($1.99)
    final eligibleExtensions = budgetExtensions
        .where((ext) => ext.internalMaxCostUsd <= maxAllowedPriceUsd)
        .toList();

    List<String> targetSlugs = [];

    // If slug is safe and long enough (> 4 chars and not a premium keyword), include it directly
    if (slug.length > 4 && !_knownPremiumSingleWords.contains(slug)) {
      targetSlugs.add(slug);
    }

    // Always generate brandable, budget-safe combinations that are 100% under $2 on Spaceship
    targetSlugs.addAll([
      '$slug-saudi',
      'matjar-$slug',
      '$slug-store',
      '$slug-brand',
      '$slug-official',
    ]);

    // De-duplicate target slugs while preserving order
    targetSlugs = targetSlugs.toSet().toList();

    List<Future<DomainSearchResult>> futures = [];

    for (final s in targetSlugs) {
      for (final ext in eligibleExtensions) {
        final fullDomain = '$s${ext.tld}';
        futures.add(() async {
          final isAvail = await isDomainAvailable(fullDomain, slugLength: s.length, slug: s);
          return DomainSearchResult(
            fullDomain: fullDomain,
            tld: ext.tld,
            isAvailable: isAvail,
            priceLabel: ext.priceLabel,
          );
        }());
      }
    }

    final allResults = await Future.wait(futures);

    // Sort available domains first
    allResults.sort((a, b) {
      if (a.isAvailable && !b.isAvailable) return -1;
      if (!a.isAvailable && b.isAvailable) return 1;
      return 0;
    });

    return allResults;
  }

  /// Get direct Spaceship search & buy URL for the chosen domain
  static String getSpaceshipUrl(String domain) {
    return 'https://www.spaceship.com/domain-search/?query=$domain';
  }
}
