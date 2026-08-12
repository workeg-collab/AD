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
                  // Brand
                  const Row(
                    children: [
                      Icon(Icons.rocket_launch_rounded, color: AppTheme.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'AD Web Solutions',
                        style: TextStyle(
                          fontSize: 18,
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
                '🇸🇦 خدمة خاصة ومخصصة لشركات ومحلات المملكة العربية السعودية | تطوير بواسطة Flutter Web ومستضاف على Vercel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                '© 2026 AD Web Solutions. جميع الحقوق محفوظة.',
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
