export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method Not Allowed' });
    return;
  }

  try {
    const {
      customerName = 'غير محدد',
      customerPhone = 'غير محدد',
      businessName = 'طلب جديد',
      category = 'غير محدد',
      domainChoice = '',
      notes = '',
      paymentMethod = 'طلب عبر الموقع',
      paymentUrl = '',
    } = req.body || {};

    const cleanDomain = (domainChoice || '').trim().toLowerCase();
    const spaceshipUrl = cleanDomain
      ? `https://www.spaceship.com/domain-search/?query=${encodeURIComponent(cleanDomain)}`
      : 'https://www.spaceship.com';

    const orderTime = new Date().toLocaleString('ar-SA', { timeZone: 'Asia/Riyadh' });
    const targetEmail = 'sales@pom-agency.online';
    const emailSubject = `🚨 إشعار طلب جديد: ${businessName || customerName} (${paymentMethod})`;

    let emailBody = `
========================================
🚨 إشعار طلب جديد - POM Agency 🚨
========================================
- طريقة الطلب/الدفع: ${paymentMethod}
- اسم العميل/النشاط: ${businessName || customerName}
- رقم هاتف العميل: ${customerPhone}
- تصنيف النشاط: ${category}
- الدومين المطلوب: ${cleanDomain || 'سيتم اختياره مع العميل'}

🛒 رابط شراء الدومين المباشر (Spaceship للإدارة):
${spaceshipUrl}
`;

    if (paymentUrl) {
      emailBody += `
💳 رابط الدفع الإلكتروني (PayTabs للعميل):
${paymentUrl}
`;
    }

    emailBody += `
💰 تفاصيل الحساب:
- السعر بالريال: 299.00 SAR ($79.73 USD)
- السعر بالمصري: 3,887.00 ج.م
- ضريبة TAX 5%: + 194.35 ج.م
- الإجمالي النهائي للدفع: 4,081.35 ج.م

📝 ملاحظات إضافية: ${notes || 'لا يوجد'}
⏰ توقيت الطلب: ${orderTime} (توقيت الرياض)
========================================
    `.trim();

    // 1. Resend API (if configured in environment)
    if (process.env.RESEND_API_KEY) {
      try {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: 'POM Orders <orders@pom-agency.online>',
            to: [targetEmail],
            subject: emailSubject,
            text: emailBody,
          }),
        });
      } catch (_) {}
    }

    // 2. Direct FormSubmit Email Dispatcher to sales@pom-agency.online
    try {
      await fetch(`https://formsubmit.co/ajax/${targetEmail}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: JSON.stringify({
          _subject: emailSubject,
          _template: 'table',
          _captcha: 'false',
          'طريقة الطلب والدفع': paymentMethod,
          'اسم العميل أو النشاط': businessName || customerName,
          'رقم هاتف العميل': customerPhone,
          'تصنيف النشاط': category,
          'الدومين المطلوب': cleanDomain || 'غير محدد',
          'رابط شراء الدومين (Spaceship للإدارة)': spaceshipUrl,
          'المبلغ الإجمالي': '299 SAR (4,081.35 EGP شامل TAX 5%)',
          'ملاحظات إضافية': notes || 'لا يوجد',
          'وقت الطلب': orderTime,
        }),
      });
    } catch (_) {}

    res.status(200).json({
      success: true,
      message: `Notification sent successfully to ${targetEmail}`,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message || 'Internal Server Error',
    });
  }
}
