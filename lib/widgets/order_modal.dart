import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/paytabs_helper.dart';
import '../utils/whatsapp_helper.dart';

class OrderModal extends StatefulWidget {
  final String? initialDomain;

  const OrderModal({super.key, this.initialDomain});

  @override
  State<OrderModal> createState() => _OrderModalState();
}

class _OrderModalState extends State<OrderModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _domainController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'متجر / محل تجاري';
  bool _isPaying = false;

  final List<String> _categories = [
    'متجر / محل تجاري',
    'مصنع / شركة B2B',
    'مكتب خدمات / استشارات',
    'كافيه / مطعم',
    'خدمة أخرى',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDomain != null && widget.initialDomain!.isNotEmpty) {
      _domainController.text = widget.initialDomain!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _domainController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitWhatsAppOrder() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      WhatsAppHelper.launchWhatsApp(
        businessName: _nameController.text.trim(),
        category: _selectedCategory,
        domainChoice: _domainController.text.trim(),
        customMessage: _notesController.text.trim().isNotEmpty
            ? 'طلب جديد لـ ${_nameController.text.trim()} - رقم التواصل: ${_phoneController.text.trim()} - ملاحظات: ${_notesController.text.trim()}'
            : null,
      );
    }
  }

  Future<void> _payWithPayTabs() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPaying = true);

    try {
      final success = await PayTabsHelper.launchPayment(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerEmail: 'customer@ad-landing.com',
        businessName: _nameController.text.trim(),
        domainChoice: _domainController.text.trim(),
        amountSar: 299.00,
        sarToEgpRate: 13.00,
      );

      if (mounted) {
        setState(() => _isPaying = false);
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('جاري التحويل إلى بوابة الدفع الآمنة PayTabs... 💳'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح صفحة الدفع حالياً، يمكنك إتمام الطلب عبر الواتساب مباشرة.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.5,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppTranslations.tr('modal_title'),
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  AppTranslations.tr('modal_sub'),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),

                const SizedBox(height: 20),

                // Business Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('lbl_name'),
                    hintText: 'مثال: متجر الأناقة أو شركة الفجر',
                    prefixIcon: const Icon(Icons.store_rounded, color: AppTheme.primary),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة الاسم';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Phone Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف / الواتساب للتواصل *',
                    hintText: '05xxxxxxxx أو 01xxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.secondary),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة رقم الهاتف للتواصل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Selected Domain Input
                TextFormField(
                  controller: _domainController,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'اسم الدومين المقترح (مجاناً بالسنة الأولى)',
                    hintText: 'مثال: mybrand.site',
                    hintTextDirection: TextDirection.ltr,
                    prefixIcon: const Icon(Icons.language_rounded, color: Color(0xFF10B981)),
                    border: const OutlineInputBorder(),
                    suffixIcon: _domainController.text.isNotEmpty
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
                        : null,
                  ),
                ),

                const SizedBox(height: 14),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'نوع النشاط *',
                    prefixIcon: Icon(Icons.category_rounded, color: AppTheme.accentGold),
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),

                const SizedBox(height: 14),

                // Notes Input
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('lbl_notes'),
                    hintText: 'أي تفاصيل أو رغبات خاصة بتصميم صفحتك...',
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Detailed Multi-Currency & 5% Tax Invoice Breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // 1. Line SAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🇸🇦 السعر بالريال السعودي:',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          Text(
                            '299.00 SAR',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 2. Line USD
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🇺🇸 السعر بالدولار الأمريكي:',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          Text(
                            '\$79.73 USD',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 3. Line EGP Base
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🇪🇬 السعر بالجنيه المصري (قبل الضريبة):',
                            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          ),
                          Text(
                            '3,887.00 ج.م',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 4. Line 5% Tax
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🧾 ضريبة القيمة المضافة (5%):',
                            style: TextStyle(fontSize: 13, color: Color(0xFFD97706)),
                          ),
                          Text(
                            '+ 194.35 ج.م',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),

                      // 5. Line Total EGP with Tax
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '💳 الإجمالي النهائي للدفع:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const Text(
                            '4,081.35 ج.م',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Primary Payment Button (PayTabs)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF0284C7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isPaying ? null : _payWithPayTabs,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isPaying
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'جاري تجهيز بوابة الدفع...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card_rounded, color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'الدفع الإلكتروني الآمن (PayTabs) 💳',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Secondary WhatsApp Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _submitWhatsAppOrder,
                    icon: const Icon(Icons.chat_rounded, color: Color(0xFF10B981), size: 20),
                    label: const Text(
                      'أو إتمام والطلب عبر الواتساب مباشرة 💬',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
