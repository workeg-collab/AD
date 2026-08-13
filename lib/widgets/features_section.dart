import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../utils/app_translations.dart';

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
        'color': const Color(0xFF10B981),
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
        'title': 'تسليم رائع خلال 6 ساعات',
        'desc': 'بدون انتظار أسابيع، استلم رابط موقعك المعاين وجاهز للنشر في نفس اليوم بعد إرسال بياناتك.',
      },
      {
        'icon': Icons.language_rounded,
        'color': const Color(0xFF3B82F6),
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
        'title': 'دومين مجاني للسنة الأولى',
        'desc': 'نشتري ونربط لك اسم دومين خاص باسم محلك أو شركتك (.site / .online / .xyz) مجاناً.',
      },
      {
        'icon': Icons.published_with_changes_rounded,
        'color': const Color(0xFFF59E0B),
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        'title': '3 جولات تعديل مجانية',
        'desc': 'نعطيك الحرية الكاملة لتغيير النصوص والصور والألوان للتأكد من الرضا التام قبل الإطلاق.',
      },
      {
        'icon': Icons.flash_on_rounded,
        'color': const Color(0xFF8B5CF6),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
        'title': 'مطور بتقنية Flutter Web',
        'desc': 'سرعة استجابة فائقة وتصميم مرن يعمل بسلاسة على شاشات الأيفون والسامسونج والكمبيوتر.',
      },
      {
        'icon': Icons.chat_outlined,
        'color': const Color(0xFF25D366),
        'gradient': [const Color(0xFF25D366), const Color(0xFF16A34A)],
        'title': 'تحويل المبيعات للواتساب',
        'desc': 'روابط واتساب مباشرة على المنتجات والخدمات تتيح للعميل الشراء والتواصل معك فوراً.',
      },
      {
        'icon': Icons.cloud_done_rounded,
        'color': const Color(0xFFEC4899),
        'gradient': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
        'title': 'استضافة Vercel الفائقة',
        'desc': 'موقعك مستضاف على أفضل السيرفرات العالمية مع حماية SSL وسرعة تحميل لا تتجاوز ثانية واحدة.',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      color: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                AppTranslations.tr('feat_title'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppTranslations.tr('feat_sub'),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Animated Grid layout
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : (MediaQuery.of(context).size.width < 1024 ? 2 : 3),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isMobile ? 1.55 : 1.35,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _AnimatedFeatureCard(
                    item: features[index],
                    textColor: textColor,
                    isDark: isDark,
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

class _AnimatedFeatureCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color? textColor;
  final bool isDark;

  const _AnimatedFeatureCard({
    required this.item,
    required this.textColor,
    required this.isDark,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item['color'] as Color;
    final gradient = widget.item['gradient'] as List<Color>;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? color : (widget.isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? color.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 24 : 12,
              offset: Offset(0, _isHovered ? 10 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isHovered
                        ? gradient
                        : [color.withValues(alpha: 0.15), color.withValues(alpha: 0.08)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  widget.item['icon'] as IconData,
                  color: _isHovered ? Colors.white : color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.item['title'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item['desc'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
