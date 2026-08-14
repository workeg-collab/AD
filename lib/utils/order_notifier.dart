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
    String? logoInfo,
    String? photosInfo,
    String? profileInfo,
    String? aboutContent,
    String? contactInfo,
    String? notes,
    required String paymentMethod,
    String? paymentUrl,
  }) async {
    final payload = {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'businessName': businessName,
      'category': category,
      'domainChoice': domainChoice ?? '',
      'logoInfo': logoInfo ?? '',
      'photosInfo': photosInfo ?? '',
      'profileInfo': profileInfo ?? '',
      'aboutContent': aboutContent ?? '',
      'contactInfo': contactInfo ?? '',
      'notes': notes ?? '',
      'paymentMethod': paymentMethod,
      'paymentUrl': paymentUrl ?? '',
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

      final Map<String, dynamic> emailPayload = {
        '_subject': '🚨 طلب جديد: $businessName ($paymentMethod)',
        '_template': 'table',
        '_captcha': 'false',
        'طريقة الطلب والدفع': paymentMethod,
        'اسم العميل أو النشاط': businessName.isNotEmpty ? businessName : customerName,
        'رقم هاتف العميل': customerPhone,
        'تصنيف النشاط': category,
        'الدومين المطلوب': cleanDomain.isNotEmpty ? cleanDomain : 'غير محدد',
        'رابط شراء الدومين (Spaceship للإدارة)': spaceshipUrl,
      };

      if (logoInfo != null && logoInfo.isNotEmpty) {
        emailPayload['الشعار / اللوجو'] = logoInfo;
      }
      if (photosInfo != null && photosInfo.isNotEmpty) {
        emailPayload['صور النشاط'] = photosInfo;
      }
      if (profileInfo != null && profileInfo.isNotEmpty) {
        emailPayload['بروفايل النشاط'] = profileInfo;
      }
      if (aboutContent != null && aboutContent.isNotEmpty) {
        emailPayload['محتوى ونصوص الموقع'] = aboutContent;
      }
      if (contactInfo != null && contactInfo.isNotEmpty) {
        emailPayload['العنوان وبيانات التواصل'] = contactInfo;
      }
      if (notes != null && notes.isNotEmpty) {
        emailPayload['ملاحظات إضافية'] = notes;
      }
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        emailPayload['رابط الدفع الإلكتروني (PayTabs)'] = paymentUrl;
      }

      emailPayload['المبلغ الإجمالي'] = '299 SAR (4,081.35 EGP شامل TAX 5%)';

      await http.post(
        Uri.parse('https://formsubmit.co/ajax/sales@pom-agency.online'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(emailPayload),
      ).timeout(const Duration(seconds: 6));
    } catch (_) {}
  }
}
