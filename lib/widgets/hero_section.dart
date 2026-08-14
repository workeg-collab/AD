import 'dart:math' as math;
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

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _pulseController;
  late AnimationController _timerWiggleController;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isOrderHovered = false;
  bool _isDemosHovered = false;
  bool _isDomainHovered = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _timerWiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
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
    _pulseController.dispose();
    _timerWiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 420;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 24 : 70,
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
                        scale: 1.0 + (pulseVal * 0.02),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 20,
                            vertical: isMobile ? 7 : 10,
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
                                blurRadius: 16 + (pulseVal * 8),
                                spreadRadius: 1 + (pulseVal * 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated Energetic Ticking Timer
                              Transform.rotate(
                                angle: wiggleVal * 0.22,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.timer_rounded,
                                    color: Colors.white,
                                    size: isMobile ? 15 : 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  AppTranslations.tr('hero_badge'),
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                                    fontSize: isSmallMobile ? 11 : (isMobile ? 12 : 14),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Glowing Live Radar Dot
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF10B981),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.6 + (pulseVal * 0.4)),
                                      blurRadius: 6 + (pulseVal * 4),
                                      spreadRadius: 1,
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

                  const SizedBox(height: 18),

                  // Main Headline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      AppTranslations.tr('hero_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 22 : (isMobile ? 26 : 46),
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                        color: textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 750),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        AppTranslations.tr('hero_sub'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallMobile ? 13.5 : (isMobile ? 15 : 18),
                          color: AppTheme.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Highlight Cards / Benefits
                  Wrap(
                    spacing: isMobile ? 8 : 16,
                    runSpacing: isMobile ? 8 : 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBenefitChip(
                        context,
                        Icons.domain_rounded,
                        AppTranslations.tr('chip_domain'),
                        isDark,
                        isMobile: isMobile,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const DomainSearchModal(),
                          );
                        },
                      ),
                      _buildAnimatedDeliveryChip(context, isDark, isMobile: isMobile),
                      _buildBenefitChip(
                        context,
                        Icons.edit_note_rounded,
                        AppTranslations.tr('chip_edits'),
                        isDark,
                        isMobile: isMobile,
                      ),
                      _buildBenefitChip(
                        context,
                        Icons.flash_on_rounded,
                        AppTranslations.tr('chip_tech'),
                        isDark,
                        isMobile: isMobile,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Interactive 3D Call to Action Buttons
                  if (isMobile)
                    Column(
                      children: [
                        // Primary Order Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onOrderTap,
                            icon: const Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.white),
                            label: Text(
                              AppTranslations.tr('btn_order'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 6,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Domain Search Button
                        _buildDomainSearchButton(isMobile: true),

                        const SizedBox(height: 12),

                        // Secondary Demos Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: widget.onDemosTap,
                            icon: Icon(Icons.grid_view_rounded, size: 18, color: textColor),
                            label: Text(
                              AppTranslations.tr('btn_demos'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
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
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Domain Search Button
                        _buildDomainSearchButton(isMobile: false),

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

  Widget _buildDomainSearchButton({required bool isMobile}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _timerWiggleController]),
      builder: (context, child) {
        final wiggleVal = math.sin(_timerWiggleController.value * 2 * math.pi);
        final pulseVal = _pulseController.value;

        final buttonContent = Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF0D9488)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF34D399).withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: _isDomainHovered ? 0.6 : (0.3 + pulseVal * 0.2)),
                blurRadius: _isDomainHovered ? 20 : (12 + pulseVal * 6),
                spreadRadius: _isDomainHovered ? 2 : (pulseVal * 2),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const DomainSearchModal(),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 14 : 19,
                ),
                child: Row(
                  mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                  mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: wiggleVal * 0.22,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.travel_explore_rounded,
                          size: isMobile ? 18 : 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'اختار اسم موقعك الآن 🌐',
                      style: TextStyle(
                        fontSize: isMobile ? 14.5 : 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'مجاناً',
                        style: TextStyle(
                          color: Color(0xFF78350F),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (isMobile) {
          return SizedBox(
            width: double.infinity,
            child: buttonContent,
          );
        }

        return MouseRegion(
          onEnter: (_) => setState(() => _isDomainHovered = true),
          onExit: (_) => setState(() => _isDomainHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(0, _isDomainHovered ? -4 : 0, 0),
            child: buttonContent,
          ),
        );
      },
    );
  }

  Widget _buildBenefitChip(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark, {
    required bool isMobile,
    VoidCallback? onTap,
  }) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 14,
        vertical: isMobile ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: isMobile ? 15 : 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 11.5 : 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: chip,
        ),
      );
    }
    return chip;
  }

  Widget _buildAnimatedDeliveryChip(BuildContext context, bool isDark, {required bool isMobile}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _timerWiggleController]),
      builder: (context, child) {
        final pulseVal = _pulseController.value;
        final wiggleVal = math.sin(_timerWiggleController.value * 2 * math.pi);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 15,
            vertical: isMobile ? 7 : 10,
          ),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.7 + (pulseVal * 0.3)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.2 + (pulseVal * 0.2)),
                blurRadius: 8 + (pulseVal * 4),
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
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timer_rounded,
                    color: Colors.white,
                    size: isMobile ? 13 : 15,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppTranslations.tr('chip_delivery'),
                style: TextStyle(
                  fontSize: isMobile ? 11.5 : 13,
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
