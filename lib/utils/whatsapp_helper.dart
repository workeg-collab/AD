import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String phoneNumber = '201093706027';

  /// Launch WhatsApp with clean, professional client message including PayTabs payment link
  static Future<void> launchWhatsApp({
    String? customMessage,
    String? businessName,
    String? category,
    String? domainChoice,
    String? paymentUrl,
  }) async {
    String textMessage = customMessage ??
        'أهلاً POM Agency 👋، أرغب في الاستفادة من عرض إنشاء صفحة تعريفية بـ 299 ريال والتسليم خلال 6 ساعات!';

    if (businessName != null && businessName.trim().isNotEmpty) {
      textMessage += '\n📌 اسم النشاط: ${businessName.trim()}';
    }
    if (category != null && category.trim().isNotEmpty) {
      textMessage += '\n🏷️ تصنيف النشاط: ${category.trim()}';
    }
    if (domainChoice != null && domainChoice.trim().isNotEmpty) {
      textMessage += '\n🌐 الدومين المختار: ${domainChoice.trim()}';
    }
    if (paymentUrl != null && paymentUrl.trim().isNotEmpty) {
      textMessage += '\n💳 رابط الدفع الإلكتروني (PayTabs):\n${paymentUrl.trim()}';
    }

    textMessage += '\n💰 قيمة العرض: 299 ريال (4,081.35 ج.م شامل TAX 5%)';

    final Uri url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(textMessage)}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
