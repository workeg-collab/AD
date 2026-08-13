import 'package:flutter/material.dart';
import '../models/template_model.dart';

class AppLanguage {
  final String code;
  final String name;
  final String flag;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
    this.isRtl = false,
  });
}

final List<AppLanguage> supportedLanguages = [
  const AppLanguage(code: 'ar', name: 'العربية', flag: '🇸🇦', isRtl: true),
  const AppLanguage(code: 'en', name: 'English', flag: '🇬🇧'),
  const AppLanguage(code: 'tr', name: 'Türkçe', flag: '🇹🇷'),
  const AppLanguage(code: 'fr', name: 'Français', flag: '🇫🇷'),
  const AppLanguage(code: 'de', name: 'Deutsch', flag: '🇩🇪'),
  const AppLanguage(code: 'it', name: 'Italiano', flag: '🇮🇹'),
  const AppLanguage(code: 'hi', name: 'हिन्दी', flag: '🇮🇳'),
];

final ValueNotifier<AppLanguage> currentLanguageNotifier =
    ValueNotifier<AppLanguage>(supportedLanguages[0]);

class AppTranslations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // Navbar & Hero
      'hero_badge': 'تسليم خلال 6 ساعات من الاتفاق + دومين مجاني لسنة كاملة!',
      'hero_title': 'صفحة تعريفية لمنتجاتك وخدماتك\nتزيد مبيعاتك وثقة عملائك بـ 299 ريال فقط!',
      'hero_sub': 'انقل عملك التجاري، محلك، أو مصنعك إلى العالم الرقمي بدون تكاليف باهظة. احصل على موقع ويب احترافي فائق السرعة، متوافق مع كافة الجوالات، مربوط برقم الواتساب الخاص بك.',
      'btn_order': 'اطلب موقعك الآن (299 ريال)',
      'btn_demos': 'استعرض نماذج القوالب',
      'chip_domain': 'دومين مجاني (سنة أولى)',
      'chip_delivery': 'استلام خلال 6 ساعات',
      'chip_edits': '3 تعديلات مجانية',
      'chip_tech': 'مطور بـ Flutter Web',
      'nav_features': 'المميزات',
      'nav_demos': 'القوالب',
      'nav_pricing': 'الأسعار',
      'nav_order': 'اطلب الآن',
      'whatsapp_btn_top': 'تواصل مباشر',
      'whatsapp_btn_main': 'واتساب المبيعات 💬',

      // Demo Switcher Header
      'demo_badge_header': '4 أشكال عصرية لكل نوع قالب',
      'demo_title': 'نماذج وقوالب جاهزة للمعاينة الحية',
      'demo_sub': 'اختر المجال واكتشف الأشكال والتصاميم المختلفة المتاحة لشركتك',
      'demo_select_btn': 'اطلب هذا التصميم لموقعك 🚀',
      'demo_live_preview': 'معاينة حية ومجانية ✨',
      'demo_included_title': 'تشمل هذه الباقة:',
      'demo_domain_prefix': 'الدومين التجريبي المقترح: ',
      'demo_order_btn': 'اطلب هذا القالب بـ 299 ريال شامل الدومين',

      // Categories
      'cat_retail_name': 'محلات ومتاجر تجزئة',
      'cat_retail_desc': 'صفحات هبوط مخصصة لمتاجر العطور، الساعات، الملابس، والمنتجات الفيزيائية.',
      'cat_corp_name': 'شركات ومؤسسات',
      'cat_corp_desc': 'تصاميم رسمية تعكس قوة الهوية التجارية والمصانع والخدمات اللوجستية.',
      'cat_serv_name': 'مكاتب وخدمات',
      'cat_serv_desc': 'مثالية للمكاتب الاستشارية، المحاماة، العيادات، والعقارات.',
      'cat_cafe_name': 'كافيهات ومطاعم',
      'cat_cafe_desc': 'منيو إلكتروني تفاعلي مع عرض الأطباق اليومية وحجز الطاولات.',

      // Retail Variants
      'v_retail-modern_name': 'الشكل 1: المتجر الحديث والمودرن',
      'v_retail-modern_badge': 'الأكثر طلباً 🔥',
      'v_retail-modern_desc': 'عرض منتجات بنظام كروت تفاعلية زجاجية، زر طلب واتساب مباشر، وربط مع الموقع الجغرافي للمحل.',
      'v_retail-modern_h0': 'معرض منتجات تفاعلي عالي الدقة',
      'v_retail-modern_h1': 'زر اطلب عبر الواتساب لكل منتج',
      'v_retail-modern_h2': 'تكامل كامل مع موقع المحل على قوقل ماب',
      'v_retail-modern_h3': 'مريح وسريع جداً على شاشات الجوال',

      'v_retail-grid_name': 'الشكل 2: المعرض الشبكي الديناميكي',
      'v_retail-grid_badge': 'مناسب للمجموعات 🛍️',
      'v_retail-grid_desc': 'تنسيق شبكي منظم لعرض عشرات المنتجات والتصنيفات المتعددة مع إمكانية التصفح السريع.',
      'v_retail-grid_h0': 'تنسيق شبكي متعدد الأقسام',
      'v_retail-grid_h1': 'فلترة وسرعة تصفح فائقة',
      'v_retail-grid_h2': 'صور مكبرة بتفاصيل زووم عالية',
      'v_retail-grid_h3': 'زر الشراء المباشر الفوري',

      'v_retail-express_name': 'الشكل 3: الكتالوج السريع البسيط',
      'v_retail-express_badge': 'خيار السرعة ⚡',
      'v_retail-express_desc': 'صفحة واحدة خفيفة جداً تهدف للوصول السريع لزر الشراء بدون أي تعقيدات وبأقل وقت تحميل.',
      'v_retail-express_h0': 'تحميل فوري في أقل من ثانية',
      'v_retail-express_h1': 'تركيز مباشر على المنتج البطل',
      'v_retail-express_h2': 'أزرار واتساب واتصال ضخمة وبارزة',
      'v_retail-express_h3': 'تصميم مثالي للحملات الإعلانية',

      'v_retail-luxury_name': 'الشكل 4: الهوية الفاخرة والعصرية',
      'v_retail-luxury_badge': 'للماركات الفاخرة 💎',
      'v_retail-luxury_desc': 'خلفيات داكنة وتأثيرات مذهبة تناسب متاجر العطور، الساعات، المجوهرات، والعبايات الراعية.',
      'v_retail-luxury_h0': 'هوية داكنة وتأثيرات ذهبية راقية',
      'v_retail-luxury_h1': 'معرض فيديو وصور سينمائية',
      'v_retail-luxury_h2': 'قسم قصة العلامة التجارية ورسالتها',
      'v_retail-luxury_h3': 'زر تواصل فاخر ومخصص',

      // Corporate Variants
      'v_corp-classic_name': 'الشكل 1: الهوية المؤسسية الرسمية',
      'v_corp-classic_badge': 'النمط الرسمي 🏢',
      'v_corp-classic_desc': 'تبرز رؤية وقيم الشركة، خدماتها المؤسسية، مع زر مخصص لتحميل الكتالوج التسويقي PDF.',
      'v_corp-classic_h0': 'قسم من نحن ورؤية الشركة المستقبلية',
      'v_corp-classic_h1': 'كتالوج PDF للتحميل المباشر بنقرة واحدة',
      'v_corp-classic_h2': 'نموذج طلب تسعير وتواصل رسمي',
      'v_corp-classic_h3': 'عرض الشركاء واعتمادات الجودة',

      'v_corp-industrial_name': 'الشكل 2: العرض الصناعي واللوجستي',
      'v_corp-industrial_badge': 'للمصانع وخطوط الإنتاج 🏭',
      'v_corp-industrial_desc': 'استعراض خطوط الإنتاج والحلول اللوجستية بالصور التوضيحية والأرقام والمواصفات الفنية.',
      'v_corp-industrial_h0': 'جدول المواصفات والقدرة الإنتاجية',
      'v_corp-industrial_h1': 'عرض المعايير والشهادات الدولية',
      'v_corp-industrial_h2': 'خرائط الفروع ومواقع المصانع',
      'v_corp-industrial_h3': 'زر طلب توريد بالكميات والجملة',

      'v_corp-tech_name': 'الشكل 3: النمط التكنولوجي والمؤسسي',
      'v_corp-tech_badge': 'عصري وحديث 🚀',
      'v_corp-tech_desc': 'واجهة ذات أنماط عصرية تناسب شركات التقنية، البرمجيات، والمؤسسات الاستثمارية الحديثة.',
      'v_corp-tech_h0': 'عرض الخدمات والحلول الذكية',
      'v_corp-tech_h1': 'إحصائيات تفاعلية وأرقام إنجازات',
      'v_corp-tech_h2': 'تكامل مع البريد ووسائل التواصل',
      'v_corp-tech_h3': 'نموذج حجز اجتماعات واستشارات',

      'v_corp-express_name': 'الشكل 4: البروفايل السريع للشركة',
      'v_corp-express_badge': 'مناسب للحملات 🎯',
      'v_corp-express_desc': 'صفحة تعريفية مختصرة وأنيقة تضمن وصول العميل لبيانات التواصل والسجل التجاري في ثوانٍ.',
      'v_corp-express_h0': 'ملخص الكيان والإنجازات بسرعة',
      'v_corp-express_h1': 'روابط السجل التجاري والاعتمادات',
      'v_corp-express_h2': 'أزرار الاتصال بمدراء المبيعات مباشرة',
      'v_corp-express_h3': 'تحميل البطاقة الرقمية الذكية',

      // Services Variants
      'v_serv-advisory_name': 'الشكل 1: حجز الاستشارات التنفيذية',
      'v_serv-advisory_badge': 'للمكاتب والخبراء 💼',
      'v_serv-advisory_desc': 'مخصص للمحامين والمستشارين الماليين والهندسيين لحجز المواعيد والاستشارات الفورية.',
      'v_serv-advisory_h0': 'حجز مواعيد واستشارات فوري عبر الواتساب',
      'v_serv-advisory_h1': 'عرض مؤهلات وخبرات فريق العمل',
      'v_serv-advisory_h2': 'جدول أسعار الباقات الاستشارية',
      'v_serv-advisory_h3': 'آراء العملاء والتقييمات الموثقة',

      'v_serv-portfolio_name': 'الشكل 2: المعرض المكتبي المهني',
      'v_serv-portfolio_badge': 'للمكاتب الهندسية والديكور 📐',
      'v_serv-portfolio_desc': 'مناسب للمكاتب الهندسية وتصاميم الديكور لعرض المشاريع السابقة بصور مكبرة وجذابة.',
      'v_serv-portfolio_h0': 'معرض أعمال ومشاريع منجزة عالية الجودة',
      'v_serv-portfolio_h1': 'مقارنة قبل وبعد التنفيذ',
      'v_serv-portfolio_h2': 'حاسبة التكلفة المبدئية للخدمة',
      'v_serv-portfolio_h3': 'زر طلب معاينة أو زيارة ميدانية',

      'v_serv-quick_name': 'الشكل 3: بطاقة الخدمة المباشرة',
      'v_serv-quick_badge': 'خدمات فورية ⚡',
      'v_serv-quick_desc': 'مخصص لخدمات الصيانة، الفنيين، والخدمات الميدانية مع زر طلب الفني فوراً.',
      'v_serv-quick_h0': 'طلب الخدمة في 30 ثانية',
      'v_serv-quick_h1': 'تحديد نطاقات الخدمة والمحافظات',
      'v_serv-quick_h2': 'توضيح أسعار الكشفية والخدمات',
      'v_serv-quick_h3': 'أزرار اتصال واتساب وطوارئ مباشرة',

      'v_serv-branding_name': 'الشكل 4: الهوية الشخصية للخبراء',
      'v_serv-branding_badge': 'للعلامات الشخصية 🌟',
      'v_serv-branding_desc': 'يسلط الضوء على الخبير أو المستشار الفردي مع نبذة شخصية وإنجازات ومواعيد التواصل.',
      'v_serv-branding_h0': 'السيرة الذاتية والإنجازات البارزة',
      'v_serv-branding_h1': 'روابط وسائل التواصل والمحتوى',
      'v_serv-branding_h2': 'حجز جلسات استشارية زوم أو واتساب',
      'v_serv-branding_h3': 'معرض نماذج الأعمال الشخصية',

      // Cafe Variants
      'v_cafe-smart_name': 'الشكل 1: المنيو التفاعلي الذكي',
      'v_cafe-smart_badge': 'الأحدث بالمنطقة 🍕',
      'v_cafe-smart_desc': 'منيو إلكتروني ملون بالأصناف والأسعار مخصص لفتح الباركود QR Code داخل المطعم.',
      'v_cafe-smart_h0': 'منيو سريع الفتح عبر QR Code',
      'v_cafe-smart_h1': 'تصنيف الأطعمة والمشروبات بسهولة',
      'v_cafe-smart_h2': 'عرض المكونات والسعرات الحرارية',
      'v_cafe-smart_h3': 'زر الطلب والتوصيل المباشر',

      'v_cafe-lounge_name': 'الشكل 2: نمط اللاونج الداكن والأنيق',
      'v_cafe-lounge_badge': 'فخم ورائع ☕',
      'v_cafe-lounge_desc': 'طراز راقي وأجواء دافئة مخصصة للكافيهات والمطاعم الفاخرة للاونج وجلسات العوائل.',
      'v_cafe-lounge_h0': 'صور وفيديوهات سينمائية للأجواء',
      'v_cafe-lounge_h1': 'حجز الطاولات والجلسات الخاصة',
      'v_cafe-lounge_h2': 'قائمة المشروبات المختصة',
      'v_cafe-lounge_h3': 'خريطة الموقع والمواقف التفصيلية',

      'v_cafe-fastfood_name': 'الشكل 3: الوجبات السريعة والتوصيل',
      'v_cafe-fastfood_badge': 'الأكثر مبيعاً 🍔',
      'v_cafe-fastfood_desc': 'إبراز الوجبات الأكثر طلباً والعروض اليومية مع زر الطلب الفوري وتأكيد الفرع.',
      'v_cafe-fastfood_h0': 'عرض العروض اليومية والباقات العائلية',
      'v_cafe-fastfood_h1': 'ربط مباشر مع منصات التوصيل',
      'v_cafe-fastfood_h2': 'طلب سريع ومباشر عبر الواتساب',
      'v_cafe-fastfood_h3': 'أوقات العمل وفروع المطعم',

      'v_cafe-bakery_name': 'الشكل 4: الكافيه العصري والحلويات',
      'v_cafe-bakery_badge': 'تصميم مميز 🍰',
      'v_cafe-bakery_desc': 'ألوان مبهجة وعرض شهي للحلويات، المخبوزات والقهوة المختصة مع خيار طلب التورتات.',
      'v_cafe-bakery_h0': 'قسم مخصص لطلبات كيك المناسبات',
      'v_cafe-bakery_h1': 'قائمة القهوة المختصة والمحمصة',
      'v_cafe-bakery_h2': 'أوقات الدوام ورابط الحجز',
      'v_cafe-bakery_h3': 'روابط انستغرام وتيك توك المباشرة',

      // Features Section
      'feat_title': 'لماذا تختار خدمة SA لتطوير موقعك؟',
      'feat_sub': 'نوفر لك حلولاً سريعة واقتصادية دون التنازل عن الجودة والأناقة',
      'feat_1_title': 'تسليم رائع خلال 6 ساعات',
      'feat_1_desc': 'بدون انتظار أسابيع، استلم رابط موقعك المعاين وجاهز للنشر في نفس اليوم بعد إرسال بياناتك.',
      'feat_2_title': 'دومين مجاني للسنة الأولى',
      'feat_2_desc': 'نشتري ونربط لك اسم دومين خاص باسم محلك أو شركتك (.site / .online / .xyz) مجاناً.',
      'feat_3_title': '3 جولات تعديل مجانية',
      'feat_3_desc': 'نعطيك الحرية الكاملة لتغيير النصوص والصور والألوان للتأكد من الرضا التام قبل الإطلاق.',
      'feat_4_title': 'مطور بتقنية Flutter Web',
      'feat_4_desc': 'سرعة استجابة فائقة وتصميم مرن يعمل بسلاسة على شاشات الأيفون والسامسونج والكمبيوتر.',
      'feat_5_title': 'تحويل المبيعات للواتساب',
      'feat_5_desc': 'روابط واتساب مباشرة على المنتجات والخدمات تتيح للعميل الشراء والتواصل معك فوراً.',
      'feat_6_title': 'استضافة Vercel الفائقة',
      'feat_6_desc': 'موقعك مستضاف على أفضل السيرفرات العالمية مع حماية SSL وسرعة تحميل لا تتجاوز ثانية واحدة.',

      // Pricing Section
      'price_badge': '🏷️ العرض الأكثر طلباً بالسعودية',
      'price_title': 'باقة الصفحة التعريفية الشاملة',
      'price_sub': 'حل متكامل دون مصاريف خفية أو تجديدات معقدة',
      'price_amount': '299',
      'price_currency': 'ريال سعودي',
      'price_period': '/ دفعة واحدة',
      'price_includes': 'شاملة الدومين التأسيسي والتسليم خلال 6 ساعات',
      'price_cta_btn': 'ابتدئ طلبك الآن واستلم موقعك اليوم',
      'price_item_1': 'تصميم مخصص فائق الأناقة متوافق مع كافة الجوالات والأجهزة',
      'price_item_2': 'اسم دومين خاص لمجالك (.site / .online / .xyz) مجاناً للسنة الأولى',
      'price_item_3': 'إدراج منتجاتك، صورك، نصوصك، ومعلومات التواصل كاملة',
      'price_item_4': 'زر طلب وتواصل مباشر يوجه العملاء فوراً إلى رقم الواتساب الخاص بك',
      'price_item_5': 'ربط موقع المحل/الشركة على خرائط قوقل لتسهيل وصول العملاء',
      'price_item_6': '3 جولات تعديل مجانية بعد الاستلام لضمان الرضا التام 100%',
      'price_item_7': 'تسليم كامل للموقع مع الرابط المباشر خلال 6 ساعات من الاتفاق',

      // Order Modal
      'modal_title': 'اطلب موقعك الآن خلال 6 ساعات 🚀',
      'modal_sub': 'أدخل بياناتك وسيتم التواصل معك فوراً عبر الواتساب للبدء والتسليم',
      'lbl_name': 'الاسم الكامل / اسم المحل',
      'lbl_phone': 'رقم الواتساب (للتواصل والتسليم)',
      'lbl_notes': 'ملاحظات أو نوع النشاط (اختياري)',
      'btn_submit_order': 'تأكيد الطلب عبر الواتساب 💬',

      // Footer
      'footer_sub': '🇸🇦 خدمة خاصة ومخصصة لشركات ومحلات المملكة العربية السعودية | إحدى خدمات POM Agency | تطوير بواسطة Flutter Web ومستضاف على Vercel',
    },
    'en': {
      // Navbar & Hero
      'hero_badge': '6-Hour Delivery + Free Domain for 1 Full Year!',
      'hero_title': 'Landing Page For Your Business & Services\nBoost Sales & Trust For Only 299 SAR!',
      'hero_sub': 'Take your business, shop, or company digital without high costs. Get a blazing-fast professional website, fully responsive on mobile, connected directly to your WhatsApp.',
      'btn_order': 'Order Your Website Now (299 SAR)',
      'btn_demos': 'Explore Template Demos',
      'chip_domain': 'Free Domain (Year 1)',
      'chip_delivery': '6-Hour Delivery',
      'chip_edits': '3 Free Revisions',
      'chip_tech': 'Built with Flutter Web',
      'nav_features': 'Features',
      'nav_demos': 'Templates',
      'nav_pricing': 'Pricing',
      'nav_order': 'Order Now',
      'whatsapp_btn_top': 'Direct Chat',
      'whatsapp_btn_main': 'Sales WhatsApp 💬',

      // Demo Switcher Header
      'demo_badge_header': '4 Modern 3D Shapes Per Template Category',
      'demo_title': 'Live Interactive Template Demos',
      'demo_sub': 'Select your industry and discover unique 3D designs for your business',
      'demo_select_btn': 'Order This Design Now 🚀',
      'demo_live_preview': 'Free Live Preview ✨',
      'demo_included_title': 'Package Includes:',
      'demo_domain_prefix': 'Suggested Demo Domain: ',
      'demo_order_btn': 'Order This Template for 299 SAR (Domain Included)',

      // Categories
      'cat_retail_name': 'Retail & Shops',
      'cat_retail_desc': 'Custom landing pages for perfumes, watches, apparel, and physical products.',
      'cat_corp_name': 'Corporate & Industry',
      'cat_corp_desc': 'Official designs reflecting strong brand identity, factories, and logistics.',
      'cat_serv_name': 'Services & Consultancies',
      'cat_serv_desc': 'Ideal for consultancy firms, law offices, medical clinics, and real estate.',
      'cat_cafe_name': 'Cafes & Restaurants',
      'cat_cafe_desc': 'Interactive digital menu showcasing daily specials & table bookings.',

      // Retail Variants
      'v_retail-modern_name': 'Shape 1: Modern Store Showcase',
      'v_retail-modern_badge': 'Most Popular 🔥',
      'v_retail-modern_desc': 'Interactive glass card product grid, direct WhatsApp order button, and Google Maps integration.',
      'v_retail-modern_h0': 'High-resolution interactive product showcase',
      'v_retail-modern_h1': 'Direct WhatsApp order button per product',
      'v_retail-modern_h2': 'Full Google Maps store location integration',
      'v_retail-modern_h3': 'Ultra-fast & seamless on mobile screens',

      'v_retail-grid_name': 'Shape 2: Dynamic Grid Showcase',
      'v_retail-grid_badge': 'Great for Collections 🛍️',
      'v_retail-grid_desc': 'Organized grid layout for displaying multi-category products with quick browsing.',
      'v_retail-grid_h0': 'Multi-category grid layout',
      'v_retail-grid_h1': 'Ultra-fast filtering & browsing',
      'v_retail-grid_h2': 'High-res zoom product images',
      'v_retail-grid_h3': 'Instant direct buy button',

      'v_retail-express_name': 'Shape 3: Express Quick Catalog',
      'v_retail-express_badge': 'Speed Choice ⚡',
      'v_retail-express_desc': 'Lightweight single-page design for instant purchase access with sub-second loading.',
      'v_retail-express_h0': 'Sub-second instant load speed',
      'v_retail-express_h1': 'Direct hero product focus',
      'v_retail-express_h2': 'Prominent call & WhatsApp CTA buttons',
      'v_retail-express_h3': 'Ideal for ad campaigns',

      'v_retail-luxury_name': 'Shape 4: Luxury Brand Identity',
      'v_retail-luxury_badge': 'Luxury Brands 💎',
      'v_retail-luxury_desc': 'Dark background with gold accents suitable for perfumes, watches, jewelry & luxury wear.',
      'v_retail-luxury_h0': 'Dark premium identity & gold accents',
      'v_retail-luxury_h1': 'Cinematic image & video gallery',
      'v_retail-luxury_h2': 'Brand story & heritage section',
      'v_retail-luxury_h3': 'Custom luxury contact button',

      // Corporate Variants
      'v_corp-classic_name': 'Shape 1: Official Corporate Identity',
      'v_corp-classic_badge': 'Official Style 🏢',
      'v_corp-classic_desc': 'Highlights company vision, values, services, and a dedicated PDF catalog download.',
      'v_corp-classic_h0': 'About Us & company vision section',
      'v_corp-classic_h1': 'One-click direct PDF catalog download',
      'v_corp-classic_h2': 'Official RFQ & contact form',
      'v_corp-classic_h3': 'Partners & quality accreditations showcase',

      'v_corp-industrial_name': 'Shape 2: Industrial & Logistics',
      'v_corp-industrial_badge': 'Factories & Plants 🏭',
      'v_corp-industrial_desc': 'Showcases production lines and logistics solutions with specs and technical numbers.',
      'v_corp-industrial_h0': 'Production capacity & specs table',
      'v_corp-industrial_h1': 'International standards & ISO showcase',
      'v_corp-industrial_h2': 'Plant locations & branch map',
      'v_corp-industrial_h3': 'Wholesale & B2B order button',

      'v_corp-tech_name': 'Shape 3: Tech & Enterprise',
      'v_corp-tech_badge': 'Modern & Tech 🚀',
      'v_corp-tech_desc': 'Modern interface for tech companies, software firms, and investment institutions.',
      'v_corp-tech_h0': 'Smart solutions & tech services display',
      'v_corp-tech_h1': 'Interactive stats & achievement counters',
      'v_corp-tech_h2': 'Email & social media integration',
      'v_corp-tech_h3': 'Meeting & consultation booking form',

      'v_corp-express_name': 'Shape 4: Express Company Profile',
      'v_corp-express_badge': 'Great for Campaigns 🎯',
      'v_corp-express_desc': 'Concise profile ensuring clients reach contact data and commercial registry in seconds.',
      'v_corp-express_h0': 'Rapid entity summary & achievements',
      'v_corp-express_h1': 'CR & registration certificate links',
      'v_corp-express_h2': 'Direct sales managers call buttons',
      'v_corp-express_h3': 'Digital vCard download',

      // Services Variants
      'v_serv-advisory_name': 'Shape 1: Executive Advisory Booking',
      'v_serv-advisory_badge': 'For Experts & Offices 💼',
      'v_serv-advisory_desc': 'Tailored for lawyers, financial & engineering consultants for instant booking.',
      'v_serv-advisory_h0': 'Instant consultation booking via WhatsApp',
      'v_serv-advisory_h1': 'Team expertise & credentials section',
      'v_serv-advisory_h2': 'Consulting package pricing table',
      'v_serv-advisory_h3': 'Verified client testimonials & reviews',

      'v_serv-portfolio_name': 'Shape 2: Professional Portfolio Showcase',
      'v_serv-portfolio_badge': 'Engineering & Interiors 📐',
      'v_serv-portfolio_desc': 'Ideal for engineering firms & interior design studios to feature past projects.',
      'v_serv-portfolio_h0': 'High-res completed projects portfolio',
      'v_serv-portfolio_h1': 'Before & after execution sliders',
      'v_serv-portfolio_h2': 'Initial service cost estimation calculator',
      'v_serv-portfolio_h3': 'On-site inspection request button',

      'v_serv-quick_name': 'Shape 3: Direct On-Demand Service',
      'v_serv-quick_badge': 'Instant Services ⚡',
      'v_serv-quick_desc': 'Designed for maintenance, technicians & field services with instant dispatch.',
      'v_serv-quick_h0': '30-second rapid service request',
      'v_serv-quick_h1': 'Service coverage area & zones map',
      'v_serv-quick_h2': 'Transparent pricing & service fees',
      'v_serv-quick_h3': 'Emergency & direct WhatsApp call buttons',

      'v_serv-branding_name': 'Shape 4: Expert Personal Branding',
      'v_serv-branding_badge': 'Personal Brands 🌟',
      'v_serv-branding_desc': 'Highlights individual consultants & experts with biography and achievements.',
      'v_serv-branding_h0': 'Biography & key achievements',
      'v_serv-branding_h1': 'Social media & content channels',
      'v_serv-branding_h2': 'Zoom & WhatsApp consultation booking',
      'v_serv-branding_h3': 'Personal work portfolio gallery',

      // Cafe Variants
      'v_cafe-smart_name': 'Shape 1: Smart Interactive QR Menu',
      'v_cafe-smart_badge': 'Latest Trend 🍕',
      'v_cafe-smart_desc': 'Vibrant digital menu for in-restaurant QR code scanning.',
      'v_cafe-smart_h0': 'Instant QR code digital menu access',
      'v_cafe-smart_h1': 'Easy food & beverage categorization',
      'v_cafe-smart_h2': 'Calorie & ingredient breakdown',
      'v_cafe-smart_h3': 'Direct order & delivery button',

      'v_cafe-lounge_name': 'Shape 2: Luxury Dark Lounge',
      'v_cafe-lounge_badge': 'Premium & Chic ☕',
      'v_cafe-lounge_desc': 'Sophisticated dark theme for luxury lounges, specialty coffee & fine dining.',
      'v_cafe-lounge_h0': 'Cinematic ambience photos & videos',
      'v_cafe-lounge_h1': 'Private seating & table reservations',
      'v_cafe-lounge_h2': 'Specialty coffee & drinks menu',
      'v_cafe-lounge_h3': 'Detailed location map & valet info',

      'v_cafe-fastfood_name': 'Shape 3: Fast Food & Express Delivery',
      'v_cafe-fastfood_badge': 'Best Seller 🍔',
      'v_cafe-fastfood_desc': 'Highlights best sellers & daily deals with instant branch order button.',
      'v_cafe-fastfood_h0': 'Daily deals & family combos display',
      'v_cafe-fastfood_h1': 'Direct link to delivery apps',
      'v_cafe-fastfood_h2': 'Instant WhatsApp direct ordering',
      'v_cafe-fastfood_h3': 'Working hours & branch locations',

      'v_cafe-bakery_name': 'Shape 4: Bakery & Modern Cafe',
      'v_cafe-bakery_badge': 'Charming Design 🍰',
      'v_cafe-bakery_desc': 'Charming visual design for pastries, cakes & specialty roasters.',
      'v_cafe-bakery_h0': 'Custom occasion cake order section',
      'v_cafe-bakery_h1': 'Specialty roastery & coffee list',
      'v_cafe-bakery_h2': 'Opening hours & booking links',
      'v_cafe-bakery_h3': 'Direct Instagram & TikTok integration',

      // Features Section
      'feat_title': 'Why Choose SA Web Solutions?',
      'feat_sub': 'Fast, cost-effective digital solutions without compromising elegance & quality',
      'feat_1_title': 'Fast 6-Hour Delivery',
      'feat_1_desc': 'No waiting weeks! Get your live preview link ready on the same day after sending your details.',
      'feat_2_title': 'Free Domain (1st Year)',
      'feat_2_desc': 'We purchase & connect a custom domain (.site / .online / .xyz) for your brand for free.',
      'feat_3_title': '3 Free Revisions',
      'feat_3_desc': 'Complete freedom to adjust texts, images & colors until 100% satisfied.',
      'feat_4_title': 'Powered by Flutter Web',
      'feat_4_desc': 'Ultra-responsive performance running smoothly on iPhone, Android & PC.',
      'feat_5_title': 'Direct WhatsApp Leads',
      'feat_5_desc': 'Direct WhatsApp buttons allowing customers to inquire & buy instantly.',
      'feat_6_title': 'Vercel Super Hosting',
      'feat_6_desc': 'Hosted on world-class global edge servers with free SSL & sub-second loading.',

      // Pricing Section
      'price_badge': '🏷️ Most Popular Offer in KSA',
      'price_title': 'All-Inclusive Landing Page Package',
      'price_sub': 'Complete turn-key solution with zero hidden fees',
      'price_amount': '299',
      'price_currency': 'SAR',
      'price_period': '/ One-time fee',
      'price_includes': 'Includes custom domain & 6-hour delivery',
      'price_cta_btn': 'Start Your Order Now & Get Your Site Today',
      'price_item_1': 'Ultra-elegant custom design responsive on all mobile & desktop screens',
      'price_item_2': 'Custom brand domain name (.site / .online / .xyz) free for 1st year',
      'price_item_3': 'Full inclusion of your products, images, texts & contact info',
      'price_item_4': 'Direct WhatsApp order buttons routing customers straight to your phone',
      'price_item_5': 'Google Maps integration for easy customer navigation to your location',
      'price_item_6': '3 free revisions rounds after delivery guaranteeing 100% satisfaction',
      'price_item_7': 'Complete delivery with direct web link within 6 hours of agreement',

      // Order Modal
      'modal_title': 'Order Your Website in 6 Hours 🚀',
      'modal_sub': 'Enter your details and our team will contact you via WhatsApp immediately',
      'lbl_name': 'Full Name / Business Name',
      'lbl_phone': 'WhatsApp Number (for delivery)',
      'lbl_notes': 'Notes or Business Type (Optional)',
      'btn_submit_order': 'Confirm Order via WhatsApp 💬',

      // Footer
      'footer_sub': '🇸🇦 Dedicated web service for Saudi Arabian businesses & stores | A POM Agency service | Powered by Flutter Web & Vercel',
    },
  };

  static String tr(String key) {
    final langCode = currentLanguageNotifier.value.code;
    return _localizedValues[langCode]?[key] ?? _localizedValues['ar']?[key] ?? key;
  }

  static String getVariantName(TemplateVariant variant) {
    final key = 'v_${variant.id}_name';
    final val = tr(key);
    return (val != key && val.isNotEmpty) ? val : variant.name;
  }

  static String getVariantBadge(TemplateVariant variant) {
    final key = 'v_${variant.id}_badge';
    final val = tr(key);
    return (val != key && val.isNotEmpty) ? val : variant.badge;
  }

  static String getVariantDesc(TemplateVariant variant) {
    final key = 'v_${variant.id}_desc';
    final val = tr(key);
    return (val != key && val.isNotEmpty) ? val : variant.description;
  }

  static List<String> getVariantHighlights(TemplateVariant variant) {
    final List<String> result = [];
    for (int i = 0; i < variant.highlights.length; i++) {
      final key = 'v_${variant.id}_h$i';
      final val = tr(key);
      if (val != key && val.isNotEmpty) {
        result.add(val);
      } else {
        result.add(variant.highlights[i]);
      }
    }
    return result;
  }
}
