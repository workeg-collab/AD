import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrustStatsSection extends StatelessWidget {
  const TrustStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;

    final stats = [
      {'number': '+500', 'label': 'موقع تم إطلاقه للأنشطة بالمملكة', 'icon': Icons.business_outlined},
      {'number': '6 ساعات', 'label': 'متوسط سرعة التسليم والربط', 'icon': Icons.schedule_rounded},
      {'number': '100%', 'label': 'ضمان الرضا و3 جولات تعديل', 'icon': Icons.verified_user_outlined},
      {'number': '299 ر.س', 'label': 'باقة شاملة بدون أي مصاريف خفية', 'icon': Icons.local_offer_outlined},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 32 : 48,
      ),
      color: isDark ? AppTheme.bgDark : Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              // Metrics Grid
              isMobile
                  ? Column(
                      children: stats.map((stat) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildStatItem(
                            number: stat['number'] as String,
                            label: stat['label'] as String,
                            icon: stat['icon'] as IconData,
                            isDark: isDark,
                            textColor: textColor,
                            isMobile: true,
                          ),
                        );
                      }).toList(),
                    )
                  : Row(
                      children: stats.map((stat) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildStatItem(
                              number: stat['number'] as String,
                              label: stat['label'] as String,
                              icon: stat['icon'] as IconData,
                              isDark: isDark,
                              textColor: textColor,
                              isMobile: false,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String number,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.bgLight,
        borderRadius: AppTheme.radiusMd,
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryContainerDark
                  : AppTheme.primaryContainer,
              borderRadius: AppTheme.radiusSm,
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: isMobile ? 20 : 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    fontSize: isMobile ? 17 : 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 11.5 : 12.5,
                    color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
