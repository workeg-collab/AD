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
    final isMobile = MediaQuery.of(context).size.width < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentCategory = TemplateModel.sampleTemplates[_selectedCategoryIndex];
    final currentVariant = currentCategory.variants[_selectedVariantIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Badge header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.palette_rounded, color: AppTheme.primaryDark, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '4 أشكال عصرية لكل نوع قالب',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppTranslations.tr('demo_title'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppTranslations.tr('demo_sub'),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

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
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            item.icon,
                            color: isSelected ? Colors.black : AppTheme.primary,
                            size: 18,
                          ),
                          label: Text(
                            translatedCatName.isNotEmpty ? translatedCatName : item.category,
                            style: TextStyle(
                              fontSize: 14,
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
                              color: isSelected ? AppTheme.primary : AppTheme.borderDark,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Shape / Variant Switcher Bar
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
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
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? variant.themeColor.withValues(alpha: 0.25) : variant.themeColor.withValues(alpha: 0.15))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? (isDark ? variant.themeColor : AppTheme.primaryDark) : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? (isDark ? variant.themeColor : AppTheme.primaryDark) : AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                variant.name,
                                style: TextStyle(
                                  fontSize: 13,
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

              const SizedBox(height: 32),

              // Detailed Template Preview Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Badge & Details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: currentVariant.themeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: currentVariant.themeColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              currentCategory.icon,
                              color: currentVariant.themeColor,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currentVariant.name,
                                        style: TextStyle(
                                          fontSize: isMobile ? 18 : 22,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: currentVariant.themeColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: currentVariant.themeColor.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        currentVariant.badge,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? currentVariant.themeColor : AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'الدومين التجريبي المقترح: ${currentVariant.demoUrl}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? currentVariant.themeColor : AppTheme.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Divider(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      const SizedBox(height: 24),

                      Text(
                        currentVariant.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Features Highlights Checklist
                      Column(
                        children: currentVariant.highlights.map((feat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: currentVariant.themeColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Interactive Visual Layout Shape Preview
                      ShapePreviewWidget(
                        variantId: currentVariant.id,
                        themeColor: currentVariant.themeColor,
                      ),

                      const SizedBox(height: 32),

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
                          icon: const Icon(Icons.chat_bubble_rounded),
                          label: Text('اطلب ${currentVariant.name} بـ 299 ريال شامل الدومين'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentVariant.themeColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            textStyle: const TextStyle(
                              fontSize: 16,
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

