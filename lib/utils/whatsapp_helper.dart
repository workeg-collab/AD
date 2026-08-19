import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String phoneNumber = '201500682755';

  /// Launch WhatsApp with comprehensive client message including attachments, content & PayTabs payment link
  static Future<void> launchWhatsApp({
    String? customMessage,
    String? businessName,
    String? customerEmail,
    String? category,
    String? domainChoice,
    String? logoInfo,
    String? photosInfo,
    String? profileInfo,
    String? aboutContent,
    String? contactInfo,
    String? notes,
    String? paymentUrl,
  }) async {
    String textMessage = customMessage ??
        'أهلاً POM Agency 👋، أرغب في الاستفادة من عرض إنشاء صفحة تعريفية بـ 299 ريال والتسليم خلال 6 ساعات!';

    if (businessName != null && businessName.trim().isNotEmpty) {
      textMessage += '\n📌 *اسم النشاط:* ${businessName.trim()}';
    }
    if (customerEmail != null && customerEmail.trim().isNotEmpty) {
      textMessage += '\n📧 *البريد الإلكتروني:* ${customerEmail.trim()}';
    }
    if (category != null && category.trim().isNotEmpty) {
      textMessage += '\n🏷️ *تصنيف النشاط:* ${category.trim()}';
    }
    if (domainChoice != null && domainChoice.trim().isNotEmpty) {
      textMessage += '\n🌐 *الدومين المختار:* ${domainChoice.trim()}';
    }

    // Attachments & Content Section (if any is provided)
    final bool hasAttachmentsOrContent = (logoInfo != null && logoInfo.isNotEmpty) ||
        (photosInfo != null && photosInfo.isNotEmpty) ||
        (profileInfo != null && profileInfo.isNotEmpty) ||
        (aboutContent != null && aboutContent.trim().isNotEmpty) ||
        (contactInfo != null && contactInfo.trim().isNotEmpty) ||
        (notes != null && notes.trim().isNotEmpty);

    if (hasAttachmentsOrContent) {
      textMessage += '\n\n📦 *المرفقات وبيانات الموقع:*';

      if (logoInfo != null && logoInfo.isNotEmpty) {
        textMessage += '\n- 🎨 *الشعار / اللوجو:* $logoInfo';
      }
      if (photosInfo != null && photosInfo.isNotEmpty) {
        textMessage += '\n- 📸 *صور النشاط:* $photosInfo';
      }
      if (profileInfo != null && profileInfo.isNotEmpty) {
        textMessage += '\n- 📄 *بروفايل النشاط:* $profileInfo';
      }
      if (aboutContent != null && aboutContent.trim().isNotEmpty) {
        textMessage += '\n- 📝 *محتوى ونصوص الموقع:* ${aboutContent.trim()}';
      }
      if (contactInfo != null && contactInfo.trim().isNotEmpty) {
        textMessage += '\n- 📍 *العنوان وبيانات التواصل:* ${contactInfo.trim()}';
      }
      if (notes != null && notes.trim().isNotEmpty) {
        textMessage += '\n- 💡 *ملاحظات خاصة:* ${notes.trim()}';
      }
    }

    if (paymentUrl != null && paymentUrl.trim().isNotEmpty) {
      textMessage += '\n\n💳 *رابط الدفع الإلكتروني (PayTabs):*\n${paymentUrl.trim()}';
    }

    textMessage += '\n\n💰 *قيمة العرض:* 299 ريال (4,081.35 ج.م شامل TAX 5%)';

    final Uri url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(textMessage)}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
