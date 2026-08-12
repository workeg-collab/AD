import 'package:flutter/material.dart';
import '../models/template_model.dart';
import '../theme/app_theme.dart';
import '../utils/whatsapp_helper.dart';

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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final currentTemplate = TemplateModel.sampleTemplates[_selectedIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const Text(
                'استكشف نماذج القوالب المتاحة لأنشطتك',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'نقوم بتخصيص الألوان والنصوص والمنتجات حسب مجال نشاطك التجاري بدقة عالية',
                style: TextStyle(
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
                      final isSelected = _selectedIndex == index;

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
                            item.category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.black : AppTheme.textWhite,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceDark,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedIndex = index;
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

              const SizedBox(height: 40),

              // Template Preview Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 36),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              currentTemplate.icon,
                              color: AppTheme.primary,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTemplate.title,
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textWhite,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'الدومين التأسيسي المتوقع: ${currentTemplate.demoUrl}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: AppTheme.borderDark),
                      const SizedBox(height: 24),

                      Text(
                        currentTemplate.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textWhite,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Features Checklist
                      Column(
                        children: currentTemplate.features.map((feat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppTheme.textWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            WhatsAppHelper.launchWhatsApp(
                              category: currentTemplate.category,
                              customMessage: 'أرغب في اختيار ${currentTemplate.title} لشركتي!',
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_rounded),
                          label: const Text('اطلب هذا القالب بـ 299 ريال شامل الدومين'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
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
