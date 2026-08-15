import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShapePreviewWidget extends StatefulWidget {
  final String variantId;
  final Color themeColor;

  const ShapePreviewWidget({
    super.key,
    required this.variantId,
    required this.themeColor,
  });

  @override
  State<ShapePreviewWidget> createState() => _ShapePreviewWidgetState();
}

class _ShapePreviewWidgetState extends State<ShapePreviewWidget> {
  bool _isMobileView = false;

  Widget _buildNetworkImage(String url, {double? height, double? width, BorderRadius? borderRadius, BoxFit fit = BoxFit.cover}) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: widget.themeColor.withValues(alpha: 0.1),
              borderRadius: borderRadius ?? BorderRadius.circular(10),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.themeColor,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.themeColor.withValues(alpha: 0.2), Colors.black26],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.image_rounded, color: widget.themeColor, size: 28),
            ),
          );
        },
      ),
    );
  }

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
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? widget.themeColor.withValues(alpha: 0.35) : AppTheme.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Browser / Device Controller Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
              border: Border(bottom: BorderSide(color: borderCol)),
            ),
            child: Row(
              children: [
                // Traffic light dots
                Row(
                  children: [
                    Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(width: 14),

                // URL Address Pill
                Expanded(
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_rounded, size: 12, color: widget.themeColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'https://pom-agency.online/${widget.variantId}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppTheme.textMuted : AppTheme.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.themeColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'معاينة حية ⚡',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: widget.themeColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Responsive View Toggle (Desktop 💻 vs Mobile 📱)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _isMobileView = false),
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: !_isMobileView ? widget.themeColor.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(9)),
                          ),
                          child: Icon(Icons.laptop_chromebook_rounded, size: 16, color: !_isMobileView ? widget.themeColor : AppTheme.textMuted),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _isMobileView = true),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isMobileView ? widget.themeColor.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                          ),
                          child: Icon(Icons.smartphone_rounded, size: 16, color: _isMobileView ? widget.themeColor : AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Preview Canvas Area
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isMobileView ? 12 : 20,
              vertical: 20,
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: BoxConstraints(
                  maxWidth: _isMobileView ? 380 : double.infinity,
                ),
                decoration: _isMobileView
                    ? BoxDecoration(
                        color: isDark ? const Color(0xFF020617) : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: widget.themeColor.withValues(alpha: 0.5), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      )
                    : null,
                padding: _isMobileView ? const EdgeInsets.all(12) : EdgeInsets.zero,
                child: _buildLayoutForVariant(context, isDark, cardBg, textMain, borderCol),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutForVariant(BuildContext context, bool isDark, Color cardBg, Color textMain, Color borderCol) {
    switch (widget.variantId) {
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
        return _buildRetailModern(isDark, cardBg, textMain, borderCol);
    }
  }

  // =========================================================================
  // 1. RETAIL & E-COMMERCE VARIANTS
  // =========================================================================

  // 1.1 Retail Modern (المتجر الحديث والمودرن)
  Widget _buildRetailModern(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Promo Banner
        Stack(
          children: [
            _buildNetworkImage(
              'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=800&q=80',
              height: 140,
              width: double.infinity,
              borderRadius: BorderRadius.circular(14),
            ),
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.85), Colors.black.withValues(alpha: 0.3)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.themeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('تشكيلة العطور الملكية 👑', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  const Text('عطور شرقية فاخرة وثبات يدوم طويلاً', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('توصيل فوري لجميع مدن المملكة 🇸🇦', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الأكثر مبيعاً وطلباً 🔥', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textMain)),
            Text('عرض الكل (18)', style: TextStyle(fontSize: 11, color: widget.themeColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),

        // Product Cards Row
        Row(
          children: [
            Expanded(
              child: _buildProductCard(
                image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80',
                title: 'ساعة سويسرية كلاسيك',
                price: '280 ر.س',
                originalPrice: '350 ر.س',
                rating: '4.9 ⭐',
                cardBg: cardBg,
                textMain: textMain,
                borderCol: borderCol,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildProductCard(
                image: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80',
                title: 'حقيبة جلد طبيعي فاخرة',
                price: '199 ر.س',
                originalPrice: '260 ر.س',
                rating: '4.8 ⭐',
                cardBg: cardBg,
                textMain: textMain,
                borderCol: borderCol,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 1.2 Retail Grid (المعرض الشبكي الديناميكي)
  Widget _buildRetailGrid(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        // Category Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['✨ كل التشكيلة', '👗 عبايات راقية', '💎 مجوهرات وساعات', '👠 أحذية فاخرة'].map((cat) {
              final isFirst = cat.startsWith('✨');
              return Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isFirst ? widget.themeColor : cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isFirst ? widget.themeColor : borderCol),
                ),
                child: Text(
                  cat,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isFirst ? Colors.black : textMain),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // 4-Item Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.82,
          children: [
            _buildProductCard(
              image: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&q=80',
              title: 'عباية مخمل حريرية',
              price: '320 ر.س',
              rating: '5.0 ⭐',
              cardBg: cardBg,
              textMain: textMain,
              borderCol: borderCol,
            ),
            _buildProductCard(
              image: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&q=80',
              title: 'عقد ذهب عيار 21',
              price: '890 ر.س',
              rating: '4.9 ⭐',
              cardBg: cardBg,
              textMain: textMain,
              borderCol: borderCol,
            ),
            _buildProductCard(
              image: 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=600&q=80',
              title: 'نظارة شمسية بولارايزد',
              price: '160 ر.س',
              rating: '4.7 ⭐',
              cardBg: cardBg,
              textMain: textMain,
              borderCol: borderCol,
            ),
            _buildProductCard(
              image: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=600&q=80',
              title: 'حذاء كلاسيك جلد إيطالي',
              price: '240 ر.س',
              rating: '4.9 ⭐',
              cardBg: cardBg,
              textMain: textMain,
              borderCol: borderCol,
            ),
          ],
        ),
      ],
    );
  }

  // 1.3 Retail Express (الكتالوج السريع البسيط)
  Widget _buildRetailExpress(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.themeColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNetworkImage(
                    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('🔥 خصم 40% لفترة محدودة', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        Text('سماعات Pro عازلة للضوضاء', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textMain)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('299 ر.س', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: widget.themeColor)),
                            const SizedBox(width: 8),
                            const Text('499 ر.س', style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Timer countdown simulation
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, color: Color(0xFFEF4444), size: 14),
                    SizedBox(width: 6),
                    Text('ينتهي العرض الخاص خلال: 05:42:19 ⏳', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.black),
                  label: const Text('اطلب الآن بالواتساب مع الشحن المجاني 🚀', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 1.4 Retail Luxury (الهوية الفاخرة والعصرية)
  Widget _buildRetailLuxury(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F19),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
              const SizedBox(width: 6),
              Text(
                'L U X U R Y   C O L L E C T I O N',
                style: TextStyle(color: const Color(0xFFFFD700), fontSize: 10.5, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 14),
            ],
          ),
          const SizedBox(height: 12),
          _buildNetworkImage(
            'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&q=80',
            height: 130,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 12),
          const Text('مجموعة المجوهرات الملكية والذهب', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('تصاميم حصرية مصنوعة يدوياً بأعلى معايير النقاء والفخامة', style: TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('حجز موعد في صالة العرض الخاصة 💎', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. CORPORATE & FACTORIES VARIANTS (المصانع والشركات)
  // =========================================================================

  // 2.1 Corporate Classic (الهوية المؤسسية الرسمية)
  Widget _buildCorpClassic(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Stack(
          children: [
            _buildNetworkImage(
              'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80',
              height: 120,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomRight,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مجموعة الرواد القابضة 🏢', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('ريادة الأعمال والاستثمار المستدام في المملكة', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox('15+ عاماً', 'خبرة وموثوقية', widget.themeColor, cardBg, textMain, borderCol),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricBox('500+ مشروع', 'تم تنفيذه بنجاح', widget.themeColor, cardBg, textMain, borderCol),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricBox('ISO 9001', 'شهادة جودة عالمية', widget.themeColor, cardBg, textMain, borderCol),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.themeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.themeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: widget.themeColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text('تحميل البروفايل المؤسسي 2026 (PDF)', style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              Icon(Icons.download_rounded, color: widget.themeColor, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  // 2.2 Corporate Industrial (العرض الصناعي واللوجستي)
  Widget _buildCorpIndustrial(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNetworkImage(
                'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=600&q=80',
                height: 100,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNetworkImage(
                'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600&q=80',
                height: 100,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('مصنع الأمل للصناعات الحديثة 🏭', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: textMain)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: widget.themeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text('توريد جملة B2B', style: TextStyle(color: widget.themeColor, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('طاقة إنتاجية تتجاوز 100,000 طن سنوياً بأحدث خطوط الإنتاج الألمانية المؤتمتة.', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.request_quote_rounded, size: 14, color: Colors.white),
                  label: const Text('طلب عرض سعر وتوريد كميات 📋', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3D00),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2.3 Corporate Tech (النمط التكنولوجي والمؤسسي)
  Widget _buildCorpTech(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF651FFF).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF651FFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.code_rounded, color: Color(0xFF7C4DFF), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('حلول الذكاء الاصطناعي والحوسبة السحابية 🚀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    Text('أنظمة ERP وحلول أتمتة الشركات', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNetworkImage(
            'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',
            height: 90,
            width: double.infinity,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('⚡ سرعة 99.9%', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10.5, fontWeight: FontWeight.bold)),
              Text('🔒 أمان سحابي مشفر', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10.5, fontWeight: FontWeight.bold)),
              Text('📊 لوحة تحكم ذكية', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10.5, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // 2.4 Corporate Express (البروفايل السريع للشركة)
  Widget _buildCorpExpress(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildNetworkImage(
                'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&q=80',
                width: 65,
                height: 65,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('شركة الأفق للاستشارات 🏛️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textMain)),
                    const SizedBox(height: 3),
                    Text('سجل تجاري: 1010******', style: TextStyle(fontSize: 10.5, color: isDark ? Colors.grey : Colors.grey.shade600)),
                    const SizedBox(height: 3),
                    const Text('📍 الرياض - طريق الملك فهد', style: TextStyle(fontSize: 10.5, color: Colors.blueAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble, color: Color(0xFF25D366), size: 14),
                      SizedBox(width: 4),
                      Text('واتساب المبيعات', style: TextStyle(color: Color(0xFF25D366), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, color: Colors.blue, size: 14),
                      SizedBox(width: 4),
                      Text('اتصال مباشر', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. SERVICES & CONSULTING VARIANTS (المهن والاستشارات)
  // =========================================================================

  // 3.1 Services Advisory (حجز الاستشارات التنفيذية)
  Widget _buildServAdvisory(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Stack(
          children: [
            _buildNetworkImage(
              'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&q=80',
              height: 120,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
              padding: const EdgeInsets.all(14),
              alignment: Alignment.centerRight,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('المحامي والمستشار القانوني ⚖️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('استشارات قانونية وتجارية موثقة من وزارة العدل', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('جلسة استشارة قانونية (45 دقيقة)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textMain)),
                  const SizedBox(height: 2),
                  const Text('مباشرة عبر زوم أو الحضور بالمكتب', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFAB00),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('حجز موعد 📅', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3.2 Services Portfolio (المعرض المكتبي المهني)
  Widget _buildServPortfolio(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildNetworkImage(
                    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&q=80',
                    height: 110,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                      child: const Text('فيلا مودرن - الرياض', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Stack(
                children: [
                  _buildNetworkImage(
                    'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600&q=80',
                    height: 110,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                      child: const Text('ديكور داخلي فاخر', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.themeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📐 استشارات التصميم المعماري والديكور', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain)),
              Text('طلب معاينة 🏡', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.themeColor)),
            ],
          ),
        ),
      ],
    );
  }

  // 3.3 Services Quick (بطاقة الخدمة المباشرة)
  Widget _buildServQuick(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF1744).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildNetworkImage(
                'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600&q=80',
                width: 70,
                height: 70,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFF1744).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                      child: const Text('طوارئ 24/7 🚨', style: TextStyle(color: Color(0xFFFF1744), fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text('صيانة التكييف والأجهزة المنزلية ❄️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: textMain)),
                    const Text('وصول الفني خلال 30 دقيقة لجميع الأحياء', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.white),
              label: const Text('طلب فني صيانة عاجل الآن ⚡', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF1744),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3.4 Services Branding (الهوية الشخصية للخبراء)
  Widget _buildServBranding(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          _buildNetworkImage(
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&q=80',
            width: 80,
            height: 90,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('د. سارة العتيبي 🌟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: textMain)),
                const SizedBox(height: 2),
                Text('مستشارة تطوير الأعمال والاستثمار', style: TextStyle(fontSize: 11, color: widget.themeColor, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('مؤلفة وخبير معتمد في استراتيجيات النمو الرقمي', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.themeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('حجز استشارة خاصة 🤝', style: TextStyle(color: widget.themeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. CAFES & RESTAURANTS VARIANTS (الكافيهات والمطاعم)
  // =========================================================================

  // 4.1 Cafe Smart (المنيو التفاعلي الذكي)
  Widget _buildCafeSmart(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Stack(
          children: [
            _buildNetworkImage(
              'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&q=80',
              height: 120,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomRight,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أروما كافيه ومحمصة مختصة ☕', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                      Text('منيو إلكتروني سريع عبر QR Code', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                    ],
                  ),
                  Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFoodItemCard(
                image: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600&q=80',
                name: 'سبانش لاتيه مثلج',
                price: '22 ر.س',
                cardBg: cardBg,
                textMain: textMain,
                borderCol: borderCol,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFoodItemCard(
                image: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=600&q=80',
                name: 'كرواسون لوز فرنسي',
                price: '18 ر.س',
                cardBg: cardBg,
                textMain: textMain,
                borderCol: borderCol,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4.2 Cafe Lounge (نمط اللاونج الداكن والأنيق)
  Widget _buildCafeLounge(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0B1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFAA00FF).withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildNetworkImage(
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
            height: 110,
            width: double.infinity,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 10),
          const Text('لاونج ومطعم ذا روز الفاخر 🍷', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('جلسات عائلية خاصة وأجواء راقية مع إطلالة بانورامية', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFAA00FF).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('حجز طاولة VIP 🪑', style: TextStyle(color: Color(0xFFE1BEE7), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('قائمة المأكولات 📖', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4.3 Cafe Fastfood (الوجبات السريعة والتوصيل)
  Widget _buildCafeFastfood(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Stack(
          children: [
            _buildNetworkImage(
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
              height: 120,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
            ),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.bottomRight,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سماش برجر بيف أنجوس 🍔', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('وجبة دبل تشيز برجر + بطاطس مقرمشة + بيبسي بـ 34 ر.س', style: TextStyle(color: Color(0xFFFFD54F), fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 18),
            label: const Text('اطلب توصيل فوري عبر الواتساب (جاهز / هنقرستيشن) 🛵', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDD2C00),
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  // 4.4 Cafe Bakery (الكافيه العصري والحلويات)
  Widget _buildCafeBakery(bool isDark, Color cardBg, Color textMain, Color borderCol) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNetworkImage(
                'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
                height: 105,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildNetworkImage(
                'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=600&q=80',
                height: 105,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سويت بيكري للحلويات وكيك المناسبات 🍰', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textMain)),
                  const Text('كيك مخصص لأعياد الميلاد وحفلات التخرج', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFC51162),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('طلب كيكة مخصصة 🎂', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildProductCard({
    required String image,
    required String title,
    required String price,
    String? originalPrice,
    required String rating,
    required Color cardBg,
    required Color textMain,
    required Color borderCol,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildNetworkImage(
                image,
                height: 95,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(rating, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      price,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: widget.themeColor),
                    ),
                    if (originalPrice != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        originalPrice,
                        style: const TextStyle(fontSize: 9.5, color: Colors.grey, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 11),
                      SizedBox(width: 4),
                      Text('طلب واتساب', style: TextStyle(fontSize: 9.5, color: Color(0xFF25D366), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard({
    required String image,
    required String name,
    required String price,
    required Color cardBg,
    required Color textMain,
    required Color borderCol,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNetworkImage(
            image,
            height: 75,
            width: double.infinity,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(price, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: widget.themeColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String value, String label, Color color, Color cardBg, Color textMain, Color borderCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }
}
