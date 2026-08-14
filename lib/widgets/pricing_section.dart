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
    final textColor = theme.textTheme.bodyLarge?.color;

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
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 40 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentGold, width: 1),
                ),
                child: Text(
                  AppTranslations.tr('price_badge'),
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppTranslations.tr('price_title'),
                style: TextStyle(
                  fontSize: isMobile ? 24 : 34,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppTranslations.tr('price_sub'),
                style: TextStyle(
                  fontSize: isMobile ? 13.5 : 16,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // Pricing Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 18 : 40),
                  child: Column(
                    children: [
                      // Price Header
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            AppTranslations.tr('price_amount'),
                            style: TextStyle(
                              fontSize: isSmallMobile ? 42 : (isMobile ? 48 : 56),
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                          Text(
                            AppTranslations.tr('price_currency'),
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            AppTranslations.tr('price_period'),
                            style: TextStyle(
                              fontSize: isMobile ? 12.5 : 14,
                              color: AppTheme.textMuted.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text(
                        AppTranslations.tr('price_includes'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isMobile ? 20 : 32),
                      Divider(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      SizedBox(height: isMobile ? 20 : 32),

                      // Included Items List
                      Column(
                        children: packageItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3.5),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13.5 : 15,
                                      color: textColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: isMobile ? 24 : 36),

                      // Order Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onOpenOrderModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flash_on_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                AppTranslations.tr('price_cta_btn'),
                                style: TextStyle(
                                  fontSize: isMobile ? 15 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
