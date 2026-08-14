import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
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
  final _domainController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'متجر / محل تجاري';

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
    _domainController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      WhatsAppHelper.launchWhatsApp(
        businessName: _nameController.text.trim(),
        category: _selectedCategory,
        domainChoice: _domainController.text.trim(),
        customMessage: _notesController.text.trim().isNotEmpty
            ? 'طلب جديد لـ ${_nameController.text.trim()} - ملاحظات: ${_notesController.text.trim()}'
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Dialog(
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 520),
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
                        const Icon(Icons.edit_document, color: AppTheme.primary, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          AppTranslations.tr('modal_title'),
                          style: TextStyle(
                            fontSize: 17,
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

                const SizedBox(height: 24),

                // Business Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('lbl_name'),
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

                const SizedBox(height: 16),

                // Selected Domain Input
                TextFormField(
                  controller: _domainController,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'اسم الدومين المقترح (مجاناً مع الباقة)',
                    hintText: 'مثال: mybrand.site',
                    hintTextDirection: TextDirection.ltr,
                    prefixIcon: const Icon(Icons.language_rounded, color: Color(0xFF10B981)),
                    border: const OutlineInputBorder(),
                    suffixIcon: _domainController.text.isNotEmpty
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'نوع النشاط *',
                    prefixIcon: Icon(Icons.category_rounded, color: AppTheme.secondary),
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

                const SizedBox(height: 16),

                // Notes Input
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppTranslations.tr('lbl_notes'),
                    border: const OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitOrder,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: Text(AppTranslations.tr('btn_submit_order')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
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
