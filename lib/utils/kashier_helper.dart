import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class KashierHelper {
  static const String merchantId = '67fbac5d-49d7-4615-9eab-2b00f7c211db';
  static const String apiKey =
      'e52fac37d9b4237a55fa1b9ca745e8c3\$57813ce0ee96d77d421e225a35032b347380c1c507a86c2230283bfa189b8a9d9cc952af190c71b3fc10d50dffd1b34f';
  static const String checkoutBaseUrl = 'https://checkout.kashier.io';

  /// Generate Kashier HMAC-SHA256 hash for secure checkout
  static String generateHash({
    required String mid,
    required String orderId,
    required double amount,
    required String currency,
    required String secret,
  }) {
    // Kashier standard payment path format: /?payment=mid.orderId.amount.currency
    final String amountStr = amount.toStringAsFixed(2);
    final String path = '/?payment=$mid.$orderId.$amountStr.$currency';
    final key = utf8.encode(secret);
    final bytes = utf8.encode(path);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }

  /// Create a Kashier Hosted Checkout URL
  static Future<String?> createPaymentPage({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String businessName,
    String? domainChoice,
    double amountSar = 299.00,
    double sarToEgpRate = 13.53,
    double taxPercent = 5.00,
  }) async {
    final baseEgp = amountSar * sarToEgpRate;
    final taxEgp = baseEgp * (taxPercent / 100);
    final totalEgp = double.parse((baseEgp + taxEgp).toStringAsFixed(2));

    final payload = {
      'customerName': customerName.isNotEmpty ? customerName : 'عميل كريم',
      'customerPhone': customerPhone.isNotEmpty ? customerPhone : '+201500682755',
      'customerEmail': customerEmail.isNotEmpty ? customerEmail : 'customer@ad-landing.com',
      'businessName': businessName.isNotEmpty ? businessName : 'طلب جديد',
      'domainChoice': domainChoice ?? '',
      'amountSar': amountSar,
      'sarToEgpRate': sarToEgpRate,
      'taxPercent': taxPercent,
    };

    // 1. Try Vercel Serverless Function first
    try {
      final serverlessUri = Uri.base.resolve('/api/kashier');
      final response = await http.post(
        serverlessUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['redirect_url'] != null) {
          return data['redirect_url'] as String;
        }
      }
    } catch (_) {}

    // 2. Direct HMAC-SHA256 URL Generation Fallback
    try {
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      const currency = 'EGP';
      final hash = generateHash(
        mid: merchantId,
        orderId: orderId,
        amount: totalEgp,
        currency: currency,
        secret: apiKey,
      );

      final metaData = jsonEncode({
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerEmail': customerEmail,
        'businessName': businessName,
        'domainChoice': domainChoice ?? '',
      });

      final queryParams = {
        'merchantId': merchantId,
        'orderId': orderId,
        'amount': totalEgp.toStringAsFixed(2),
        'currency': currency,
        'hash': hash,
        'mode': 'live',
        'metaData': metaData,
        'merchantRedirect': 'https://sa.pom-agency.online',
        'allowedMethods': 'card,wallet',
        'display': 'ar',
      };

      final uri = Uri.parse(checkoutBaseUrl).replace(queryParameters: queryParams);
      return uri.toString();
    } catch (_) {}

    return null;
  }

  /// Launch Kashier payment page in external browser tab/window
  static Future<bool> launchPayment({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String businessName,
    String? domainChoice,
    double amountSar = 299.00,
    double sarToEgpRate = 13.53,
    double taxPercent = 5.00,
  }) async {
    final url = await createPaymentPage(
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      businessName: businessName,
      domainChoice: domainChoice,
      amountSar: amountSar,
      sarToEgpRate: sarToEgpRate,
      taxPercent: taxPercent,
    );

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }
    return false;
  }
}
