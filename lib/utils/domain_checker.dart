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

  /// Check a single domain availability via DNS over HTTPS
  static Future<bool> isDomainAvailable(String domain) async {
    try {
      final uri = Uri.parse('https://dns.google/resolve?name=$domain&type=A');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['Status'] as int?;
        final answer = data['Answer'];

        if (status == 3) return true;
        if (answer == null || (answer is List && answer.isEmpty)) {
          final nsUri = Uri.parse('https://dns.google/resolve?name=$domain&type=NS');
          final nsResponse = await http.get(nsUri).timeout(const Duration(seconds: 4));
          if (nsResponse.statusCode == 200) {
            final nsData = jsonDecode(nsResponse.body);
            final nsStatus = nsData['Status'] as int?;
            final nsAnswer = nsData['Answer'];
            if (nsStatus == 3 || nsAnswer == null || (nsAnswer is List && nsAnswer.isEmpty)) {
              return true;
            }
          }
        }
        return false;
      }
    } catch (_) {}
    return false;
  }

  /// Search across all <= $2 USD extensions
  static Future<List<DomainSearchResult>> searchAllBudgetExtensions(String rawName) async {
    final slug = sanitizeSlug(rawName);
    if (slug.isEmpty || slug.length < 2) return [];

    final eligibleExtensions = budgetExtensions
        .where((ext) => ext.internalMaxCostUsd <= maxAllowedPriceUsd)
        .toList();

    List<Future<DomainSearchResult>> futures = eligibleExtensions.map((ext) async {
      final fullDomain = '$slug${ext.tld}';
      final isAvail = await isDomainAvailable(fullDomain);
      return DomainSearchResult(
        fullDomain: fullDomain,
        tld: ext.tld,
        isAvailable: isAvail,
      );
    }).toList();

    final results = await Future.wait(futures);

    results.sort((a, b) {
      if (a.isAvailable && !b.isAvailable) return -1;
      if (!a.isAvailable && b.isAvailable) return 1;
      return 0;
    });

    return results;
  }

  /// Get direct Spaceship search & buy URL for the chosen domain
  static String getSpaceshipUrl(String domain) {
    return 'https://www.spaceship.com/domain-search/?query=$domain';
  }
}
