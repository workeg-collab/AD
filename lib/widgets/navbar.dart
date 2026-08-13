import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/whatsapp_helper.dart';
import '../main.dart';

class Navbar extends StatelessWidget {
  final VoidCallback onOrderTap;
  final VoidCallback onDemosTap;
  final VoidCallback onFeaturesTap;

  const Navbar({
    super.key,
    required this.onOrderTap,
    required this.onDemosTap,
    required this.onFeaturesTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navTextColor = theme.textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo with POM Agency Logo Image
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/pom_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.rocket_launch_rounded,
                            color: AppTheme.primaryDark,
                            size: 24,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'POM SA',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryDark,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.accentGold, width: 1),
                            ),
                            child: const Text(
                              'السعودية 🇸🇦',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'POM Agency | حلول ويب سريعة',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Desktop Nav Items
              if (!isMobile)
                Row(
                  children: [
                    TextButton(
                      onPressed: onFeaturesTap,
                      child: Text(
                        'المميزات والضمان',
                        style: TextStyle(color: navTextColor, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: onDemosTap,
                      child: Text(
                        'قوالب المعاينة',
                        style: TextStyle(color: navTextColor, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: onOrderTap,
                      child: const Text(
                        'تفاصيل العرض (299 ريال)',
                        style: TextStyle(color: AppTheme.accentGold, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              // Action CTA & Tiny Dark Mode Icon
              Row(
                children: [
                  // Theme Mode Toggle Icon Button
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, child) {
                      final isDark = mode == ThemeMode.dark;
                      return Tooltip(
                        message: isDark ? 'التحويل للوضع الساطع الأبيض ☀️' : 'التحويل للوضع المظلم 🌙',
                        child: InkWell(
                          onTap: () {
                            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.cardDark : Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                              color: isDark ? Colors.amber : AppTheme.primary,
                              size: 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 10),

                  // Action CTA
                  ElevatedButton.icon(
                    onPressed: () => WhatsAppHelper.launchWhatsApp(),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: Text(isMobile ? 'اطلب الآن' : 'تواصل واتساب مباشر'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
