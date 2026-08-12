import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/whatsapp_helper.dart';

class OrderModal extends StatefulWidget {
  const OrderModal({super.key});

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
    return Dialog(
      backgroundColor: AppTheme.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.borderDark, width: 1),
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
                    const Row(
                      children: [
                        Icon(Icons.edit_document, color: AppTheme.primary, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'تعبئة تفاصيل الطلب السريع',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
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
                const Text(
                  'أدخل البيانات الأولية لتحويلها مباشرة للواتساب والبدء بالتنفيذ خلال 6 ساعات',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),

                const SizedBox(height: 24),

                // Business Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المحل / الشركة *',
                    hintText: 'مثال: متجر المها للعبايات',
                    prefixIcon: Icon(Icons.store_rounded, color: AppTheme.primary),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى كتابة اسم النشاط التجاري';
                    }
                    return null;
                  },
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
                  dropdownColor: AppTheme.cardDark,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: const TextStyle(color: AppTheme.textWhite)),
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

                // Domain Suggestion Input
                TextFormField(
                  controller: _domainController,
                  decoration: const InputDecoration(
                    labelText: 'الدومين المقترح (اختياري)',
                    hintText: 'مثال: almaha-store.site',
                    prefixIcon: Icon(Icons.language_rounded, color: AppTheme.accentGold),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Notes Input
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات أو روابط نصوص وصور (اختياري)',
                    hintText: 'أية طلبات خاصة أو تفاصيل إضافية...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitOrder,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text('إرسال وبدء التنفيذ عبر الواتساب (299 ريال)'),
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
