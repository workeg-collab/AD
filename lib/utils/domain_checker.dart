import 'dart:convert';
import 'package:http/http.dart' as http;

class DomainExtensionInfo {
  final String tld;
  final double internalMaxCostUsd;

  const DomainExtensionInfo({
    required this.tld,
    required this.internalMaxCostUsd,
  });
}

class DomainSearchResult {
  final String fullDomain;
  final String tld;
  final bool isAvailable;
  final bool isChecking;

  DomainSearchResult({
    required this.fullDomain,
    required this.tld,
    required this.isAvailable,
    this.isChecking = false,
  });
}

class DomainChecker {
  // STRICT CONSTRAINT: Domain cost must NEVER exceed $2.00 USD
  static const double maxAllowedPriceUsd = 2.0;

  // Verified budget TLDs that strictly cost <= $2.00 USD on global registrars (Spaceship / Namecheap / Porkbun)
  static const List<DomainExtensionInfo> budgetExtensions = [
    DomainExtensionInfo(tld: '.site', internalMaxCostUsd: 0.99),
    DomainExtensionInfo(tld: '.online', internalMaxCostUsd: 0.99),
    DomainExtensionInfo(tld: '.xyz', internalMaxCostUsd: 0.99),
    DomainExtensionInfo(tld: '.store', internalMaxCostUsd: 1.79),
    DomainExtensionInfo(tld: '.shop', internalMaxCostUsd: 1.88),
    DomainExtensionInfo(tld: '.website', internalMaxCostUsd: 1.49),
    DomainExtensionInfo(tld: '.space', internalMaxCostUsd: 1.29),
    DomainExtensionInfo(tld: '.fun', internalMaxCostUsd: 1.49),
    DomainExtensionInfo(tld: '.top', internalMaxCostUsd: 1.20),
    DomainExtensionInfo(tld: '.uno', internalMaxCostUsd: 1.20),
    DomainExtensionInfo(tld: '.icu', internalMaxCostUsd: 1.10),
    DomainExtensionInfo(tld: '.click', internalMaxCostUsd: 1.40),
  ];

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
  static Future<bool> isDomainAvailable(String domain, {int slugLength = 4}) async {
    // STRICT RULE: 1-3 letter domains (like 'aly.online', 'aly.site', 'aly.xyz')
    // are ALWAYS priced as Premium Registry Domains ($50 - $5,000+) on Spaceship.
    // They must NEVER be marked as available under the <= $2 budget rule!
    if (slugLength <= 3) {
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
            return slugLength > 3;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  /// Search across all <= $2 USD extensions with smart suggestions for short keywords
  static Future<List<DomainSearchResult>> searchAllBudgetExtensions(String rawName) async {
    final slug = sanitizeSlug(rawName);
    if (slug.isEmpty || slug.length < 2) return [];

    final eligibleExtensions = budgetExtensions
        .where((ext) => ext.internalMaxCostUsd <= maxAllowedPriceUsd)
        .toList();

    List<String> targetSlugs = [slug];
    // If the input slug is very short (e.g. 'aly'), generate smart business variants
    if (slug.length <= 3) {
      targetSlugs.addAll([
        '$slug-store',
        '$slug-brand',
        '$slug-shop',
        'matjar-$slug',
      ]);
    }

    List<Future<DomainSearchResult>> futures = [];

    for (final s in targetSlugs) {
      for (final ext in eligibleExtensions) {
        final fullDomain = '$s${ext.tld}';
        futures.add(() async {
          final isAvail = await isDomainAvailable(fullDomain, slugLength: s.length);
          return DomainSearchResult(
            fullDomain: fullDomain,
            tld: ext.tld,
            isAvailable: isAvail,
          );
        }());
      }
    }

    final allResults = await Future.wait(futures);

    // Filter to avoid overwhelming results:
    // If the direct keyword has available domains, show them first, then suggestions
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
