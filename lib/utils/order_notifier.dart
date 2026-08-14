import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderNotifier {
  /// Send background order notification to company email (sales@pom-agency.online)
  static Future<void> sendAdminNotification({
    required String customerName,
    required String customerPhone,
    required String businessName,
    required String category,
    String? domainChoice,
    String? notes,
    required String paymentMethod,
  }) async {
    final payload = {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'businessName': businessName,
      'category': category,
      'domainChoice': domainChoice ?? '',
      'notes': notes ?? '',
      'paymentMethod': paymentMethod,
    };

    // 1. Try Vercel Serverless Function /api/notify
    try {
      final serverlessUri = Uri.parse('/api/notify');
      await http.post(
        serverlessUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 6));
    } catch (_) {}

    // 2. Direct fallback to FormSubmit email dispatcher in case of offline/direct routing
    try {
      final cleanDomain = (domainChoice ?? '').trim().toLowerCase();
      final spaceshipUrl = cleanDomain.isNotEmpty
          ? 'https://www.spaceship.com/domain-search/?query=$cleanDomain'
          : 'https://www.spaceship.com';

      await http.post(
        Uri.parse('https://formsubmit.co/ajax/sales@pom-agency.online'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          '_subject': '🚨 طلب جديد: $businessName ($paymentMethod)',
          '_template': 'table',
          '_captcha': 'false',
          'طريقة الطلب والدفع': paymentMethod,
          'اسم العميل أو النشاط': businessName.isNotEmpty ? businessName : customerName,
          'رقم هاتف العميل': customerPhone,
          'تصنيف النشاط': category,
          'الدومين المطلوب': cleanDomain.isNotEmpty ? cleanDomain : 'غير محدد',
          'رابط شراء الدومين (Spaceship للإدارة)': spaceshipUrl,
          'المبلغ الإجمالي': '299 SAR (4,081.35 EGP شامل TAX 5%)',
          'ملاحظات إضافية': notes ?? 'لا يوجد',
        }),
      ).timeout(const Duration(seconds: 6));
    } catch (_) {}
  }
}
