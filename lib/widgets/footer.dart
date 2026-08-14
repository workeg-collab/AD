import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/whatsapp_helper.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 24,
        vertical: isMobile ? 30 : 40,
      ),
      color: isDark ? AppTheme.bgDark : Colors.grey.shade100,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
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
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            isDark ? 'assets/images/xxx.png' : 'assets/images/xxx_dark.png',
                            height: 30,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.rocket_launch_rounded,
                                color: AppTheme.primaryDark,
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
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),

                  // WhatsApp quick link
                  InkWell(
                    onTap: () => WhatsAppHelper.launchWhatsApp(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_rounded, color: AppTheme.primaryDark, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '00201093706027 (واتساب المبيعات)',
                            style: TextStyle(
                              color: textColor,
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Divider(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              const SizedBox(height: 20),

              Text(
                AppTranslations.tr('footer_sub'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                '© 2026 POM Agency - SA Web Solutions. جميع الحقوق محفوظة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
