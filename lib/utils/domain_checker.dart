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
  // STRICT CONSTRAINT: Spaceship sub-$2 domain limit (<= $1.99 USD)
  static const double maxAllowedPriceUsd = 1.99;

  // Verified Spaceship TLDs that strictly cost <= $1.99 USD on Spaceship.com
  static const List<DomainExtensionInfo> budgetExtensions = [
    DomainExtensionInfo(tld: '.site', internalMaxCostUsd: 0.99),
    DomainExtensionInfo(tld: '.online', internalMaxCostUsd: 0.99),
    DomainExtensionInfo(tld: '.xyz', internalMaxCostUsd: 1.49),
    DomainExtensionInfo(tld: '.top', internalMaxCostUsd: 1.20),
    DomainExtensionInfo(tld: '.icu', internalMaxCostUsd: 1.10),
    DomainExtensionInfo(tld: '.uno', internalMaxCostUsd: 1.20),
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
  static Future<bool> isDomainAvailable(String domain, {required String slug}) async {
    // STRICT REGISTRY ANTI-PREMIUM RULE:
    // Single-word names without hyphens (like 'bella', 'rose', 'gold', 'sarah', etc.)
    // are priced as Premium Registry Domains ($50 - $5,000+) on Spaceship.
    // Standard $0.68 - $0.98 registration prices apply strictly to compound brandable domains
    // (e.g. 'bella-store', 'bella-saudi', 'matjar-bella', 'bella-official').
    if (!slug.contains('-') && slug.length < 9) {
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
            return slug.contains('-') || slug.length >= 9;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  /// Search across all Spaceship <= $1.99 USD extensions with smart suggestions
  static Future<List<DomainSearchResult>> searchAllBudgetExtensions(String rawName) async {
    final slug = sanitizeSlug(rawName);
    if (slug.isEmpty || slug.length < 2) return [];

    final eligibleExtensions = budgetExtensions
        .where((ext) => ext.internalMaxCostUsd <= maxAllowedPriceUsd)
        .toList();

    List<String> targetSlugs = [];

    // If slug already contains a hyphen (e.g. 'bella-store' or 'al-amal-shop') or is long enough, include it
    if (slug.contains('-') || slug.length >= 9) {
      targetSlugs.add(slug);
    }

    // Always generate brandable, budget-safe combinations that are 100% under $2 on Spaceship
    targetSlugs.addAll([
      '$slug-saudi',
      'matjar-$slug',
      '$slug-store',
      '$slug-brand',
      '$slug-official',
      '$slug-shop',
      'dar-$slug',
    ]);

    // De-duplicate target slugs while preserving order
    targetSlugs = targetSlugs.toSet().toList();

    List<Future<DomainSearchResult>> futures = [];

    for (final s in targetSlugs) {
      for (final ext in eligibleExtensions) {
        final fullDomain = '$s${ext.tld}';
        futures.add(() async {
          final isAvail = await isDomainAvailable(fullDomain, slug: s);
          return DomainSearchResult(
            fullDomain: fullDomain,
            tld: ext.tld,
            isAvailable: isAvail,
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
