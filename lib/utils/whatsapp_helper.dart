import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  static const String phoneNumber = '201093706027';

  /// Generate direct Spaceship purchase link for admin to buy the domain instantly
  static String getSpaceshipPurchaseUrl(String domain) {
    final clean = domain.trim().toLowerCase();
    if (clean.isEmpty) return 'https://www.spaceship.com';
    return 'https://www.spaceship.com/domain-search/?query=$clean';
  }

  /// Launch WhatsApp with full order notification details & domain purchase link
  static Future<void> launchWhatsApp({
    String? customMessage,
    String? customerName,
    String? customerPhone,
    String? businessName,
    String? category,
    String? domainChoice,
    String? notes,
    String? paymentMethod,
  }) async {
    // If it's a general consultation inquiry (no customer name provided yet)
    if (customerName == null && businessName == null && customMessage != null) {
      final Uri url = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(customMessage)}',
      );
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
      return;
    }

    final domain = (domainChoice != null && domainChoice.trim().isNotEmpty)
        ? domainChoice.trim()
        : null;

    final String spaceshipLink = domain != null ? getSpaceshipPurchaseUrl(domain) : '';

    String textMessage =
        '🚨 *إشعار طلب جديد - POM Agency* 🚨\n'
        '━━━━━━━━━━━━━━━━━━━━\n';

    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      textMessage += '💳 *طريقة الدفع/الطلب:* $paymentMethod\n';
    }

    final displayName = customerName ?? businessName ?? 'عميل جديد';
    textMessage += '👤 *اسم العميل/النشاط:* $displayName\n';

    if (customerPhone != null && customerPhone.isNotEmpty) {
      textMessage += '📱 *رقم هاتف العميل:* $customerPhone\n';
    }

    if (category != null && category.isNotEmpty) {
      textMessage += '🏷️ *تصنيف النشاط:* $category\n';
    }

    if (domain != null) {
      textMessage += '🌐 *الدومين المختار:* $domain\n';
      textMessage += '🛒 *رابط شراء الدومين المباشر (Spaceship):*\n$spaceshipLink\n';
    } else {
      textMessage += '🌐 *الدومين:* سيتم اختياره ومراجعته مع العميل\n';
    }

    textMessage +=
        '━━━━━━━━━━━━━━━━━━━━\n'
        '💰 *تفاصيل المبلغ:*\n'
        '🇸🇦 السعر بالريال: 299.00 SAR\n'
        '🇺🇸 السعر بالدولار: \$79.73 USD\n'
        '🇪🇬 السعر بالمصري (قبل الضريبة): 3,887.00 ج.م\n'
        '🧾 TAX (5%): + 194.35 ج.م\n'
        '💳 الإجمالي للدفع: 4,081.35 ج.م\n'
        '━━━━━━━━━━━━━━━━━━━━';

    if (notes != null && notes.trim().isNotEmpty) {
      textMessage += '\n📝 *ملاحظات إضافية:* ${notes.trim()}';
    }

    final Uri url = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(textMessage)}',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  /// Launch admin notification specifically when PayTabs electronic payment is initiated
  static Future<void> notifyAdminPayTabsOrder({
    required String customerName,
    required String customerPhone,
    required String businessName,
    required String category,
    String? domainChoice,
    String? notes,
  }) async {
    await launchWhatsApp(
      customerName: customerName,
      customerPhone: customerPhone,
      businessName: businessName,
      category: category,
      domainChoice: domainChoice,
      notes: notes,
      paymentMethod: 'دفع إلكتروني عبر PayTabs 💳',
    );
  }
}
