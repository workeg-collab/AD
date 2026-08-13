import 'package:flutter/material.dart';

class TemplateVariant {
  final String id;
  final String name;
  final String description;
  final String badge;
  final String demoUrl;
  final List<String> highlights;
  final Color themeColor;

  const TemplateVariant({
    required this.id,
    required this.name,
    required this.description,
    required this.badge,
    required this.demoUrl,
    required this.highlights,
    required this.themeColor,
  });
}

class TemplateModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final List<TemplateVariant> variants;

  const TemplateModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.variants,
  });

  static const List<TemplateModel> sampleTemplates = [
    TemplateModel(
      id: 'retail',
      title: 'قالب المتاجر والمحلات التجارية',
      category: 'التجارة والتجزئة',
      description: 'تصاميم مخصصة للمحلات، المعارض، ومتاجر الملابس والعطور لزيادة المبيعات والطلب الفوري.',
      icon: Icons.shopping_bag_rounded,
      variants: [
        TemplateVariant(
          id: 'retail-modern',
          name: 'الشكل 1: المتجر الحديث والمودرن',
          badge: 'الأكثر طلباً 🔥',
          description: 'عرض منتجات بنظام كروت تفاعلية زجاجية، زر طلب واتساب مباشر، وربط مع الموقع الجغرافي للمحل.',
          demoUrl: 'retail-modern.site',
          highlights: [
            'معرض منتجات تفاعلي عالي الدقة',
            'زر اطلب عبر الواتساب لكل منتج',
            'تكامل كامل مع موقع المحل على قوقل ماب',
            'مريح وسريع جداً على شاشات الجوال',
          ],
          themeColor: Color(0xFF00E676),
        ),
        TemplateVariant(
          id: 'retail-grid',
          name: 'الشكل 2: المعرض الشبكي الديناميكي',
          badge: 'مناسب للمجموعات 🛍️',
          description: 'تنسيق شبكي منظم لعرض عشرات المنتجات والتصنيفات المتعددة مع إمكانية التصفح السريع.',
          demoUrl: 'retail-grid.site',
          highlights: [
            'تنسيق شبكي متعدد الأقسام',
            'فلترة وسرعة تصفح فائقة',
            'صور مكبرة بتفاصيل زووم عالية',
            'زر الشراء المباشر الفوري',
          ],
          themeColor: Color(0xFF00B0FF),
        ),
        TemplateVariant(
          id: 'retail-express',
          name: 'الشكل 3: الكتالوج السريع البسيط',
          badge: 'خيار السرعة ⚡',
          description: 'صفحة واحدة خفيفة جداً تهدف للوصول السريع لزر الشراء بدون أي تعقيدات وبأقل وقت تحميل.',
          demoUrl: 'retail-express.site',
          highlights: [
            'تحميل فوري في أقل من ثانية',
            'تركيز مباشر على المنتج البطل',
            'أزرار واتساب واتصال ضخمة وبارزة',
            'تصميم مثالي للحملات الإعلانية',
          ],
          themeColor: Color(0xFFFF9100),
        ),
        TemplateVariant(
          id: 'retail-luxury',
          name: 'الشكل 4: الهوية الفاخرة والعصرية',
          badge: 'للماركات الفاخرة 💎',
          description: 'خلفيات داكنة وتأثيرات مذهبة تناسب متاجر العطور، الساعات، المجوهرات، والعبايات الراعية.',
          demoUrl: 'retail-luxury.site',
          highlights: [
            'هوية داكنة وتأثيرات ذهبية راقية',
            'معرض فيديو وصور سينمائية',
            'قسم قصة العلامة التجارية ورسالتها',
            'زر تواصل فاخر ومخصص',
          ],
          themeColor: Color(0xFFFFD700),
        ),
      ],
    ),
    TemplateModel(
      id: 'corporate',
      title: 'قالب المصانع والشركات',
      category: 'B2B والشركات',
      description: 'واجهات رسمية تبرز قوة الشركات والمصانع مع إمكانية إضافة كتالوج المنتجات بنواذة PDF.',
      icon: Icons.factory_rounded,
      variants: [
        TemplateVariant(
          id: 'corp-classic',
          name: 'الشكل 1: الهوية المؤسسية الرسمية',
          badge: 'النمط الرسمي 🏢',
          description: 'تبرز رؤية وقيم الشركة، خدماتها المؤسسية، مع زر مخصص لتحميل الكتالوج التسويقي PDF.',
          demoUrl: 'factory-corporate.site',
          highlights: [
            'قسم من نحن ورؤية الشركة المستقبلية',
            'كتالوج PDF للتحميل المباشر بنقرة واحدة',
            'نموذج طلب تسعير وتواصل رسمي',
            'عرض الشركاء واعتمادات الجودة',
          ],
          themeColor: Color(0xFF2979FF),
        ),
        TemplateVariant(
          id: 'corp-industrial',
          name: 'الشكل 2: العرض الصناعي واللوجستي',
          badge: 'للمصانع وخطوط الإنتاج 🏭',
          description: 'استعراض خطوط الإنتاج والحلول اللوجستية بالصور التوضيحية والأرقام والمواصفات الفنية.',
          demoUrl: 'factory-industrial.site',
          highlights: [
            'جدول المواصفات والقدرة الإنتاجية',
            'عرض المعايير والشهادات الدولية',
            'خرائط الفروع ومواقع المصانع',
            'زر طلب توريد بالكميات والجملة',
          ],
          themeColor: Color(0xFFFF3D00),
        ),
        TemplateVariant(
          id: 'corp-tech',
          name: 'الشكل 3: النمط التكنولوجي والمؤسسي',
          badge: 'عصري وحديث 🚀',
          description: 'واجهة ذات أنماط عصرية تناسب شركات التقنية، البرمجيات، والمؤسسات الاستثمارية الحديثة.',
          demoUrl: 'tech-enterprise.site',
          highlights: [
            'عرض الخدمات والحلول الذكية',
            'إحصائيات تفاعلية وأرقام إنجازات',
            'تكامل مع البريد ووسائل التواصل',
            'نموذج حجز اجتماعات واستشارات',
          ],
          themeColor: Color(0xFF651FFF),
        ),
        TemplateVariant(
          id: 'corp-express',
          name: 'الشكل 4: البروفايل السريع للشركة',
          badge: 'مناسب للحملات 🎯',
          description: 'صفحة تعريفية مختصرة وأنيقة تضمن وصول العميل لبيانات التواصل والسجل التجاري في ثوانٍ.',
          demoUrl: 'express-profile.site',
          highlights: [
            'ملخص الكيان والإنجازات بسرعة',
            'روابط السجل التجاري والاعتمادات',
            'أزرار الاتصال بمدراء المبيعات مباشرة',
            'تحميل البطاقة الرقمية الذكية',
          ],
          themeColor: Color(0xFF00E5FF),
        ),
      ],
    ),
    TemplateModel(
      id: 'services',
      title: 'قالب المهن والخدمات الاستشارية',
      category: 'الخدمات والاستشارات',
      description: 'مصمم للمكاتب الهندسية، المحاماة، المهن الحرة، والخدمات الفنية لجذب العملاء واستقبال الطلبات.',
      icon: Icons.engineering_rounded,
      variants: [
        TemplateVariant(
          id: 'serv-advisory',
          name: 'الشكل 1: حجز الاستشارات التنفيذية',
          badge: 'للمكاتب والخبراء 💼',
          description: 'مخصص للمحامين والمستشارين الماليين والهندسيين لحجز المواعيد والاستشارات الفورية.',
          demoUrl: 'services-expert.site',
          highlights: [
            'حجز مواعيد واستشارات فوري عبر الواتساب',
            'عرض مؤهلات وخبرات فريق العمل',
            'جدول أسعار الباقات الاستشارية',
            'آراء العملاء والتقييمات الموثقة',
          ],
          themeColor: Color(0xFFFFAB00),
        ),
        TemplateVariant(
          id: 'serv-portfolio',
          name: 'الشكل 2: المعرض المكتبي المهني',
          badge: 'للمكاتب الهندسية والديكور 📐',
          description: 'مناسب للمكاتب الهندسية وتصاميم الديكور لعرض المشاريع السابقة بصور مكبرة وجذابة.',
          demoUrl: 'services-portfolio.site',
          highlights: [
            'معرض أعمال ومشاريع منجزة عالية الجودة',
            'مقارنة قبل وبعد التنفيذ',
            'حاسبة التكلفة المبدئية للخدمة',
            'زر طلب معاينة أو زيارة ميدانية',
          ],
          themeColor: Color(0xFF00BFA5),
        ),
        TemplateVariant(
          id: 'serv-quick',
          name: 'الشكل 3: بطاقة الخدمة المباشرة',
          badge: 'خدمات فورية ⚡',
          description: 'مخصص لخدمات الصيانة، الفنيين، والخدمات الميدانية مع زر طلب الفني فوراً.',
          demoUrl: 'services-quick.site',
          highlights: [
            'طلب الخدمة في 30 ثانية',
            'تحديد نطاقات الخدمة والمحافظات',
            'توضيح أسعار الكشفية والخدمات',
            'أزرار اتصال واتساب وطوارئ مباشرة',
          ],
          themeColor: Color(0xFFFF1744),
        ),
        TemplateVariant(
          id: 'serv-branding',
          name: 'الشكل 4: الهوية الشخصية للخبراء',
          badge: 'للعلامات الشخصية 🌟',
          description: 'يسلط الضوء على الخبير أو المستشار الفردي مع نبذة شخصية وإنجازات ومواعيد التواصل.',
          demoUrl: 'expert-branding.site',
          highlights: [
            'السيرة الذاتية والإنجازات البارزة',
            'روابط وسائل التواصل والمحتوى',
            'حجز جلسات استشارية زوم أو واتساب',
            'معرض نماذج الأعمال الشخصية',
          ],
          themeColor: Color(0xFFD500F9),
        ),
      ],
    ),
    TemplateModel(
      id: 'cafe',
      title: 'قالب الكافيهات والمطاعم',
      category: 'الأغذية والمشروبات',
      description: 'منيو إلكتروني تفاعلي يعرض قائمة الطعام والمشروبات بالأسعار مع خيار الطلب أو الحجز.',
      icon: Icons.restaurant_rounded,
      variants: [
        TemplateVariant(
          id: 'cafe-smart',
          name: 'الشكل 1: المنيو التفاعلي الذكي',
          badge: 'الأحدث بالمنطقة 🍕',
          description: 'منيو إلكتروني ملون بالأصناف والأسعار مخصص لفتح الباركود QR Code داخل المطعم.',
          demoUrl: 'cafe-smartmenu.site',
          highlights: [
            'منيو سريع الفتح عبر QR Code',
            'تصنيف الأطعمة والمشروبات بسهولة',
            'عرض المكونات والسعرات الحرارية',
            'زر الطلب والتوصيل المباشر',
          ],
          themeColor: Color(0xFFFF6D00),
        ),
        TemplateVariant(
          id: 'cafe-lounge',
          name: 'الشكل 2: نمط اللاونج الداكن والأنيق',
          badge: 'فخم ورائع ☕',
          description: 'طراز راقي وأجواء دافئة مخصصة للكافيهات والمطاعم الفاخرة للاونج وجلسات العوائل.',
          demoUrl: 'lounge-dark.site',
          highlights: [
            'صور وفيديوهات سينمائية للأجواء',
            'حجز الطاولات والجلسات الخاصة',
            'قائمة المشروبات المختصة',
            'خريطة الموقع والمواقف التفصيلية',
          ],
          themeColor: Color(0xFFAA00FF),
        ),
        TemplateVariant(
          id: 'cafe-fastfood',
          name: 'الشكل 3: الوجبات السريعة والتوصيل',
          badge: 'الأكثر مبيعاً 🍔',
          description: 'إبراز الوجبات الأكثر طلباً والعروض اليومية مع زر الطلب الفوري وتأكيد الفرع.',
          demoUrl: 'fastfood-express.site',
          highlights: [
            'عرض العروض اليومية والباقات العائلية',
            'ربط مباشر مع منصات التوصيل',
            'طلب سريع ومباشر عبر الواتساب',
            'أوقات العمل وفروع المطعم',
          ],
          themeColor: Color(0xFFDD2C00),
        ),
        TemplateVariant(
          id: 'cafe-bakery',
          name: 'الشكل 4: الكافيه العصري والحلويات',
          badge: 'تصميم مميز 🍰',
          description: 'ألوان مبهجة وعرض شهي للحلويات، المخبوزات والقهوة المختصة مع خيار طلب التورتات.',
          demoUrl: 'bakery-cafe.site',
          highlights: [
            'قسم مخصص لطلبات كيك المناسبات',
            'قائمة القهوة المختصة والمحمصة',
            'أوقات الدوام ورابط الحجز',
            'روابط انستغرام وتيك توك المباشرة',
          ],
          themeColor: Color(0xFFC51162),
        ),
      ],
    ),
  ];
}

