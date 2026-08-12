import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String phoneNumber = '201093706027';

  static Future<void> launchWhatsApp({
    String? customMessage,
    String? businessName,
    String? category,
    String? domainChoice,
  }) async {
    String textMessage = customMessage ??
        'أهلاً بك 👋، أرغب في الاستفادة من عرض إنشاء صفحة تعريفية بـ 299 ريال شاملة الدومين التأسيسي والتسليم خلال 6 ساعات!';

    if (businessName != null && businessName.isNotEmpty) {
      textMessage += '\n📌 اسم النشاط: $businessName';
    }
    if (category != null && category.isNotEmpty) {
      textMessage += '\n🏷️ تصنيف النشاط: $category';
    }
    if (domainChoice != null && domainChoice.isNotEmpty) {
      textMessage += '\n🌐 الدومين المقترح: $domainChoice';
    }

    final Uri url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(textMessage)}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
