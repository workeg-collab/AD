import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShapePreviewWidget extends StatelessWidget {
  final String variantId;
  final Color themeColor;

  const ShapePreviewWidget({
    super.key,
    required this.variantId,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : Colors.white;
    final textMain = isDark ? Colors.white : AppTheme.textDark;
    final borderCol = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? themeColor.withValues(alpha: 0.3) : AppTheme.borderLight,
          width: 1.5,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Column(
        children: [
          // Browser Top Bar Mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black38 : Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: borderCol)),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lock_rounded, size: 12, color: themeColor),
                            const SizedBox(width: 6),
                            Text(
                              'https://pomagencyonline.com/$variantId',
                              style: TextStyle(fontSize: 11, color: isDark ? AppTheme.textMuted : AppTheme.textDark),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'معاينة حية',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDark ? themeColor : AppTheme.primaryDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Shape Layout Preview Area
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildLayoutForVariant(context, isDark, cardBg, textMain, borderCol),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutForVariant(BuildContext context, bool isDark, Color cardBg, Color textMain, Color borderCol) {
    switch (variantId) {
      // --- Retail Variants ---
      case 'retail-modern':
        return _buildRetailModern(isDark, cardBg, textMain, borderCol);
      case 'retail-grid':
        return _buildRetailGrid(isDark, cardBg, textMain, borderCol);
      case 'retail-express':
        return _buildRetailExpress(isDark, cardBg, textMain, borderCol);
      case 'retail-luxury':
        return _buildRetailLuxury(isDark, cardBg, textMain, borderCol);

      // --- Corporate Variants ---
      case 'corp-classic':
        return _buildCorpClassic(isDark, cardBg, textMain, borderCol);
      case 'corp-industrial':
        return _buildCorpIndustrial(isDark, cardBg, textMain, borderCol);
      case 'corp-tech':
        return _buildCorpTech(isDark, cardBg, textMain, borderCol);
      case 'corp-express':
        return _buildCorpExpress(isDark, cardBg, textMain, borderCol);

      // --- Services Variants ---
      case 'serv-advisory':
        return _buildServAdvisory(isDark, cardBg, textMain, borderCol);
      case 'serv-portfolio':
        return _buildServPortfolio(isDark, cardBg, textMain, borderCol);
      case 'serv-quick':
        return _buildServQuick(isDark, cardBg, textMain, borderCol);
      case 'serv-branding':
        return _buildServBranding(isDark, cardBg, textMain, borderCol);

      // --- Cafe Variants ---
      case 'cafe-smart':
        return _buildCafeSmart(isDark, cardBg, textMain, borderCol);
      case 'cafe-lounge':
        return _buildCafeLounge(isDark, cardBg, textMain, borderCol);
      case 'cafe-fastfood':
        return _buildCafeFastfood(isDark, cardBg, textMain, borderCol);
      case 'cafe-bakery':
        return _buildCafeBakery(isDark, cardBg, textMain, borderCol);

      default:
        return _buildDefaultPreview(textMain);
    }
  }

  // 1. Retail Modern
  Widget _buildRetailModern(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        // Mini Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [themeColor.withValues(alpha: 0.25), Colors.black26]
                  : [themeColor.withValues(alpha: 0.15), Colors.grey.shade100],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تشكيلة الصيف الجديدة ✨', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? themeColor : AppTheme.primaryDark, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('خصم 20% لفترة محدودة على جميع المنتجات', style: TextStyle(color: textMain, fontSize: 11)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  minimumSize: const Size(80, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text('تصفح الآن', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Product Scroll Row
        Row(
          children: List.generate(3, (i) {
            final names = ['عطر اللافندر', 'ساعة كلاسيك', 'حقيبة جلدية'];
            final prices = ['199 ريال', '350 ريال', '280 ريال'];
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == 2 ? 0 : 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(child: Icon(Icons.shopping_bag, color: themeColor, size: 24)),
                    ),
                    const SizedBox(height: 6),
                    Text(names[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain)),
                    Text(prices[i], style: TextStyle(fontSize: 10, color: isDark ? themeColor : AppTheme.primaryDark, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, color: Color(0xFF25D366), size: 10),
                          SizedBox(width: 4),
                          Text('طلب واتساب', style: TextStyle(fontSize: 9, color: Color(0xFF25D366), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 2. Retail Grid
  Widget _buildRetailGrid(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['الكل', 'الرجال', 'النساء', 'العروض'].map((cat) {
            final isFirst = cat == 'الكل';
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isFirst ? (isDark ? themeColor : AppTheme.primaryDark) : cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Text(cat, style: TextStyle(fontSize: 10, color: isFirst ? Colors.white : textMain, fontWeight: FontWeight.bold)),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(4, (i) {
            return Container(
              width: 140,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Icon(Icons.inventory_2_rounded, color: themeColor, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('منتج ${i + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMain)),
                        Text('${(i + 1) * 75} ريال', style: TextStyle(fontSize: 9, color: isDark ? themeColor : AppTheme.primaryDark)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // 3. Retail Express
  Widget _buildRetailExpress(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.flash_on_rounded, color: themeColor, size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('العرض البطل السريع ⚡', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textMain)),
                    const SizedBox(height: 4),
                    const Text('صفحة هبوط فائقة السرعة لتحويل الحملات الإعلانية لمبيعات مباشرة', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    const SizedBox(height: 6),
                    Text('السعر الحصري: 149 ريال', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? themeColor : AppTheme.primaryDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('اشترِ الآن بنقرة واحدة عبر الواتساب', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Retail Luxury
  Widget _buildRetailLuxury(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1F1C18), const Color(0xFF0D0D0D)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFFF7ED)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? themeColor : AppTheme.accentGold, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.diamond_outlined, color: isDark ? themeColor : AppTheme.accentGold, size: 36),
          const SizedBox(height: 8),
          Text('ROYAL LUXURY COLLECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: isDark ? themeColor : AppTheme.accentGold)),
          const SizedBox(height: 6),
          Text('فخامة لا تضاهى وتصاميم مذهبة حصرية لماركتك الفاخرة', style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : AppTheme.textDark), textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? themeColor : AppTheme.accentGold),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text('حجز تشكيلة النخبة 💎', style: TextStyle(color: isDark ? themeColor : AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. Corporate Classic
  Widget _buildCorpClassic(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.business_rounded, color: themeColor, size: 20),
                const SizedBox(width: 6),
                Text('شركة الأفق السعودية', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textMain)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
              child: Text('تحميل الكتالوج PDF 📄', style: TextStyle(fontSize: 9, color: isDark ? themeColor : AppTheme.primaryDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _buildStatCard('+15 سنة خبرة', themeColor, cardBg, borderCol),
            const SizedBox(width: 8),
            _buildStatCard('+500 مشروع', themeColor, cardBg, borderCol),
            const SizedBox(width: 8),
            _buildStatCard('اعتماد ISO', themeColor, cardBg, borderCol),
          ],
        ),
      ],
    );
  }

  // 6. Corporate Industrial
  Widget _buildCorpIndustrial(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.precision_manufacturing_rounded, color: themeColor, size: 24),
              const SizedBox(width: 8),
              Text('خطوط الإنتاج والتصنيع الفولاذي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textMain)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isDark ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الطاقة الإنتاجية اليومية:', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                Text('50,000 طن / يومياً', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? themeColor : AppTheme.primaryDark)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(6)),
                  child: const Center(child: Text('طلب توريد بالجملة 🏭', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 7. Corporate Tech
  Widget _buildCorpTech(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: themeColor, size: 20),
              const SizedBox(width: 8),
              Text('منظومة الذكاء وحلول Enterprise', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMain)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTechMetric('99.9%', 'حماية السحابة', themeColor),
              _buildTechMetric('< 10ms', 'زمن الاستجابة', themeColor),
              _buildTechMetric('24/7', 'دعم فوري', themeColor),
            ],
          ),
        ],
      ),
    );
  }

  // 8. Corporate Express Profile
  Widget _buildCorpExpress(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: themeColor.withValues(alpha: 0.2),
            radius: 24,
            child: Icon(Icons.verified_user_rounded, color: themeColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('شركة البناء والتطوير KSA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textMain)),
                const SizedBox(height: 2),
                const Text('سجل تجاري: 1010XXXXXX | موثق معروف', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_in_talk, size: 10, color: isDark ? themeColor : AppTheme.primaryDark),
                    const SizedBox(width: 4),
                    Text('اتصال مباشر بمسؤول المبيعات', style: TextStyle(fontSize: 9, color: isDark ? themeColor : AppTheme.primaryDark, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 9. Services Advisory
  Widget _buildServAdvisory(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: themeColor.withValues(alpha: 0.2),
              child: Icon(Icons.gavel_rounded, color: themeColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مكتب المستشار م. الخالد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textMain)),
                  const Text('استشارات قانونية وهندسية مرخصة', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderCol)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('حجز استشارة (30 دقيقة):', style: TextStyle(fontSize: 10, color: textMain)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(6)),
                child: const Text('احجز موعدك 📅', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 10. Services Portfolio
  Widget _buildServPortfolio(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('معرض التصميم الداخلي والديكور', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain)),
            Text('قبل / بعد 📐', style: TextStyle(fontSize: 10, color: isDark ? themeColor : AppTheme.primaryDark, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('المشروع 1 (فيلا مودرن)', style: TextStyle(fontSize: 9, color: textMain))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: themeColor)),
                child: Center(child: Text('المشروع 2 (مكتب نيوكلاسيك)', style: TextStyle(fontSize: 9, color: isDark ? themeColor : AppTheme.primaryDark, fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 11. Services Quick
  Widget _buildServQuick(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: themeColor)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.build_circle_rounded, color: themeColor, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مركز الصيانة الفورية والطوارئ 🚨', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain)),
                    const Text('وصول الفني خلال 30 دقيقة في الرياض', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(6)),
            child: const Center(child: Text('طلب الفني الفوري الآن 📞', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
          ),
        ],
      ),
    );
  }

  // 12. Services Branding
  Widget _buildServBranding(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeColor.withValues(alpha: 0.2),
            border: Border.all(color: themeColor, width: 1.5),
          ),
          child: Icon(Icons.person_pin_rounded, color: themeColor, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('د. عبدالسلام | خبير التسويق الرقمي', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain)),
              const Text('مؤلف وصانع محتوى ريادة الأعمال', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              Row(
                children: ['تويتر', 'لينكد إن', 'يوتيوب'].map((soc) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                    child: Text(soc, style: TextStyle(fontSize: 8, color: textMain)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 13. Cafe Smart Menu
  Widget _buildCafeSmart(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_scanner_rounded, color: themeColor, size: 20),
                const SizedBox(width: 6),
                Text('المنيو الإلكتروني الذكي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textMain)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: Text('QR Code 📱', style: TextStyle(fontSize: 9, color: isDark ? themeColor : AppTheme.primaryDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (i) {
            final items = ['سبانيش لاتيه', 'كيك الشوكولاتة', 'فلات وايت'];
            final prices = ['22 ريال', '28 ريال', '18 ريال'];
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == 2 ? 0 : 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderCol)),
                child: Column(
                  children: [
                    Icon(Icons.local_cafe_rounded, color: themeColor, size: 18),
                    const SizedBox(height: 4),
                    Text(items[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textMain)),
                    Text(prices[i], style: TextStyle(fontSize: 8, color: isDark ? themeColor : AppTheme.primaryDark, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 14. Cafe Lounge
  Widget _buildCafeLounge(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF140D1B) : const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.wine_bar_rounded, color: themeColor, size: 30),
          const SizedBox(height: 6),
          Text('BLACK VELVET LOUNGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          const Text('حجز الجلسات الفاخرة والطاولات الملكية', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(20)),
            child: const Text('احجز طاولتك الآن 🥂', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 15. Cafe Fastfood
  Widget _buildCafeFastfood(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: themeColor)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lunch_dining_rounded, color: themeColor, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('وجبة الكومبو العائلية 🍔🍟', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain)),
                    const Text('خصم 30% عند الطلب عبر التطبيق أو الواتساب', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Text('49 ريال', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? themeColor : AppTheme.primaryDark)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['هنقرستيشن', 'جاهز', 'تويو', 'توصيل واتساب'].map((app) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                child: Text(app, style: TextStyle(fontSize: 8, color: textMain)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 16. Cafe Bakery
  Widget _buildCafeBakery(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.cake_rounded, color: themeColor, size: 22),
            const SizedBox(width: 8),
            Text('مخبوزات وكيك المناسبات 🎂', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderCol)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تصميم تورتة حسب الطلب', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textMain)),
                  const Text('اختر الحجم، النكهة، والنص المكتوب', style: TextStyle(fontSize: 8, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(6)),
                child: const Text('صمم كيكتك 🍰', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, Color color, Color cardBg, Color borderCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: borderCol)),
        child: Center(child: Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color))),
      ),
    );
  }

  Widget _buildTechMetric(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 8, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildDefaultPreview(Color textMain) {
    return Center(
      child: Text('معاينة حية وتفاعلية لـ $variantId', style: TextStyle(color: textMain)),
    );
  }
}
