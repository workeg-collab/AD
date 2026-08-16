import 'package:flutter/material.dart';
import '../models/template_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/whatsapp_helper.dart';
import 'shape_preview_widget.dart';

class DemoSwitcher extends StatefulWidget {
  final VoidCallback onSelectTemplate;

  const DemoSwitcher({
    super.key,
    required this.onSelectTemplate,
  });

  @override
  State<DemoSwitcher> createState() => _DemoSwitcherState();
}

class _DemoSwitcherState extends State<DemoSwitcher> {
  int _selectedCategoryIndex = 0;
  int _selectedVariantIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;

    final currentCategory = TemplateModel.sampleTemplates[_selectedCategoryIndex];
    final currentVariant = currentCategory.variants[_selectedVariantIndex];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 48 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              // Badge Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    const Icon(Icons.palette_outlined, color: AppTheme.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      AppTranslations.tr('demo_badge_header'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                AppTranslations.tr('demo_title'),
                style: TextStyle(
                  fontSize: isMobile ? 22 : 32,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppTranslations.tr('demo_sub'),
                style: TextStyle(
                  fontSize: isMobile ? 13.5 : 15.5,
                  color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 24 : 36),

              // Category Selector Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    TemplateModel.sampleTemplates.length,
                    (index) {
                      final item = TemplateModel.sampleTemplates[index];
                      final isSelected = _selectedCategoryIndex == index;
                      final translatedCatName = AppTranslations.tr('cat_${item.id}_name');

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                              _selectedVariantIndex = 0;
                            });
                          },
                          borderRadius: AppTheme.radiusSm,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : (isDark ? AppTheme.cardDark : Colors.white),
                              borderRadius: AppTheme.radiusSm,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? AppTheme.softShadow(isDark: isDark, elevation: 1)
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppTheme.textMutedDark : AppTheme.textMuted),
                                  size: 17,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  translatedCatName.isNotEmpty ? translatedCatName : item.category,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppTheme.textWhite : AppTheme.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Variant Switcher Bar
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : const Color(0xFFF1F5F9),
                  borderRadius: AppTheme.radiusMd,
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 1,
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(
                    currentCategory.variants.length,
                    (vIndex) {
                      final variant = currentCategory.variants[vIndex];
                      final isSelected = _selectedVariantIndex == vIndex;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedVariantIndex = vIndex;
                          });
                        },
                        borderRadius: AppTheme.radiusSm,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 14,
                            vertical: isMobile ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppTheme.surfaceDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: AppTheme.radiusSm,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppTheme.borderDark : AppTheme.borderLight)
                                  : Colors.transparent,
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppTranslations.getVariantName(variant),
                                style: TextStyle(
                                  fontSize: isMobile ? 11.5 : 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? AppTheme.textWhite : AppTheme.textDark)
                                      : (isDark ? AppTheme.textMutedDark : AppTheme.textMuted),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 24 : 36),

              // Detailed Template Preview Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: AppTheme.radiusLg,
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    width: 1,
                  ),
                  boxShadow: AppTheme.softShadow(isDark: isDark, elevation: 1),
                ),
                padding: EdgeInsets.all(isMobile ? 18 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row with Category icon & Details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isMobile ? 10 : 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.primaryContainerDark
                                : AppTheme.primaryContainer,
                            borderRadius: AppTheme.radiusMd,
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            currentCategory.icon,
                            color: AppTheme.primary,
                            size: isMobile ? 22 : 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppTranslations.getVariantName(currentVariant),
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 20,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.primaryContainerDark
                                          : AppTheme.primaryContainer,
                                      borderRadius: AppTheme.radiusSm,
                                      border: Border.all(
                                        color: AppTheme.primary.withValues(alpha: 0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      AppTranslations.getVariantBadge(currentVariant),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppTranslations.tr('demo_domain_prefix')}${currentVariant.demoUrl}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    const SizedBox(height: 16),

                    Text(
                      AppTranslations.getVariantDesc(currentVariant),
                      style: TextStyle(
                        fontSize: isMobile ? 13.5 : 15,
                        color: textColor,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Features Highlights Checklist
                    Column(
                      children: AppTranslations.getVariantHighlights(currentVariant).map((feat) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppTheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  feat,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: isMobile ? 20 : 28),

                    // Interactive Visual Layout Shape Preview
                    ShapePreviewWidget(
                      variantId: currentVariant.id,
                      themeColor: AppTheme.primary,
                    ),

                    SizedBox(height: isMobile ? 20 : 28),

                    // Action Buttons Row (Order Modal + WhatsApp)
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: widget.onSelectTemplate,
                            icon: const Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.white),
                            label: Text(
                              isMobile ? 'طلب هذا التصميم (299 ريال) 🚀' : 'طلب وتخصيص هذا التصميم فوراً بـ 299 ريال 🚀',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: isMobile ? 12.5 : 14.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
                              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              WhatsAppHelper.launchWhatsApp(
                                category: currentCategory.category,
                                customMessage:
                                    'أهلاً POM Agency، أرغب في طلب (${currentVariant.name}) لـ (${currentCategory.category}) بسعر 299 ريال شامل الدومين والتسليم خلال 6 ساعات!',
                              );
                            },
                            icon: const Icon(Icons.chat_rounded, size: 18, color: Color(0xFF25D366)),
                            label: Text(
                              isMobile ? 'واتساب' : 'محادثة واتساب 💬',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                                color: Color(0xFF25D366),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF25D366), width: 1.2),
                              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
                              shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
