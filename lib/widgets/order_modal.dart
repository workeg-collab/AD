import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/order_notifier.dart';
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
  bool _isProcessing = false;

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

  Future<void> _submitWhatsAppOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final domain = _domainController.text.trim();
    final notes = _notesController.text.trim();

    try {
      // 1. Generate direct PayTabs payment page URL for this order
      final paymentUrl = await PayTabsHelper.createPaymentPage(
        customerName: name,
        customerPhone: phone,
        customerEmail: 'customer@ad-landing.com',
        businessName: name,
        domainChoice: domain,
        amountSar: 299.00,
        sarToEgpRate: 13.00,
        taxPercent: 5.00,
      );

      // 2. Send complete background email notification to company email (sales@pom-agency.online)
      await OrderNotifier.sendAdminNotification(
        customerName: name,
        customerPhone: phone,
        businessName: name,
        category: _selectedCategory,
        domainChoice: domain,
        notes: notes,
        paymentMethod: 'طلب وتأكيد عبر الواتساب + رابط PayTabs 💬',
        paymentUrl: paymentUrl,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.of(context).pop();

        // 3. Open WhatsApp chat with order summary AND direct PayTabs payment link
        await WhatsAppHelper.launchWhatsApp(
          businessName: name,
          category: _selectedCategory,
          domainChoice: domain,
          paymentUrl: paymentUrl,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.of(context).pop();
        await WhatsAppHelper.launchWhatsApp(
          businessName: name,
          category: _selectedCategory,
          domainChoice: domain,
        );
      }
    }
  }

  Future<void> _payWithPayTabs() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final domain = _domainController.text.trim();
    final notes = _notesController.text.trim();

    try {
      // 1. Launch PayTabs hosted checkout
      final paymentUrl = await PayTabsHelper.createPaymentPage(
        customerName: name,
        customerPhone: phone,
        customerEmail: 'customer@ad-landing.com',
        businessName: name,
        domainChoice: domain,
        amountSar: 299.00,
        sarToEgpRate: 13.00,
        taxPercent: 5.00,
      );

      // 2. Send complete background email notification to company email (sales@pom-agency.online)
      await OrderNotifier.sendAdminNotification(
        customerName: name,
        customerPhone: phone,
        businessName: name,
        category: _selectedCategory,
        domainChoice: domain,
        notes: notes,
        paymentMethod: 'دفع فوري بالبطاقة عبر PayTabs 💳',
        paymentUrl: paymentUrl,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          Navigator.of(context).pop();
          await PayTabsHelper.launchPayment(
            customerName: name,
            customerPhone: phone,
            customerEmail: 'customer@ad-landing.com',
            businessName: name,
            domainChoice: domain,
            amountSar: 299.00,
            sarToEgpRate: 13.00,
            taxPercent: 5.00,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر فتح صفحة الدفع، جاري تحويلك للواتساب للمتابعة مباشرة...'),
              backgroundColor: Colors.orange,
            ),
          );
          _submitWhatsAppOrder();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isProcessing = false);
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
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.5,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
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
                    Expanded(
                      child: Row(
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
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              AppTranslations.tr('modal_title'),
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  AppTranslations.tr('modal_sub'),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),

                const SizedBox(height: 16),

                // Business Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('lbl_name'),
                    hintText: 'مثال: متجر الأناقة أو شركة الفجر',
                    prefixIcon: const Icon(Icons.store_rounded, color: AppTheme.primary, size: 20),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة الاسم';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Phone Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف / الواتساب للتواصل *',
                    hintText: '05xxxxxxxx أو 01xxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.secondary, size: 20),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة رقم الهاتف للتواصل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Selected Domain Input
                TextFormField(
                  controller: _domainController,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'اسم الدومين المقترح (مجاناً بالسنة الأولى)',
                    hintText: 'مثال: mybrand.site',
                    hintTextDirection: TextDirection.ltr,
                    prefixIcon: const Icon(Icons.language_rounded, color: Color(0xFF10B981), size: 20),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    suffixIcon: _domainController.text.isNotEmpty
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                        : null,
                  ),
                ),

                const SizedBox(height: 12),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'نوع النشاط *',
                    prefixIcon: Icon(Icons.category_rounded, color: AppTheme.accentGold, size: 20),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  dropdownColor: isDark ? AppTheme.cardDark : Colors.white,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: TextStyle(color: textColor, fontSize: 13)),
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

                const SizedBox(height: 12),

                // Notes Input
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('lbl_notes'),
                    hintText: 'أي تفاصيل أو رغبات خاصة بتصميم صفحتك...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),

                const SizedBox(height: 14),

                // Detailed Multi-Currency & TAX (5%) Invoice Breakdown Card
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
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
                          Text(
                            '🇸🇦 السعر بالريال السعودي:',
                            style: TextStyle(fontSize: isMobile ? 12 : 13, color: AppTheme.textMuted),
                          ),
                          Text(
                            '299.00 SAR',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
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
                          Text(
                            '🇺🇸 السعر بالدولار الأمريكي:',
                            style: TextStyle(fontSize: isMobile ? 12 : 13, color: AppTheme.textMuted),
                          ),
                          Text(
                            '\$79.73 USD',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
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
                          Text(
                            '🇪🇬 السعر بالجنيه المصري (قبل الضريبة):',
                            style: TextStyle(fontSize: isMobile ? 11.5 : 13, color: AppTheme.textMuted),
                          ),
                          Text(
                            '3,887.00 ج.م',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 4. Line TAX (5%)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🧾 TAX (5%):',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                          Text(
                            '+ 194.35 ج.م',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1),
                      ),

                      // 5. Line Total EGP with TAX
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '💳 الإجمالي النهائي للدفع:',
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '4,081.35 ج.م',
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Primary Action: Submit Order + PayTabs Link via WhatsApp
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _submitWhatsAppOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isProcessing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'جاري تجهيز الطلب ورابط الدفع...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'تأكيد الطلب واستلام رابط الدفع عبر الواتساب 💬',
                                  style: TextStyle(
                                    fontSize: 14,
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

                // Secondary Action: Instant Card Payment
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _payWithPayTabs,
                    icon: const Icon(Icons.credit_card_rounded, color: Color(0xFF2563EB), size: 18),
                    label: const Text(
                      'أو الدفع الفوري بالفيزا/الماستركارد (PayTabs) 💳',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
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
