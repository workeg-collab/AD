import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/whatsapp_helper.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark, width: 1),
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.black,
                      size: 24,
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
                            'AD',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.2),
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
                        'حلول ويب سريعة للشركات',
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
                      child: const Text(
                        'المميزات والضمان',
                        style: TextStyle(color: AppTheme.textWhite, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: onDemosTap,
                      child: const Text(
                        'قوالب المعاينة',
                        style: TextStyle(color: AppTheme.textWhite, fontSize: 15),
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
        ),
      ),
    );
  }
}
