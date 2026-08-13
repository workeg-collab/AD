import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.bolt_rounded,
        'color': AppTheme.primaryDark,
        'title': 'تسليم رائع خلال 6 ساعات',
        'desc': 'بدون انتظار أسابيع، استلم رابط موقعك المعاين وجاهز للنشر في نفس اليوم بعد إرسال بياناتك.',
      },
      {
        'icon': Icons.language_rounded,
        'color': AppTheme.secondary,
        'title': 'دومين مجاني للسنة الأولى',
        'desc': 'نشتري ونربط لك اسم دومين خاص باسم محلك أو شركتك (.site / .online / .xyz) مجاناً.',
      },
      {
        'icon': Icons.published_with_changes_rounded,
        'color': AppTheme.accentGold,
        'title': '3 جولات تعديل مجانية',
        'desc': 'نعطيك الحرية الكاملة لتغيير النصوص والصور والألوان للتأكد من الرضا التام قبل الإطلاق.',
      },
      {
        'icon': Icons.flash_on_rounded,
        'color': const Color(0xFF02569B),
        'title': 'مطور بتقنية Flutter Web',
        'desc': 'سرعة استجابة فائقة وتصميم مرن يعمل بسلاسة على شاشات الأيفون والسامسونج والكمبيوتر.',
      },
      {
        'icon': Icons.chat_outlined,
        'color': const Color(0xFF25D366),
        'title': 'تحويل المبيعات للواتساب',
        'desc': 'روابط واتساب مباشرة على المنتجات والخدمات تتيح للعميل الشراء والتواصل معك فوراً.',
      },
      {
        'icon': Icons.cloud_done_rounded,
        'color': Colors.purpleAccent,
        'title': 'استضافة Vercel الفائقة',
        'desc': 'موقعك مستضاف على أفضل السيرفرات العالمية مع حماية SSL وسرعة تحميل لا تتجاوز ثانية واحدة.',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      color: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'لماذا تختار خدمة AD لتطوير موقعك؟',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'نوفر لك حلولاً سريعة واقتصادية دون التنازل عن الجودة والأناقة',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Grid layout
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : (MediaQuery.of(context).size.width < 1024 ? 2 : 3),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isMobile ? 1.6 : 1.35,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final item = features[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: item['color'] as Color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
