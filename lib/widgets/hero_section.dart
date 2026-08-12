import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onOrderTap;
  final VoidCallback onDemosTap;

  const HeroSection({
    super.key,
    required this.onOrderTap,
    required this.onDemosTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isMobile ? 40 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'تسليم خلال 6 ساعات من الاتفاق + دومين مجاني لسنة كاملة!',
                      style: TextStyle(
                        color: AppTheme.primary,
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
                  color: AppTheme.textWhite,
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
                  _buildBenefitChip(Icons.domain_rounded, 'دومين مجاني (سنة أولى)'),
                  _buildBenefitChip(Icons.timer_outlined, 'استلام خلال 6 ساعات'),
                  _buildBenefitChip(Icons.edit_note_rounded, '3 تعديلات مجانية'),
                  _buildBenefitChip(Icons.flash_on_rounded, 'مطور بـ Flutter Web'),
                ],
              ),

              const SizedBox(height: 40),

              // CTA Buttons
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onOrderTap,
                    icon: const Icon(Icons.chat_bubble_rounded, size: 22),
                    label: const Text('احجز موقعك الآن (299 ريال)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onDemosTap,
                    icon: const Icon(Icons.visibility_rounded, size: 20),
                    label: const Text('معاينة أمثلة الأنشطة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Guarantee Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppTheme.accentGold, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'ضمان المعاينة قبل الاعتماد التام + دعم فوري على الواتساب',
                    style: TextStyle(
                      color: AppTheme.textMuted.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.secondary, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
