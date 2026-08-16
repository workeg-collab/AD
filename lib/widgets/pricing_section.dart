import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';

class PricingSection extends StatelessWidget {
  final VoidCallback onOpenOrderModal;

  const PricingSection({
    super.key,
    required this.onOpenOrderModal,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;

    final List<String> packageItems = [
      AppTranslations.tr('price_item_1'),
      AppTranslations.tr('price_item_2'),
      AppTranslations.tr('price_item_3'),
      AppTranslations.tr('price_item_4'),
      AppTranslations.tr('price_item_5'),
      AppTranslations.tr('price_item_6'),
      AppTranslations.tr('price_item_7'),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 48 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryContainerDark
                      : AppTheme.primaryContainer,
                  borderRadius: AppTheme.radiusFull,
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  AppTranslations.tr('price_badge'),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                AppTranslations.tr('price_title'),
                style: TextStyle(
                  fontSize: isMobile ? 24 : 34,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                AppTranslations.tr('price_sub'),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isMobile ? 28 : 44),

              // Featured Pricing Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: AppTheme.radiusXl,
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: isDark ? 0.6 : 0.8),
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.softShadow(isDark: isDark, elevation: 2),
                ),
                padding: EdgeInsets.all(isMobile ? 20 : 44),
                child: Column(
                  children: [
                    // Price Number & Currency Row
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          AppTranslations.tr('price_amount'),
                          style: TextStyle(
                            fontSize: isSmallMobile ? 44 : (isMobile ? 50 : 64),
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppTranslations.tr('price_currency'),
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                            Text(
                              AppTranslations.tr('price_period'),
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13.5,
                                color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Value Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryContainerDark
                            : AppTheme.primaryContainer,
                        borderRadius: AppTheme.radiusSm,
                      ),
                      child: Text(
                        AppTranslations.tr('price_includes'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: isMobile ? 22 : 32),
                    Divider(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    SizedBox(height: isMobile ? 22 : 32),

                    // Included Items Checklist
                    Column(
                      children: packageItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.primaryContainerDark
                                      : AppTheme.primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: AppTheme.primary,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13.5 : 15,
                                    color: textColor,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: isMobile ? 24 : 36),

                    // Big Order CTA Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onOpenOrderModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppTheme.radiusMd,
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              AppTranslations.tr('price_cta_btn'),
                              style: TextStyle(
                                fontSize: isMobile ? 14.5 : 16.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Trust Assurance row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 15, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          'ضمان تسليم كامل و3 جولات تعديل مجانية 100%',
                          style: TextStyle(
                            fontSize: isMobile ? 11.5 : 12.5,
                            color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
