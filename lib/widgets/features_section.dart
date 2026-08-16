import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;

    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.bolt_rounded,
        'title': AppTranslations.tr('feat_1_title'),
        'desc': AppTranslations.tr('feat_1_desc'),
      },
      {
        'icon': Icons.language_rounded,
        'title': AppTranslations.tr('feat_2_title'),
        'desc': AppTranslations.tr('feat_2_desc'),
      },
      {
        'icon': Icons.published_with_changes_rounded,
        'title': AppTranslations.tr('feat_3_title'),
        'desc': AppTranslations.tr('feat_3_desc'),
      },
      {
        'icon': Icons.speed_rounded,
        'title': AppTranslations.tr('feat_4_title'),
        'desc': AppTranslations.tr('feat_4_desc'),
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'title': AppTranslations.tr('feat_5_title'),
        'desc': AppTranslations.tr('feat_5_desc'),
      },
      {
        'icon': Icons.cloud_done_outlined,
        'title': AppTranslations.tr('feat_6_title'),
        'desc': AppTranslations.tr('feat_6_desc'),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 48 : 80,
      ),
      color: isDark ? AppTheme.surfaceDark : const Color(0xFFF4F6F8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              // Section Header
              Text(
                AppTranslations.tr('feat_title'),
                style: TextStyle(
                  fontSize: isMobile ? 22 : 32,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                AppTranslations.tr('feat_sub'),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 32 : 48),

              // Unified Feature Cards Grid
              if (isMobile)
                Column(
                  children: features.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FeatureCard(
                        item: item,
                        isDark: isDark,
                        isMobile: true,
                      ),
                    );
                  }).toList(),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth < 1024 ? 2 : 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.45,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return _FeatureCard(
                      item: features[index],
                      isDark: isDark,
                      isMobile: false,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final bool isMobile;

  const _FeatureCard({
    required this.item,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: AppTheme.radiusLg,
          border: Border.all(
            color: _isHovered
                ? AppTheme.primary.withValues(alpha: 0.5)
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: 1.0,
          ),
          boxShadow: _isHovered
              ? AppTheme.softShadow(isDark: isDark, elevation: 2)
              : AppTheme.softShadow(isDark: isDark, elevation: 0.5),
        ),
        padding: EdgeInsets.all(widget.isMobile ? 16 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Unified Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryContainerDark
                    : AppTheme.primaryContainer,
                borderRadius: AppTheme.radiusSm,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.item['icon'] as IconData,
                color: AppTheme.primary,
                size: widget.isMobile ? 20 : 24,
              ),
            ),
            const SizedBox(height: 14),

            // Feature Title
            Text(
              widget.item['title'] as String,
              style: TextStyle(
                fontSize: widget.isMobile ? 15 : 16.5,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Feature Description
            Text(
              widget.item['desc'] as String,
              style: TextStyle(
                fontSize: widget.isMobile ? 12.5 : 13.5,
                color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
