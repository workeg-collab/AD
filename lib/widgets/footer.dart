import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/whatsapp_helper.dart';
import 'legal_policy_modal.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 36 : 48,
      ),
      color: isDark ? AppTheme.surfaceDark : const Color(0xFFF4F6F8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  // Brand with POM Agency Logo
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
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
                            height: 30,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.verified_rounded,
                                color: AppTheme.primary,
                                size: 20,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'POM Agency | SA Web Solutions',
                        style: TextStyle(
                          fontSize: isMobile ? 14.5 : 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),

                  // WhatsApp quick link
                  InkWell(
                    onTap: () => WhatsAppHelper.launchWhatsApp(),
                    borderRadius: AppTheme.radiusSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.cardDark : Colors.white,
                        borderRadius: AppTheme.radiusSm,
                        border: Border.all(
                          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '00201500682755 (${AppTranslations.tr('whatsapp_sales_label')})',
                            style: TextStyle(
                              color: textColor,
                              fontSize: isMobile ? 12.5 : 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              const SizedBox(height: 24),

              // Legal Policy Links
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 10,
                children: [
                  InkWell(
                    onTap: () => LegalPolicyModal.show(context, initialTabIndex: 0),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'سياسة الخصوصية وسرية البيانات',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => LegalPolicyModal.show(context, initialTabIndex: 1),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.published_with_changes_rounded,
                            size: 15,
                            color: isDark ? AppTheme.primaryLight : AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'سياسة التعديل والاسترجاع والإلغاء',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                AppTranslations.tr('footer_sub'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                  fontSize: 12.5,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                '© 2026 POM Agency - SA Web Solutions. جميع الحقوق محفوظة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
