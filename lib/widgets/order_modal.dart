import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_translations.dart';
import '../utils/order_notifier.dart';
import '../utils/paytabs_helper.dart';
import '../utils/supabase_storage_helper.dart';
import '../utils/whatsapp_helper.dart';

class OrderModal extends StatefulWidget {
  final String? initialDomain;

  const OrderModal({super.key, this.initialDomain});

  @override
  State<OrderModal> createState() => _OrderModalState();
}

class _OrderModalState extends State<OrderModal> {
  final _formKey = GlobalKey<FormState>();

  // Required Fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Optional Fields
  final _domainController = TextEditingController();
  final _logoLinkController = TextEditingController();
  final _photosLinkController = TextEditingController();
  final _profileLinkController = TextEditingController();
  final _aboutContentController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'متجر / محل تجاري';
  bool _isProcessing = false;

  // Uploaded File Results (with public URLs)
  UploadedFileResult? _logoFile;
  List<UploadedFileResult> _photoFiles = [];
  UploadedFileResult? _profileFile;

  bool _isUploadingLogo = false;
  bool _isUploadingPhotos = false;
  bool _isUploadingProfile = false;

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
    _logoLinkController.dispose();
    _photosLinkController.dispose();
    _profileLinkController.dispose();
    _aboutContentController.dispose();
    _contactInfoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Pick Logo File
  Future<void> _pickLogoFile() async {
    setState(() => _isUploadingLogo = true);
    try {
      final result = await SupabaseStorageHelper.pickAndUploadLogo();
      if (mounted && result != null) {
        setState(() {
          _logoFile = result;
        });
      }
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
  }

  // Pick Photos
  Future<void> _pickPhotos() async {
    setState(() => _isUploadingPhotos = true);
    try {
      final results = await SupabaseStorageHelper.pickAndUploadPhotos();
      if (mounted && results.isNotEmpty) {
        setState(() {
          _photoFiles = results;
        });
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhotos = false);
    }
  }

  // Pick Company Profile File
  Future<void> _pickProfileFile() async {
    setState(() => _isUploadingProfile = true);
    try {
      final result = await SupabaseStorageHelper.pickAndUploadProfileDocument();
      if (mounted && result != null) {
        setState(() {
          _profileFile = result;
        });
      }
    } finally {
      if (mounted) setState(() => _isUploadingProfile = false);
    }
  }

  String _getCombinedLogoInfo() {
    final List<String> parts = [];
    if (_logoFile != null) {
      if (_logoFile!.fileUrl != null && _logoFile!.fileUrl!.isNotEmpty) {
        parts.add(_logoFile!.fileUrl!);
      } else {
        parts.add('ملف: ${_logoFile!.fileName}');
      }
    }
    if (_logoLinkController.text.trim().isNotEmpty) {
      parts.add('رابط إضافي: ${_logoLinkController.text.trim()}');
    }
    return parts.join(' | ');
  }

  String _getCombinedPhotosInfo() {
    final List<String> parts = [];
    if (_photoFiles.isNotEmpty) {
      final urls = _photoFiles.where((f) => f.fileUrl != null).map((f) => f.fileUrl!).toList();
      if (urls.isNotEmpty) {
        parts.add(urls.join(' , '));
      } else {
        parts.add('${_photoFiles.length} صور مرفقة');
      }
    }
    if (_photosLinkController.text.trim().isNotEmpty) {
      parts.add('رابط إضافي: ${_photosLinkController.text.trim()}');
    }
    return parts.join(' | ');
  }

  String _getCombinedProfileInfo() {
    final List<String> parts = [];
    if (_profileFile != null) {
      if (_profileFile!.fileUrl != null && _profileFile!.fileUrl!.isNotEmpty) {
        parts.add(_profileFile!.fileUrl!);
      } else {
        parts.add('بروفايل: ${_profileFile!.fileName}');
      }
    }
    if (_profileLinkController.text.trim().isNotEmpty) {
      parts.add('رابط إضافي: ${_profileLinkController.text.trim()}');
    }
    return parts.join(' | ');
  }

  Future<void> _submitWhatsAppOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final domain = _domainController.text.trim();
    final aboutContent = _aboutContentController.text.trim();
    final contactInfo = _contactInfoController.text.trim();
    final notes = _notesController.text.trim();

    final logoInfo = _getCombinedLogoInfo();
    final photosInfo = _getCombinedPhotosInfo();
    final profileInfo = _getCombinedProfileInfo();

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
        logoInfo: logoInfo,
        photosInfo: photosInfo,
        profileInfo: profileInfo,
        aboutContent: aboutContent,
        contactInfo: contactInfo,
        notes: notes,
        paymentMethod: 'طلب وتأكيد عبر الواتساب + رابط PayTabs 💬',
        paymentUrl: paymentUrl,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.of(context).pop();

        // 3. Open WhatsApp chat with full order summary, attachments & direct PayTabs payment link
        await WhatsAppHelper.launchWhatsApp(
          businessName: name,
          category: _selectedCategory,
          domainChoice: domain,
          logoInfo: logoInfo,
          photosInfo: photosInfo,
          profileInfo: profileInfo,
          aboutContent: aboutContent,
          contactInfo: contactInfo,
          notes: notes,
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
          logoInfo: logoInfo,
          photosInfo: photosInfo,
          profileInfo: profileInfo,
          aboutContent: aboutContent,
          contactInfo: contactInfo,
          notes: notes,
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
    final aboutContent = _aboutContentController.text.trim();
    final contactInfo = _contactInfoController.text.trim();
    final notes = _notesController.text.trim();

    final logoInfo = _getCombinedLogoInfo();
    final photosInfo = _getCombinedPhotosInfo();
    final profileInfo = _getCombinedProfileInfo();

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
        logoInfo: logoInfo,
        photosInfo: photosInfo,
        profileInfo: profileInfo,
        aboutContent: aboutContent,
        contactInfo: contactInfo,
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
        padding: EdgeInsets.all(isMobile ? 16 : 26),
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 780),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.tr('modal_title'),
                                  style: TextStyle(
                                    fontSize: isMobile ? 14.5 : 17,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'الاسم ورقم الهاتف أساسيان فقط، وباقي الخانات اختيارية',
                                  style: TextStyle(
                                    fontSize: isMobile ? 10.5 : 11.5,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
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

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),

                // ==================== SECTION 1: REQUIRED BASIC INFO ====================
                _buildSectionHeader('1️⃣ البيانات الأساسية (مطلوبة)', Icons.person_rounded),
                const SizedBox(height: 8),

                // Field 1: Name (REQUIRED)
                Text(
                  'الاسم الكامل / اسم النشاط التجاري *',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                    hint: 'مثال: متجر الرياض / فهد القحطاني',
                    icon: Icons.business_center_outlined,
                    isDark: isDark,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى كتابة الاسم أو اسم النشاط للبدء';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Field 2: Phone (REQUIRED)
                Text(
                  'رقم الواتساب (للتواصل والتسليم الفوري) *',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    hint: 'مثال: 0501234567 أو +966501234567',
                    icon: Icons.phone_android_rounded,
                    isDark: isDark,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى كتابة رقم الواتساب الخاص بك';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Field 3: Category (Dropdown)
                Text(
                  'تصنيف النشاط (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: _buildInputDecoration(
                    hint: 'اختر تصنيف النشاط',
                    icon: Icons.category_rounded,
                    isDark: isDark,
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Field 4: Domain (OPTIONAL)
                Text(
                  'اسم الدومين المطلوب (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _domainController,
                  textDirection: TextDirection.ltr,
                  decoration: _buildInputDecoration(
                    hint: 'مثال: riyadh-store.site (أو اتركه لنساعدك في اختياره)',
                    icon: Icons.language_rounded,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // ==================== SECTION 2: BRAND ASSETS & ATTACHMENTS ====================
                _buildSectionHeader('2️⃣ المرفقات والشعار والصور (اختياري)', Icons.cloud_upload_rounded),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.primary),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'جميع المرفقات اختيارية ويمكنك أيضاً إرسالها لاحقاً عبر محادثة الواتساب بسهولة.',
                          style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Item A: Logo
                Text(
                  'شعار النشاط / اللوجو (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                _buildFilePickerRow(
                  label: _isUploadingLogo
                      ? 'جاري رفع الشعار إلى السيرفر... ⏳'
                      : (_logoFile != null
                          ? 'تم رفع الشعار بنجاح (${_logoFile!.fileName}) ✅'
                          : 'إرفاق ملف الشعار (PNG/JPG/SVG)'),
                  isSelected: _logoFile != null,
                  isUploading: _isUploadingLogo,
                  onPick: _pickLogoFile,
                  onClear: () => setState(() => _logoFile = null),
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _logoLinkController,
                  decoration: _buildInputDecoration(
                    hint: 'أو ضع رابط الشعار / Google Drive هنا',
                    icon: Icons.link_rounded,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 14),

                // Item B: Activity / Product Photos
                Text(
                  'الصور المتاحة للنشاط أو المنتجات (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                _buildFilePickerRow(
                  label: _isUploadingPhotos
                      ? 'جاري رفع الصور إلى السيرفر... ⏳'
                      : (_photoFiles.isNotEmpty
                          ? 'تم رفع ${_photoFiles.length} صور بنجاح ✅'
                          : 'إرفاق صور النشاط / المنتجات'),
                  isSelected: _photoFiles.isNotEmpty,
                  isUploading: _isUploadingPhotos,
                  onPick: _pickPhotos,
                  onClear: () => setState(() => _photoFiles = []),
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _photosLinkController,
                  decoration: _buildInputDecoration(
                    hint: 'أو ضع رابط مجلد الصور / Dropbox / Drive',
                    icon: Icons.photo_library_rounded,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 14),

                // Item C: Company Profile File
                Text(
                  'ملف بروفايل الشركة / النشاط (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                _buildFilePickerRow(
                  label: _isUploadingProfile
                      ? 'جاري رفع البروفايل إلى السيرفر... ⏳'
                      : (_profileFile != null
                          ? 'تم رفع البروفايل بنجاح (${_profileFile!.fileName}) ✅'
                          : 'إرفاق ملف البروفايل (PDF/Word)'),
                  isSelected: _profileFile != null,
                  isUploading: _isUploadingProfile,
                  onPick: _pickProfileFile,
                  onClear: () => setState(() => _profileFile = null),
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _profileLinkController,
                  decoration: _buildInputDecoration(
                    hint: 'أو ضع رابط ملف البروفايل السحابي',
                    icon: Icons.picture_as_pdf_rounded,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // ==================== SECTION 3: CONTENT & CONTACT INFO ====================
                _buildSectionHeader('3️⃣ محتوى الموقع وبيانات التواصل (اختياري)', Icons.article_rounded),
                const SizedBox(height: 10),

                // Item D: Content / About text
                Text(
                  'البيانات والنصوص المراد إضافتها في الموقع (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _aboutContentController,
                  maxLines: 3,
                  decoration: _buildInputDecoration(
                    hint: 'اكتب نبذة عن نشاطك، أبرز المنتجات والخدمات، الأسعار أو العروض التي ترغب في عرضها بالموقع...',
                    icon: Icons.edit_note_rounded,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 12),

                // Item E: Address, Phones, Emails, Website, Social
                Text(
                  'العنوان وأرقام الهواتف والإيميلات وروابط التواصل (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _contactInfoController,
                  maxLines: 3,
                  decoration: _buildInputDecoration(
                    hint: 'العنوان/الفرع، رابط موقع قوقل ماب، أرقام هواتف إضافية، الإيميل الرسمي، حسابات انستقرام وتيك توك وتويتر...',
                    icon: Icons.location_on_rounded,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 12),

                // Item F: General Notes
                Text(
                  'ملاحظات أو طلبات خاصة للتصميم (اختياري)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: _buildInputDecoration(
                    hint: 'أي ألوان مفضلة، أو أمثلة لمواقع تعجبك، أو تعليمات خاصة...',
                    icon: Icons.palette_rounded,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================== PRICE BREAKDOWN (5 LINES) ====================
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                      width: 1.2,
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
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 4),

                      // 2. Line USD
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🇺🇸 السعر بالدولار (تقريباً):',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          Text(
                            '\$79.73 USD',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // 3. Line EGP Base
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🇪🇬 السعر بالمصري (سعر الصرف 13.00):',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          Text(
                            '3,887.00 ج.م',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // 4. Line TAX 5%
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🧾 TAX (5%):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          Text(
                            '+ 194.35 ج.م',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
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
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          const Text(
                            '4,081.35 ج.م',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
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
                      onPressed: (_isProcessing || _isUploadingLogo || _isUploadingPhotos || _isUploadingProfile)
                          ? null
                          : _submitWhatsAppOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: (_isUploadingLogo || _isUploadingPhotos || _isUploadingProfile)
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
                                  'جاري رفع المرفقات للسيرفر... يرجى الانتظار ⏳',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : _isProcessing
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
                    onPressed: (_isProcessing || _isUploadingLogo || _isUploadingPhotos || _isUploadingProfile)
                        ? null
                        : _payWithPayTabs,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerRow({
    required String label,
    required bool isSelected,
    bool isUploading = false,
    required VoidCallback onPick,
    required VoidCallback onClear,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (isSelected || isUploading) ? null : onPick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : (isUploading
                      ? AppTheme.primary
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight)),
              width: (isSelected || isUploading) ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (isUploading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                )
              else
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
                  color: isSelected ? const Color(0xFF10B981) : AppTheme.primary,
                  size: 20,
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : (isUploading ? AppTheme.primary : textColor(isDark)),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isUploading)
                const SizedBox.shrink()
              else if (isSelected)
                IconButton(
                  icon: const Icon(Icons.cancel_rounded, size: 20, color: Colors.redAccent),
                  onPressed: onClear,
                  tooltip: 'إلغاء الملف',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_rounded, size: 14, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text(
                        'اختيار ملف',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
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

  Color textColor(bool isDark) => isDark ? Colors.white70 : Colors.black87;

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
      prefixIcon: Icon(icon, size: 18, color: AppTheme.primary),
      filled: true,
      fillColor: isDark ? AppTheme.cardDark : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
    );
  }
}
