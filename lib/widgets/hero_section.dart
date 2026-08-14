import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../utils/app_translations.dart';

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

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _timerWiggleController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isOrderHovered = false;
  bool _isDemosHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _timerWiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _timerWiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isMobile ? 40 : 80,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  // Prominent Animated Glowing 6-Hour Badge
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseController, _timerWiggleController]),
                    builder: (context, child) {
                      final pulseVal = _pulseController.value;
                      final wiggleVal = math.sin(_timerWiggleController.value * 2 * math.pi);

                      return Transform.scale(
                        scale: 1.0 + (pulseVal * 0.03),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 14 : 20,
                            vertical: isMobile ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                                      const Color(0xFF312E81).withValues(alpha: 0.8),
                                      const Color(0xFF065F46).withValues(alpha: 0.7),
                                    ]
                                  : [
                                      const Color(0xFFEEF2FF),
                                      const Color(0xFFE0E7FF),
                                      const Color(0xFFD1FAE5),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.6 + (pulseVal * 0.4)),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.25 + (pulseVal * 0.3)),
                                blurRadius: 18 + (pulseVal * 10),
                                spreadRadius: 1 + (pulseVal * 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated Energetic Ticking Timer & Lightning Icon
                              Transform.rotate(
                                angle: wiggleVal * 0.22,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.timer_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                AppTranslations.tr('hero_badge'),
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Glowing Live Radar Dot
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.6 + (pulseVal * 0.4)),
                                      blurRadius: 8 + (pulseVal * 4),
                                      spreadRadius: 1 + (pulseVal * 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Main Headline
                  Text(
                    AppTranslations.tr('hero_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 26 : 46,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 750),
                    child: Text(
                      AppTranslations.tr('hero_sub'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 18,
                        color: AppTheme.textMuted,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Highlight Cards / Benefits
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBenefitChip(context, Icons.domain_rounded, AppTranslations.tr('chip_domain'), isDark),
                      _buildAnimatedDeliveryChip(context, isDark),
                      _buildBenefitChip(context, Icons.edit_note_rounded, AppTranslations.tr('chip_edits'), isDark),
                      _buildBenefitChip(context, Icons.flash_on_rounded, AppTranslations.tr('chip_tech'), isDark),
                    ],
                  ),

                  const SizedBox(height: 44),

                  // Interactive 3D Call to Action Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      // Primary Animated Button
                      MouseRegion(
                        onEnter: (_) => setState(() => _isOrderHovered = true),
                        onExit: (_) => setState(() => _isOrderHovered = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          transform: Matrix4.translationValues(0, _isOrderHovered ? -3 : 0, 0),
                          child: ElevatedButton(
                            onPressed: widget.onOrderTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              elevation: _isOrderHovered ? 12 : 4,
                              shadowColor: AppTheme.primary.withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.rocket_launch_rounded, size: 22, color: Colors.white),
                                const SizedBox(width: 10),
                                Text(
                                  AppTranslations.tr('btn_order'),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Secondary Animated Button
                      MouseRegion(
                        onEnter: (_) => setState(() => _isDemosHovered = true),
                        onExit: (_) => setState(() => _isDemosHovered = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          transform: Matrix4.translationValues(0, _isDemosHovered ? -3 : 0, 0),
                          child: OutlinedButton(
                            onPressed: widget.onDemosTap,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _isDemosHovered ? AppTheme.primary : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: 20,
                                  color: _isDemosHovered ? AppTheme.primary : textColor,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppTranslations.tr('btn_demos'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isDemosHovered ? AppTheme.primary : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildBenefitChip(BuildContext context, IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDeliveryChip(BuildContext context, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _timerWiggleController]),
      builder: (context, child) {
        final pulseVal = _pulseController.value;
        final wiggleVal = math.sin(_timerWiggleController.value * 2 * math.pi);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFFFFBEB),
                      Colors.white,
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.7 + (pulseVal * 0.3)),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2 + (pulseVal * 0.2)),
                blurRadius: 10 + (pulseVal * 6),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: wiggleVal * 0.25,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppTranslations.tr('chip_delivery'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
