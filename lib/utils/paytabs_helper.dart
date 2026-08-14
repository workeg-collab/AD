import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PayTabsHelper {
  static const int profileId = 154004;
  static const String serverKey = 'SHJ9WHMT6Z-J9KRRLTHBG-2HBDZKRTWR';
  static const String clientKey = 'C7K2GR-DVBD6P-KRRB7H-G296GT';
  static const String directEndpoint = 'https://secure-egypt.paytabs.com/payment/request';

  /// Create a PayTabs Hosted Payment Page session and return the redirect URL
  static Future<String?> createPaymentPage({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String businessName,
    String? domainChoice,
    double amountSar = 299.00,
    double sarToEgpRate = 13.00,
    double taxPercent = 5.00,
  }) async {
    final baseEgp = amountSar * sarToEgpRate;
    final taxEgp = baseEgp * (taxPercent / 100);
    final totalEgp = double.parse((baseEgp + taxEgp).toStringAsFixed(2));

    final payload = {
      'customerName': customerName.isNotEmpty ? customerName : 'عميل كريم',
      'customerPhone': customerPhone.isNotEmpty ? customerPhone : '+201093706027',
      'customerEmail': customerEmail.isNotEmpty ? customerEmail : 'customer@ad-landing.com',
      'businessName': businessName.isNotEmpty ? businessName : 'طلب جديد',
      'domainChoice': domainChoice ?? '',
      'amountSar': amountSar,
      'sarToEgpRate': sarToEgpRate,
      'taxPercent': taxPercent,
    };

    // 1. Try Vercel Serverless Function first (Bypasses all browser CORS restrictions)
    try {
      final serverlessUri = Uri.parse('/api/paytabs');
      final response = await http.post(
        serverlessUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['redirect_url'] != null) {
          return data['redirect_url'] as String;
        }
      }
    } catch (_) {}

    // 2. Direct Fallback
    try {
      final cartId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      String description = 'تصميم صفحة لـ $businessName (299 SAR + 5% ضريبة = $totalEgp ج.م)';
      if (domainChoice != null && domainChoice.isNotEmpty) {
        description += ' + دومين $domainChoice';
      }

      final directPayload = {
        'profile_id': profileId,
        'tran_type': 'sale',
        'tran_class': 'ecom',
        'cart_id': cartId,
        'cart_description': description,
        'cart_currency': 'EGP',
        'cart_amount': totalEgp,
        'customer_details': {
          'name': customerName.isNotEmpty ? customerName : 'عميل كريم',
          'email': customerEmail.isNotEmpty ? customerEmail : 'customer@ad-landing.com',
          'phone': customerPhone.isNotEmpty ? customerPhone : '+201093706027',
          'street1': 'Online Order',
          'city': 'Cairo',
          'state': 'Cairo',
          'country': 'EG',
        },
      };

      final response = await http.post(
        Uri.parse(directEndpoint),
        headers: {
          'Authorization': serverKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(directPayload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final redirectUrl = data['redirect_url'] as String?;
        return redirectUrl;
      }
    } catch (_) {}

    return null;
  }

  /// Launch PayTabs payment page in external browser tab/window
  static Future<bool> launchPayment({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String businessName,
    String? domainChoice,
    double amountSar = 299.00,
    double sarToEgpRate = 13.00,
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
