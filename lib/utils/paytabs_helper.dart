import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PayTabsHelper {
  static const int profileId = 154004;
  static const String serverKey = 'SHJ9WHMT6Z-J9KRRLTHBG-2HBDZKRTWR';
  static const String clientKey = 'C7K2GR-DVBD6P-KRRB7H-G296GT';
  static const String endpoint = 'https://secure-egypt.paytabs.com/payment/request';

  /// Create a PayTabs Hosted Payment Page session and return the redirect URL
  static Future<String?> createPaymentPage({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String businessName,
    String? domainChoice,
    double amount = 2990.00,
    String currency = 'EGP',
  }) async {
    try {
      final cartId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      String description = 'تصميم صفحة تعريفية لـ $businessName';
      if (domainChoice != null && domainChoice.isNotEmpty) {
        description += ' + دومين $domainChoice';
      }

      final payload = {
        'profile_id': profileId,
        'tran_type': 'sale',
        'tran_class': 'ecom',
        'cart_id': cartId,
        'cart_description': description,
        'cart_currency': currency,
        'cart_amount': amount,
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
        Uri.parse(endpoint),
        headers: {
          'Authorization': serverKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
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
    double amount = 2990.00,
    String currency = 'EGP',
  }) async {
    final url = await createPaymentPage(
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      businessName: businessName,
      domainChoice: domainChoice,
      amount: amount,
      currency: currency,
    );

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    return false;
  }
}
