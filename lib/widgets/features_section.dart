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
    final textColor = theme.textTheme.bodyLarge?.color;

    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFF10B981),
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
        'title': AppTranslations.tr('feat_1_title'),
        'desc': AppTranslations.tr('feat_1_desc'),
      },
      {
        'icon': Icons.language_rounded,
        'color': const Color(0xFF3B82F6),
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
        'title': AppTranslations.tr('feat_2_title'),
        'desc': AppTranslations.tr('feat_2_desc'),
      },
      {
        'icon': Icons.published_with_changes_rounded,
        'color': const Color(0xFFF59E0B),
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        'title': AppTranslations.tr('feat_3_title'),
        'desc': AppTranslations.tr('feat_3_desc'),
      },
      {
        'icon': Icons.flash_on_rounded,
        'color': const Color(0xFF8B5CF6),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
        'title': AppTranslations.tr('feat_4_title'),
        'desc': AppTranslations.tr('feat_4_desc'),
      },
      {
        'icon': Icons.chat_outlined,
        'color': const Color(0xFF25D366),
        'gradient': [const Color(0xFF25D366), const Color(0xFF16A34A)],
        'title': AppTranslations.tr('feat_5_title'),
        'desc': AppTranslations.tr('feat_5_desc'),
      },
      {
        'icon': Icons.cloud_done_rounded,
        'color': const Color(0xFFEC4899),
        'gradient': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
        'title': AppTranslations.tr('feat_6_title'),
        'desc': AppTranslations.tr('feat_6_desc'),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14 : 24,
        vertical: isMobile ? 40 : 70,
      ),
      color: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                AppTranslations.tr('feat_title'),
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                AppTranslations.tr('feat_sub'),
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 24 : 48),

              // Responsive Layout: Column on mobile (never truncates) vs GridView on desktop
              if (isMobile)
                Column(
                  children: features.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _AnimatedFeatureCard(
                        item: item,
                        textColor: textColor,
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
                    childAspectRatio: 1.35,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    return _AnimatedFeatureCard(
                      item: features[index],
                      textColor: textColor,
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

class _AnimatedFeatureCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final Color? textColor;
  final bool isDark;
  final bool isMobile;

  const _AnimatedFeatureCard({
    required this.item,
    required this.textColor,
    required this.isDark,
    required this.isMobile,
  });

  @override
  State<_AnimatedFeatureCard> createState() => _AnimatedFeatureCardState();
}

class _AnimatedFeatureCardState extends State<_AnimatedFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item['color'] as Color;
    final gradient = widget.item['gradient'] as List<Color>;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered ? color : (widget.isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered ? color.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.isMobile ? 18 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(widget.isMobile ? 10 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isHovered
                            ? gradient
                            : [color.withValues(alpha: 0.15), color.withValues(alpha: 0.08)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      widget.item['icon'] as IconData,
                      color: _isHovered ? Colors.white : color,
                      size: widget.isMobile ? 22 : 28,
                    ),
                  ),
                  if (widget.isMobile) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.item['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.textColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (!widget.isMobile) ...[
                const SizedBox(height: 16),
                Text(
                  widget.item['title'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                widget.item['desc'] as String,
                style: TextStyle(
                  fontSize: widget.isMobile ? 13 : 14,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
