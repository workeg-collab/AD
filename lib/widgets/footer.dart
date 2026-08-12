import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/whatsapp_helper.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: AppTheme.bgDark,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand with POM Agency Logo
                  Row(
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            'assets/images/pom_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.rocket_launch_rounded,
                                color: AppTheme.primary,
                                size: 20,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'POM Agency | AD Web Solutions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),

                  // WhatsApp quick link
                  InkWell(
                    onTap: () => WhatsAppHelper.launchWhatsApp(),
                    child: const Row(
                      children: [
                        Icon(Icons.chat_rounded, color: AppTheme.primary, size: 20),
                        SizedBox(width: 6),
                        Text(
                          '01142466903 (واتساب المبيعات)',
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: AppTheme.borderDark),
              const SizedBox(height: 24),

              const Text(
                '🇸🇦 خدمة خاصة ومخصصة لشركات ومحلات المملكة العربية السعودية | إحدى خدمات POM Agency | تطوير بواسطة Flutter Web ومستضاف على Vercel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                '© 2026 POM Agency - AD Web Solutions. جميع الحقوق محفوظة.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
