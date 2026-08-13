import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
                  // Glowing Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.2),
                          AppTheme.secondary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'تسليم خلال 6 ساعات من الاتفاق + دومين مجاني لسنة كاملة!',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Main Headline
                  Text(
                    'صفحة تعريفية لمنتجاتك وخدماتك\nتزيد مبيعاتك وثقة عملائك بـ 299 ريال فقط!',
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
                      'انقل عملك التجاري، محلك، أو مصنعك إلى العالم الرقمي بدون تكاليف باهظة. احصل على موقع ويب احترافي فائق السرعة، متوافق مع كافة الجوالات، مربوط برقم الواتساب الخاص بك.',
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
                      _buildBenefitChip(context, Icons.domain_rounded, 'دومين مجاني (سنة أولى)', isDark),
                      _buildBenefitChip(context, Icons.timer_outlined, 'استلام خلال 6 ساعات', isDark),
                      _buildBenefitChip(context, Icons.edit_note_rounded, '3 تعديلات مجانية', isDark),
                      _buildBenefitChip(context, Icons.flash_on_rounded, 'مطور بـ Flutter Web', isDark),
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.rocket_launch_rounded, size: 22, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'اطلب موقعك الآن (299 ريال)',
                                  style: TextStyle(
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
                                  'استعرض نماذج القوالب',
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
}
