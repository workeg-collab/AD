import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import 'domain_search_modal.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onOrderTap;
  final VoidCallback onDemosTap;

  const HeroSection({
    super.key,
    required this.onOrderTap,
    required this.onDemosTap,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 28,
            vertical: isMobile ? 32 : 64,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                children: [
                  // 1. Sleek Top Supporting Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppTranslations.tr('hero_badge'),
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6EE7B7) : AppTheme.primary,
                              fontSize: isSmallMobile ? 11.5 : 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Main Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      AppTranslations.tr('hero_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 24 : (isMobile ? 28 : 44),
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Supporting Description
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      AppTranslations.tr('hero_sub'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 14 : (isMobile ? 15 : 17),
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                        height: 1.65,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 4. Value Pillars / Highlight Badges
                  Wrap(
                    spacing: isMobile ? 8 : 12,
                    runSpacing: isMobile ? 8 : 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPillarChip(
                        context,
                        icon: Icons.language_rounded,
                        label: AppTranslations.tr('chip_domain'),
                        isDark: isDark,
                        isMobile: isMobile,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const DomainSearchModal(),
                          );
                        },
                      ),
                      _buildPillarChip(
                        context,
                        icon: Icons.schedule_rounded,
                        label: AppTranslations.tr('chip_delivery'),
                        isDark: isDark,
                        isMobile: isMobile,
                        isHighlight: true,
                      ),
                      _buildPillarChip(
                        context,
                        icon: Icons.edit_note_rounded,
                        label: AppTranslations.tr('chip_edits'),
                        isDark: isDark,
                        isMobile: isMobile,
                      ),
                      _buildPillarChip(
                        context,
                        icon: Icons.speed_rounded,
                        label: AppTranslations.tr('chip_tech'),
                        isDark: isDark,
                        isMobile: isMobile,
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // 5. Action Buttons (Primary, Domain, Demos)
                  if (isMobile)
                    Column(
                      children: [
                        // Primary Order Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onOrderTap,
                            icon: const Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.white),
                            label: Text(
                              AppTranslations.tr('btn_order'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            style: AppTheme.primaryButtonStyle(isMobile: true),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Free Domain Finder Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const DomainSearchModal(),
                              );
                            },
                            icon: const Icon(Icons.travel_explore_rounded, size: 18, color: AppTheme.primary),
                            label: Text(
                              AppTranslations.tr('btn_choose_domain'),
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primary, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Secondary Demos Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: widget.onDemosTap,
                            icon: Icon(Icons.grid_view_rounded, size: 16, color: textColor),
                            label: Text(
                              AppTranslations.tr('btn_demos'),
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: textColor),
                            ),
                            style: AppTheme.secondaryButtonStyle(isDark: isDark, isMobile: true),
                          ),
                        ),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: [
                        // Primary Order CTA
                        ElevatedButton.icon(
                          onPressed: widget.onOrderTap,
                          icon: const Icon(Icons.rocket_launch_rounded, size: 19, color: Colors.white),
                          label: Text(
                            AppTranslations.tr('btn_order'),
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                            elevation: 0,
                          ),
                        ),

                        // Domain Finder Button
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const DomainSearchModal(),
                            );
                          },
                          icon: const Icon(Icons.travel_explore_rounded, size: 19, color: AppTheme.primary),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppTranslations.tr('btn_choose_domain'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryContainer,
                                  borderRadius: AppTheme.radiusSm,
                                ),
                                child: Text(
                                  AppTranslations.tr('badge_free'),
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                          ),
                        ),

                        // Demos Outlined Button
                        OutlinedButton.icon(
                          onPressed: widget.onDemosTap,
                          icon: Icon(Icons.grid_view_rounded, size: 18, color: textColor),
                          label: Text(
                            AppTranslations.tr('btn_demos'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          style: AppTheme.secondaryButtonStyle(isDark: isDark, isMobile: false),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillarChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    required bool isMobile,
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: isHighlight
            ? (isDark ? AppTheme.primaryContainerDark : AppTheme.primaryContainer)
            : (isDark ? AppTheme.cardDark : Colors.white),
        borderRadius: AppTheme.radiusSm,
        border: Border.all(
          color: isHighlight
              ? AppTheme.primary.withValues(alpha: 0.35)
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
            size: isMobile ? 15 : 18,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13.5,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusSm,
        child: chip,
      );
    }
    return chip;
  }
}
