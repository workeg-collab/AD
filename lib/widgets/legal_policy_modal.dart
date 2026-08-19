import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/whatsapp_helper.dart';

class LegalPolicyModal extends StatefulWidget {
  final int initialTabIndex;

  const LegalPolicyModal({
    super.key,
    this.initialTabIndex = 0,
  });

  static Future<void> show(BuildContext context, {int initialTabIndex = 0}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LegalPolicyModal(initialTabIndex: initialTabIndex),
    );
  }

  @override
  State<LegalPolicyModal> createState() => _LegalPolicyModalState();
}

class _LegalPolicyModalState extends State<LegalPolicyModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.surfaceDark : Colors.white;
    final cardBg = isDark ? AppTheme.cardDark : const Color(0xFFF8FAFC);
    final textColor = isDark ? AppTheme.textWhite : AppTheme.textDark;
    final subTextColor = isDark ? AppTheme.textMutedDark : AppTheme.textMuted;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 32,
        vertical: isMobile ? 16 : 32,
      ),
      child: Container(
        width: isMobile ? double.infinity : 820,
        height: isMobile ? screenHeight * 0.88 : screenHeight * 0.82,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السياسات والشروط القانونية | Legal Policies',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'POM Agency - SA Web Solutions',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: subTextColor, size: 22),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                labelColor: AppTheme.primary,
                unselectedLabelColor: subTextColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.shield_outlined, size: 18),
                    text: 'سياسة الخصوصية وسرية البيانات',
                  ),
                  Tab(
                    icon: Icon(Icons.published_with_changes_rounded, size: 18),
                    text: 'سياسة التعديل والاسترجاع والإلغاء',
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Privacy Policy
                  _buildPrivacyPolicyTab(
                    context,
                    isMobile,
                    isDark,
                    textColor,
                    subTextColor,
                    cardBg,
                    borderColor,
                  ),

                  // Tab 2: Return, Modification & Refund Policy
                  _buildRefundPolicyTab(
                    context,
                    isMobile,
                    isDark,
                    textColor,
                    subTextColor,
                    cardBg,
                    borderColor,
                  ),
                ],
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.support_agent_rounded, size: 18, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'لأي استفسار قانوني أو دعم فني مباشر:',
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // WhatsApp Button
                      ElevatedButton.icon(
                        onPressed: () => WhatsAppHelper.launchWhatsApp(
                          customMessage: 'أهلاً POM Agency 👋، لدي استفسار بخصوص سياسات الخدمة والخصوصية.',
                        ),
                        icon: const Icon(Icons.chat_rounded, size: 15, color: Colors.white),
                        label: const Text('واتساب الدعم', style: TextStyle(fontSize: 12, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Email Button
                      OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse('mailto:sales@pom-agency.online?subject=Legal%20Inquiry%20-%20POM%20Agency');
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.email_outlined, size: 15, color: AppTheme.primary),
                        label: const Text('sales@pom-agency.online', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          side: const BorderSide(color: AppTheme.primary, width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyTab(
    BuildContext context,
    bool isMobile,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color cardBg,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro Alert Card
          _buildHighlightCard(
            icon: Icons.verified_user_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.08),
            borderColor: const Color(0xFF10B981).withValues(alpha: 0.3),
            title: 'التزامنا بحماية خصوصيتك وسرية بياناتك',
            description:
                'نحن في وكالة POM Agency نلتزم بحماية خصوصية عملائنا وزوارنا بأعلى معايير الأمان والشفافية. نضمن لك بقاء بياناتك سرية بالكامل وعدم بيعها أو مشاركتها مع أي طرف ثالث لأغراض دعائية أو تجارية.',
          ),
          const SizedBox(height: 20),

          // Section 1: Data Collection
          _buildPolicySection(
            icon: Icons.folder_shared_rounded,
            title: '1. البيانات التي نجمعها وطرق جمعها الآمنة',
            content:
                'نقوم بجمع المعلومات الضرورية فقط لمعالجة طلبك وإنشاء صفحتك التعريفية بدقة وسرعة، ويشمل ذلك:',
            bullets: [
              '📌 بيانات التواصل: الاسم، البريد الإلكتروني، ورقم الواتساب / الهاتف لتأكيد الطلب وإرسال التحديثات.',
              '🏢 بيانات النشاط التجاري: اسم النشاط أو المتجر، التصنيف والخدمات، والدومين المطلوب حجزه.',
              '🎨 ملفات الهوية والمحتوى: الشعارات (اللوجو)، صور المنتجات أو المنشأة، البروفايل التعريفي، ونصوص الصفحات.',
              '💳 بيانات الدفع: تتم معالجة المعاملات المالية بالكامل عبر بوابات دفع إلكترونية مشفرة ومعتمدة (مثل Kashier) دون تخزين أرقام بطاقاتك الائتمانية على خوادمنا.',
            ],
            textColor: textColor,
            subTextColor: subTextColor,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 16),

          // Section 2: Strict Confidentiality & Usage
          _buildPolicySection(
            icon: Icons.lock_outline_rounded,
            title: '2. سرية البيانات وأوجه استخدامها',
            content:
                'تُستخدم البيانات والمعلومات المرفوعة حصرياً للأغراض المحددة التالية:',
            bullets: [
              '✅ تصميم وتطوير وإطلاق الصفحة التعريفية الخاصة بك وفق أعلى معايير الجودة والسرعة.',
              '✅ ربط النطاق (الدومين) وضبط إعدادات الاستضافة السحابية وشهادات الأمان SSL.',
              '✅ إدارة التواصل معك بخصوص مسودة التصميم، التعديلات، والدعم الفني المستمر.',
              '⛔ عدم مشاركة البيانات: نؤكد بشكل قاطع عدم بيع أو تأجير أو مشاركة أي من بياناتك أو ملفاتك مع أطراف ثالثة أو شركات إعلانية نهائياً.',
            ],
            textColor: textColor,
            subTextColor: subTextColor,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 16),

          // Section 3: Cookies & Site Analytics
          _buildPolicySection(
            icon: Icons.cookie_rounded,
            title: '3. ملفات تعريف الارتباط (Cookies) وتحليلات الاستخدام',
            content:
                'يستخدم موقعنا ملفات تعريف الارتباط الأساسية وتقنيات التتبع غير المقتحمة بهدف:',
            bullets: [
              '⚡ تحسين سرعة التصفح وتذكر اللغة المختارة وتفضيلات العرض.',
              '📊 تحليل الأداء العام للموقع وسهولة الاستخدام لتطوير جودة خدماتنا.',
              '⚙️ يمكنك تعطيل ملفات تعريف الارتباط من إعدادات متصفحك في أي وقت دون أن يؤثر ذلك على قدرتك على تصفح عروضنا.',
            ],
            textColor: textColor,
            subTextColor: subTextColor,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 16),

          // English Summary Note
          _buildEnglishSummaryBox(
            title: 'English Summary - Privacy Policy',
            text:
                'POM Agency collects client contact details and business requirements strictly to design, build, and deploy custom landing pages. We maintain absolute confidentiality, use safe encrypted storage, never sell data to third parties, and utilize standard cookies solely for site performance and analytics.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRefundPolicyTab(
    BuildContext context,
    bool isMobile,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color cardBg,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro Alert Card
          _buildHighlightCard(
            icon: Icons.published_with_changes_rounded,
            iconColor: const Color(0xFF3B82F6),
            bgColor: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.12 : 0.08),
            borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            title: 'سياسة واضحة وعادلة للتعديلات والاسترجاع',
            description:
                'نحرص على رضا عملائنا بنسبة 100%، ونقدم نموذج عمل مرن يتضمن جولات تعديل مجانية لضمان تطابق الصفحة التعريفية مع تطلعاتك وهويتك التجارية.',
          ),
          const SizedBox(height: 20),

          // Section 1: Revisions & Timeframe
          _buildPolicySection(
            icon: Icons.edit_note_rounded,
            title: '1. جولات التعديل والمدة المحددة للملاحظات',
            content:
                'تتضمن باقة إنشاء الصفحة التعريفية جولات تعديل مخصصة خلال مرحلة التطوير:',
            bullets: [
              '🎯 التعديلات المشمولة: تشمل تعديل النصوص، استبدال الصور والشعارات، وتنسيق الألوان، وضبط الروابط وأرقام الواتساب.',
              '⏱️ مهلة إرسال الملاحظات: يُرجى تزويدنا بكافة الملاحظات مجمعة خلال 48 إلى 72 ساعة من استلام مسودة المعاينة لضمان سرعة التسليم النهائي.',
              '🚀 التسليم السريع: نسعى لتنفيذ التعديلات المعتمدة في أقصر وقت ممكن للحفاظ على التزامنا بالتسليم القياسي.',
            ],
            textColor: textColor,
            subTextColor: subTextColor,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 16),

          // Section 2: Refund Terms
          _buildPolicySection(
            icon: Icons.payments_outlined,
            title: '2. سياسة الاسترجاع المالي (Refund Policy)',
            content:
                'نظراً للطبيعة الرقمية المخصصة لخدمات تطوير الويب وتكاليف حجز النطاقات فوراً، تخضع طلبات الاسترداد للشروط التالية:',
            bullets: [
              '⚖️ تقييم فردي: يتم تقييم طلبات الاسترداد لكل حالة على حدة قبل التسليم والنشر النهائي على الدومين المباشر.',
              '🟢 قبل بدء العمل وحجز الدومين: في حال طلب الإلغاء قبل بدء تنفيذ التصميم أو شراء الدومين، يُسترد المبلغ كاملاً (مع خصم رسوم بوابة الدفع الإلكتروني إن وجدت).',
              '🔴 بعد النشر والتسليم النهائي: بمجرد اعتماد الصفحة ونشرها على الدومين وتسليم بيانات التحكم، تصبح الرسوم مستحقة بالكامل وغير قابلة للاسترداد.',
              '🌐 رسوم الدومينات: رسوم حجز أسماء النطاقات (الدومينات) لدى هيئات التسجيل العالمية غير قابلة للاسترداد فور تسجيلها.',
            ],
            textColor: textColor,
            subTextColor: subTextColor,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 16),

          // Section 3: Support & Change Requests
          _buildPolicySection(
            icon: Icons.mark_chat_read_rounded,
            title: '3. خطوات تقديم طلبات التعديل والدعم الفني',
            content:
                'لتقديم أي تعديل أو ملاحظات، يمكنك التواصل معنا مباشرة عبر إحدى الطرق التالية:',
            bullets: [
              '💬 رسائل الواتساب المباشرة: عبر رقم خدمة العملاء والمبيعات (00201500682755).',
              '✉️ البريد الإلكتروني الرسمي: إرسال الملاحظات والملفات إلى sales@pom-agency.online.',
              '⚡ سرعة الاستجابة: يقوم فريق الدعم بالرد والبدء في تنفيذ طلبات التعديل خلال 2 إلى 4 ساعات عمل.',
            ],
            textColor: textColor,
            subTextColor: subTextColor,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 16),

          // Section 4: Cancellation & Ownership
          _buildPolicySection(
            icon: Icons.workspace_premium_rounded,
            title: '4. شروط الإلغاء وحقوق الملكية الفكرية',
            content:
                'حقوق الملكية الفكرية وضمانات العميل:',
            bullets: [
              '👑 الملكية الكاملة: تنتقل الملكية الكاملة للصفحة التعريفية وتصاميمها ومحتواها للعميل بمجرد سداد رسوم الباقة بالكامل.',
              '📁 ملكية الأصول: يحتفظ العميل بكامل حقوق الملكية لعلامته التجارية، نصوصه، صوره، ومرفقاته.',
              '📋 في حال الإلغاء بالتراضي: قبل اكتمال المشروع، تتم التسوية بناءً على حجم المراحل المنجزة وتكاليف حجز النطاق.',
            ],
            textColor: textColor,
            subTextColor: subTextColor,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
          const SizedBox(height: 16),

          // English Summary Note
          _buildEnglishSummaryBox(
            title: 'English Summary - Return & Refund Policy',
            text:
                'Landing page packages include standard revision rounds during the development phase. Due to custom digital development and immediate domain registrations, refund requests are evaluated case-by-case before final live deployment. Full ownership rights of custom code and assets transfer to the client upon complete settlement.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required String content,
    required List<String> bullets,
    required Color textColor,
    required Color subTextColor,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 10),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                bullet,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnglishSummaryBox({
    required String title,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language_rounded, size: 15, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: isDark ? AppTheme.textMutedDark : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
