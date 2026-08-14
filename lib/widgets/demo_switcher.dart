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
    final currentCategory = TemplateModel.sampleTemplates[_selectedCategoryIndex];
    final currentVariant = currentCategory.variants[_selectedVariantIndex];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 36 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Badge header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.palette_rounded, color: AppTheme.primaryDark, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      AppTranslations.tr('demo_badge_header'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Text(
                AppTranslations.tr('demo_title'),
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppTranslations.tr('demo_sub'),
                style: TextStyle(
                  fontSize: isMobile ? 13.5 : 16,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isMobile ? 20 : 36),

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
                        child: ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            item.icon,
                            color: isSelected ? Colors.black : AppTheme.primary,
                            size: 16,
                          ),
                          label: Text(
                            translatedCatName.isNotEmpty ? translatedCatName : item.category,
                            style: TextStyle(
                              fontSize: isMobile ? 12.5 : 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppTheme.textWhite : AppTheme.textDark),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryDark,
                          backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoryIndex = index;
                                _selectedVariantIndex = 0;
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Shape / Variant Switcher Bar
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
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
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 16,
                            vertical: isMobile ? 7 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? variant.themeColor.withValues(alpha: 0.25) : variant.themeColor.withValues(alpha: 0.15))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? (isDark ? variant.themeColor : AppTheme.primaryDark) : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? (isDark ? variant.themeColor : AppTheme.primaryDark) : AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppTranslations.getVariantName(variant),
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? (isDark ? AppTheme.textWhite : AppTheme.textDark)
                                      : AppTheme.textMuted,
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

              SizedBox(height: isMobile ? 20 : 32),

              // Detailed Template Preview Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Badge & Details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(isMobile ? 10 : 16),
                            decoration: BoxDecoration(
                              color: currentVariant.themeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: currentVariant.themeColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              currentCategory.icon,
                              color: currentVariant.themeColor,
                              size: isMobile ? 24 : 36,
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
                                          fontSize: isMobile ? 16 : 22,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: currentVariant.themeColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: currentVariant.themeColor.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        AppTranslations.getVariantBadge(currentVariant),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? currentVariant.themeColor : AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppTranslations.tr('demo_domain_prefix')}${currentVariant.demoUrl}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 13,
                                    color: isDark ? currentVariant.themeColor : AppTheme.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      Divider(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      const SizedBox(height: 18),

                      Text(
                        AppTranslations.getVariantDesc(currentVariant),
                        style: TextStyle(
                          fontSize: isMobile ? 13.5 : 16,
                          color: theme.textTheme.bodyLarge?.color,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Features Highlights Checklist
                      Column(
                        children: AppTranslations.getVariantHighlights(currentVariant).map((feat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: currentVariant.themeColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 15,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: isMobile ? 20 : 32),

                      // Interactive Visual Layout Shape Preview
                      ShapePreviewWidget(
                        variantId: currentVariant.id,
                        themeColor: currentVariant.themeColor,
                      ),

                      SizedBox(height: isMobile ? 20 : 32),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            WhatsAppHelper.launchWhatsApp(
                              category: currentCategory.category,
                              customMessage:
                                  'أرغب في طلب (${currentVariant.name}) لـ (${currentCategory.category}) بسعر 299 ريال شامل الدومين!',
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                          label: Text(AppTranslations.tr('demo_order_btn')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentVariant.themeColor,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
                            textStyle: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
