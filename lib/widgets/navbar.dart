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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navTextColor = theme.textTheme.bodyMedium?.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 28,
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
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo Area
              InkWell(
                onTap: () {},
                borderRadius: AppTheme.radiusMd,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: isMobile ? 36 : 44,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : AppTheme.bgLight,
                        borderRadius: AppTheme.radiusSm,
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          isDark ? 'assets/images/xxx.png' : 'assets/images/xxx_dark.png',
                          height: isMobile ? 26 : 34,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.verified_rounded,
                              color: AppTheme.primary,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                                fontSize: isMobile ? 15 : 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.primaryContainerDark
                                    : AppTheme.primaryContainer,
                                borderRadius: AppTheme.radiusSm,
                                border: Border.all(
                                  color: AppTheme.primary.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'السعودية 🇸🇦',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!isMobile)
                          const Text(
                            'حلول الويب والصفحات التعريفية السريعة',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Desktop Navigation Links
              if (!isMobile)
                Row(
                  children: [
                    _buildNavLink(
                      title: AppTranslations.tr('nav_features'),
                      onTap: onFeaturesTap,
                      color: navTextColor,
                    ),
                    const SizedBox(width: 8),
                    _buildNavLink(
                      title: AppTranslations.tr('nav_demos'),
                      onTap: onDemosTap,
                      color: navTextColor,
                    ),
                    const SizedBox(width: 8),
                    _buildNavLink(
                      title: AppTranslations.tr('nav_pricing'),
                      onTap: onOrderTap,
                      color: isDark ? const Color(0xFFFBBF24) : AppTheme.accentGold,
                      isBold: true,
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const DomainSearchModal(),
                        );
                      },
                      icon: const Icon(Icons.language_rounded, size: 16, color: AppTheme.primary),
                      label: Text(
                        AppTranslations.tr('nav_domain_check'),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSm),
                      ),
                    ),
                  ],
                ),

              // Actions (Language, Theme Toggle, Primary CTA)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LanguageSelectorButton(),
                  const SizedBox(width: 8),

                  // Theme Mode Toggle
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, child) {
                      final isCurrentDark = mode == ThemeMode.dark;
                      return IconButton(
                        tooltip: isCurrentDark ? 'التحويل للوضع النهاري ☀️' : 'التحويل للوضع الليلي 🌙',
                        onPressed: () {
                          themeNotifier.value = isCurrentDark ? ThemeMode.light : ThemeMode.dark;
                        },
                        icon: Icon(
                          isCurrentDark ? Icons.wb_sunny_rounded : Icons.dark_mode_outlined,
                          size: 18,
                          color: isCurrentDark ? const Color(0xFFFBBF24) : AppTheme.textMuted,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.cardDark : AppTheme.bgLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusSm,
                            side: BorderSide(
                              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 10),

                  // Top Action CTA Button
                  ElevatedButton.icon(
                    onPressed: () => WhatsAppHelper.launchWhatsApp(),
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: isMobile ? 14 : 16),
                    label: Text(
                      isMobile
                          ? AppTranslations.tr('nav_order')
                          : AppTranslations.tr('whatsapp_btn_top'),
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 18,
                        vertical: isMobile ? 10 : 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusSm,
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

  Widget _buildNavLink({
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool isBold = false,
  }) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusSm),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14.5,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
