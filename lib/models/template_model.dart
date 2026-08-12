import 'package:flutter/material.dart';

class TemplateModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final String demoUrl;
  final List<String> features;

  const TemplateModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.demoUrl,
    required this.features,
  });

  static const List<TemplateModel> sampleTemplates = [
    TemplateModel(
      id: 'retail',
      title: 'قالب المتاجر والمحلات التجارية',
      category: 'التجارة والتجزئة',
      description: 'مثالي للمحلات، المعارض، ومتاجر الملابس والعطور لحرض المنتجات وأزرار الطلب الفوري عبر الواتساب.',
      icon: Icons.shopping_bag_rounded,
      demoUrl: 'retail.site',
      features: [
        'معرض منتجات تفاعلي عالي الدقة',
        'زر اطلب عبر الواتساب لكل منتج',
        'ربط موقع المحل على خرائط قوقل',
        'مريح وسريع جداً على شاشات الجوال',
      ],
    ),
    TemplateModel(
      id: 'corporate',
      title: 'قالب المصانع والشركات',
      category: 'B2B والشركات',
      description: 'صفحة تعريفية رسمية تبرز هوية الشركة، خدماتها، خطوط الإنتاج، مع إمكانية إرفاق ملف PDF للكتالوج.',
      icon: Icons.factory_rounded,
      demoUrl: 'factory-ksa.site',
      features: [
        'قسم من نحن ورؤية الشركة',
        'كتالوج PDF للتحميل المباشر',
        'نموذج طلب تسعير وتواصل',
        'شهادات الاعتماد وآراء العملاء',
      ],
    ),
    TemplateModel(
      id: 'services',
      title: 'قالب المهن والخدمات الاستشارية',
      category: 'الخدمات والاستشارات',
      description: 'مصمم للمكاتب الهندسية، المحاماة، المهن الحرة، والخدمات الفنية لجذب العملاء وزيادة المبيعات.',
      icon: Icons.engineering_rounded,
      demoUrl: 'services-expert.site',
      features: [
        'عرض الخدمات والأسعار بشكل منظم',
        'حجز استشارة فوري عبر الواتساب',
        'معرض الأعمال والشاريع المنجزة',
        'أرقام التواصل المباشرة والبريد',
      ],
    ),
    TemplateModel(
      id: 'cafe',
      title: 'قالب الكافيهات والمطاعم',
      category: 'الأغذية والمشروبات',
      description: 'منيو إلكتروني تفاعلي يعرض قائمة الطعام والمشروبات بالأسعار مع خيار الطلب أو الحجز.',
      icon: Icons.restaurant_rounded,
      demoUrl: 'cafe-demo.site',
      features: [
        'منيو إلكتروني منظم بالقطع والأسعار',
        'عرض العروض اليومية والتخفيضات',
        'خريطة الفرع وأوقات العمل',
        'سريع الفتح عبر QR Code',
      ],
    ),
  ];
}
