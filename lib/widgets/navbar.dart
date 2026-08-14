import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/whatsapp_helper.dart';
import '../main.dart';
import 'language_selector_button.dart';
import 'domain_search_modal.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navTextColor = theme.textTheme.bodyMedium?.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 10 : 14,
      ),
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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: isMobile ? 38 : 48,
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          isDark ? 'assets/images/xxx.png' : 'assets/images/xxx_dark.png',
                          height: isMobile ? 30 : 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.rocket_launch_rounded,
                              color: AppTheme.primaryDark,
                              size: isMobile ? 18 : 24,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'POM SA',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 20,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryDark,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.accentGold, width: 1),
                              ),
                              child: Text(
                                'السعودية 🇸🇦',
                                style: TextStyle(
                                  fontSize: isMobile ? 9.5 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!isMobile)
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
              ),

              // Desktop Nav Items
              if (!isMobile)
                Row(
                  children: [
                    TextButton(
                      onPressed: onFeaturesTap,
                      child: Text(
                        AppTranslations.tr('nav_features'),
                        style: TextStyle(color: navTextColor, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: onDemosTap,
                      child: Text(
                        AppTranslations.tr('nav_demos'),
                        style: TextStyle(color: navTextColor, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: onOrderTap,
                      child: Text(
                        AppTranslations.tr('nav_pricing'),
                        style: const TextStyle(color: AppTheme.accentGold, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const DomainSearchModal(),
                        );
                      },
                      icon: const Icon(Icons.language_rounded, size: 16, color: Color(0xFF10B981)),
                      label: const Text(
                        'فحص الدومين 🌐',
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              // Action CTA, Language Selector & Theme Toggle Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Small Language Selector Button
                  const LanguageSelectorButton(),

                  SizedBox(width: isMobile ? 5 : 8),

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
                            padding: EdgeInsets.all(isMobile ? 6 : 7),
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
                              size: isMobile ? 14 : 15,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(width: isMobile ? 6 : 10),

                  // Action CTA
                  ElevatedButton.icon(
                    onPressed: () => WhatsAppHelper.launchWhatsApp(),
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: isMobile ? 15 : 18),
                    label: Text(
                      isMobile
                          ? (isSmallMobile ? 'طلب' : AppTranslations.tr('nav_order'))
                          : AppTranslations.tr('whatsapp_btn_top'),
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 20,
                        vertical: isMobile ? 10 : 14,
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
