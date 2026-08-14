import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String phoneNumber = '201093706027';

  /// Launch WhatsApp with clean, professional client message
  static Future<void> launchWhatsApp({
    String? customMessage,
    String? businessName,
    String? category,
    String? domainChoice,
  }) async {
    String textMessage = customMessage ??
        'أهلاً POM Agency 👋، أرغب في الاستفادة من عرض إنشاء صفحة تعريفية بـ 299 ريال شاملة الدومين والتسليم خلال 6 ساعات!';

    if (businessName != null && businessName.trim().isNotEmpty) {
      textMessage += '\n📌 اسم النشاط: ${businessName.trim()}';
    }
    if (category != null && category.trim().isNotEmpty) {
      textMessage += '\n🏷️ تصنيف النشاط: ${category.trim()}';
    }
    if (domainChoice != null && domainChoice.trim().isNotEmpty) {
      textMessage += '\n🌐 الدومين المقترح: ${domainChoice.trim()}';
    }

    final Uri url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(textMessage)}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
