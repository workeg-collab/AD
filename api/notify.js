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
      customerName = 'عميلنا العزيز',
      customerEmail = '',
      client_email = '',
      customerPhone = 'غير محدد',
      businessName = 'طلب جديد',
      category = 'غير محدد',
      domainChoice = '',
      notes = '',
      logoInfo = '',
      photosInfo = '',
      profileInfo = '',
      aboutContent = '',
      contactInfo = '',
      paymentMethod = 'طلب عبر الموقع',
      paymentUrl = '',
      orderAmount = '299.00 SAR (4,081.35 EGP شامل الضريبة 5%)',
    } = req.body || {};

    const targetClientEmail = (customerEmail || client_email || '').trim();
    const cleanDomain = (domainChoice || '').trim().toLowerCase();
    const spaceshipUrl = cleanDomain
      ? `https://www.spaceship.com/domain-search/?query=${encodeURIComponent(cleanDomain)}`
      : 'https://www.spaceship.com';

    const orderTime = new Date().toLocaleString('ar-SA', { timeZone: 'Asia/Riyadh' });
    const targetAdminEmail = 'sales@pom-agency.online';
    const sender = 'POM Agency <sales@pom-agency.online>';

    function formatFilesHtml(fileString) {
      if (!fileString) return '<span style="color: #94a3b8;">لم يتم إرفاق ملفات</span>';
      const urls = fileString.split(/[\s,|]+/).filter((s) => s.startsWith('http'));
      if (urls.length === 0) {
        return `<span style="color: #334155;">${fileString}</span>`;
      }
      return urls
        .map(
          (url, idx) =>
            `<a href="${url}" target="_blank" style="display: inline-block; background: #f1f5f9; border: 1px solid #cbd5e1; border-radius: 6px; padding: 5px 10px; margin: 3px 0; color: #2563eb; text-decoration: none; font-size: 13px; font-weight: bold;">📥 معاينة الملف ${idx + 1}</a>`
        )
        .join('<br/>');
    }

    const clientHtml = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="utf-8">
  <title>تأكيد استلام طلبك | POM Agency</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc; margin: 0; padding: 0; color: #1e293b; direction: rtl; }
    .container { max-width: 620px; margin: 25px auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #e2e8f0; }
    .header { background: linear-gradient(135deg, #0F172A 0%, #1E293B 100%); padding: 32px 24px; text-align: center; color: #ffffff; }
    .header h1 { margin: 0; font-size: 22px; font-weight: 800; letter-spacing: -0.5px; }
    .header p { margin: 8px 0 0 0; font-size: 14px; color: #94a3b8; }
    .badge { display: inline-block; background: #10B981; color: #ffffff; padding: 4px 14px; border-radius: 20px; font-size: 12px; font-weight: bold; margin-top: 10px; }
    .content { padding: 28px 24px; }
    .card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 18px; margin-bottom: 20px; }
    .card-title { font-size: 15px; font-weight: bold; color: #0f172a; margin-bottom: 12px; border-bottom: 1px solid #e2e8f0; padding-bottom: 8px; }
    .row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 13.5px; }
    .label { color: #64748b; font-weight: 600; }
    .value { color: #0f172a; font-weight: bold; text-align: left; }
    .price-box { background: linear-gradient(135deg, #10B981 0%, #059669 100%); color: #ffffff; padding: 18px; border-radius: 12px; text-align: center; margin-bottom: 20px; }
    .price-box .amount { font-size: 26px; font-weight: 900; }
    .notice-box { background: #fffbeb; border: 1px solid #fef3c7; border-right: 4px solid #f59e0b; border-radius: 8px; padding: 14px; margin-bottom: 20px; font-size: 13px; color: #92400e; line-height: 1.6; }
    .btn { display: block; background: #2563eb; color: #ffffff !important; text-align: center; padding: 14px 20px; border-radius: 10px; text-decoration: none; font-weight: bold; font-size: 15px; margin-top: 15px; }
    .footer { background: #f1f5f9; padding: 20px; text-align: center; font-size: 12px; color: #64748b; border-top: 1px solid #e2e8f0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🚀 تم استلام طلبك بنجاح!</h1>
      <p>أهلاً بك <strong>${customerName}</strong>، يسعدنا خدمتك في POM Agency</p>
      <div class="badge">التسليم خلال 6 ساعات ⚡</div>
    </div>

    <div class="content">
      <div class="notice-box">
        <strong>⚠️ تنبيه هام:</strong> هذا ملخص وتأكيد للطلب، وليس فاتورة ضريبية نهائية. سيتم إرسال الفاتورة الرسمية إليك لاحقاً.<br/>
        <small style="color: #b45309; display: block; margin-top: 4px; font-size: 11.5px; direction: ltr; text-align: left;">
          Notice: This is an order summary and confirmation, not a final tax invoice. An official invoice will be sent to you later.
        </small>
      </div>

      <div class="price-box">
        <div style="font-size: 13px; opacity: 0.9;">المبلغ الإجمالي للعرض</div>
        <div class="amount">${orderAmount}</div>
        <div style="font-size: 12px; opacity: 0.85; margin-top: 4px;">شامل الاستضافة، الدومين، التصميم وبرمجة الصفحة</div>
      </div>

      <div class="card">
        <div class="card-title">📌 بيانات الطلب والنشاط</div>
        <div class="row"><span class="label">اسم النشاط:</span><span class="value">${businessName}</span></div>
        <div class="row"><span class="label">رقم الهاتف / الواتساب:</span><span class="value">${customerPhone}</span></div>
        <div class="row"><span class="label">البريد الإلكتروني:</span><span class="value">${targetClientEmail}</span></div>
        <div class="row"><span class="label">تصنيف النشاط:</span><span class="value">${category}</span></div>
        <div class="row"><span class="label">الدومين المختار:</span><span class="value" style="color: #2563eb;">${domainChoice}</span></div>
        <div class="row"><span class="label">طريقة الدفع:</span><span class="value">${paymentMethod}</span></div>
        <div class="row"><span class="label">توقيت الطلب:</span><span class="value">${orderTime}</span></div>
      </div>

      <div class="card">
        <div class="card-title">📦 الملفات والمرفقات السحابية (Supabase)</div>
        <div style="margin-bottom: 10px;">
          <span class="label">🎨 الشعار / اللوجو:</span><br/>
          ${formatFilesHtml(logoInfo)}
        </div>
        <div style="margin-bottom: 10px;">
          <span class="label">📸 صور النشاط والمنتجات:</span><br/>
          ${formatFilesHtml(photosInfo)}
        </div>
        <div style="margin-bottom: 10px;">
          <span class="label">📄 بروفايل الشركة / الملفات:</span><br/>
          ${formatFilesHtml(profileInfo)}
        </div>
      </div>

      ${
        aboutContent || contactInfo || notes
          ? `
      <div class="card">
        <div class="card-title">📝 نصوص وملاحظات إضافية</div>
        ${aboutContent ? `<p style="font-size: 13px; margin: 6px 0;"><strong>المحتوى:</strong> ${aboutContent}</p>` : ''}
        ${contactInfo ? `<p style="font-size: 13px; margin: 6px 0;"><strong>بيانات التواصل:</strong> ${contactInfo}</p>` : ''}
        ${notes ? `<p style="font-size: 13px; margin: 6px 0;"><strong>ملاحظات خاصة:</strong> ${notes}</p>` : ''}
      </div>`
          : ''
      }

      ${
        paymentUrl
          ? `<a href="${paymentUrl}" target="_blank" class="btn" style="background: #10B981;">💳 اضغط هنا للدفع الإلكتروني الفوري (PayTabs)</a>`
          : ''
      }

      <a href="https://wa.me/201500682755" target="_blank" class="btn">💬 التواصل المباشر عبر الواتساب مع فريق العمل</a>
    </div>

    <div class="footer">
      <p style="margin: 0;">POM Agency • حلول الويب والتسويق الرقمي بالسعودية</p>
      <p style="margin: 4px 0 0 0;">البريد الرسمي: sales@pom-agency.online • هاتف: +201500682755</p>
    </div>
  </div>
</body>
</html>
    `;

    const adminHtml = `
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="utf-8">
  <title>🚨 طلب جديد وارد</title>
</head>
<body style="font-family: Arial, sans-serif; background: #f8fafc; padding: 20px; color: #0f172a; direction: rtl;">
  <div style="max-width: 600px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 24px; border: 1px solid #cbd5e1;">
    <h2 style="color: #dc2626; margin-top: 0;">🚨 إشعار طلب جديد وارد عبر الموقع</h2>
    <hr style="border: none; border-top: 1px solid #e2e8f0; margin: 15px 0;"/>
    
    <table style="width: 100%; font-size: 14px; line-height: 1.8;">
      <tr><td style="width: 140px; color: #64748b;"><strong>اسم العميل:</strong></td><td>${businessName || customerName}</td></tr>
      <tr><td style="color: #64748b;"><strong>البريد الإلكتروني:</strong></td><td><a href="mailto:${targetClientEmail}">${targetClientEmail}</a></td></tr>
      <tr><td style="color: #64748b;"><strong>رقم الواتساب:</strong></td><td><a href="https://wa.me/${customerPhone.replace(/[^0-9]/g, '')}">${customerPhone}</a></td></tr>
      <tr><td style="color: #64748b;"><strong>تصنيف النشاط:</strong></td><td>${category}</td></tr>
      <tr><td style="color: #64748b;"><strong>الدومين المطلوب:</strong></td><td><strong>${domainChoice || 'غير محدد'}</strong></td></tr>
      <tr><td style="color: #64748b;"><strong>طريقة الدفع:</strong></td><td>${paymentMethod}</td></tr>
      <tr><td style="color: #64748b;"><strong>المبلغ:</strong></td><td>${orderAmount}</td></tr>
      <tr><td style="color: #64748b;"><strong>رابط Spaceship للدومين:</strong></td><td><a href="${spaceshipUrl}">شراء الدومين</a></td></tr>
      <tr><td style="color: #64748b;"><strong>وقت الطلب:</strong></td><td>${orderTime}</td></tr>
    </table>

    <h3 style="margin-top: 20px; color: #1e293b; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;">📦 روابط الملفات السحابية (Supabase)</h3>
    <p><strong>الشعار / اللوجو:</strong><br/>${formatFilesHtml(logoInfo)}</p>
    <p><strong>صور النشاط والمنتجات:</strong><br/>${formatFilesHtml(photosInfo)}</p>
    <p><strong>بروفايل الشركة:</strong><br/>${formatFilesHtml(profileInfo)}</p>

    ${aboutContent ? `<p><strong>المحتوى المطلوب:</strong><br/>${aboutContent}</p>` : ''}
    ${contactInfo ? `<p><strong>بيانات التواصل:</strong><br/>${contactInfo}</p>` : ''}
    ${notes ? `<p><strong>ملاحظات:</strong><br/>${notes}</p>` : ''}
    ${paymentUrl ? `<p><strong>رابط PayTabs للعميل:</strong><br/><a href="${paymentUrl}">${paymentUrl}</a></p>` : ''}
  </div>
</body>
</html>
    `;

    // 1. Resend API Dispatch
    if (process.env.RESEND_API_KEY) {
      if (targetClientEmail) {
        try {
          await fetch('https://api.resend.com/emails', {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              from: sender,
              to: [targetClientEmail],
              subject: `تأكيد استلام طلبك لإنشاء صفحة تعريفية | POM Agency (${businessName})`,
              html: clientHtml,
            }),
          });
        } catch (_) {}
      }

      try {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: sender,
            to: [targetAdminEmail],
            subject: `🚨 طلب جديد: ${businessName || customerName} - (${targetClientEmail || customerPhone})`,
            html: adminHtml,
          }),
        });
      } catch (_) {}
    }

    // 2. Direct FormSubmit Dispatch to ensure delivery
    try {
      await fetch(`https://formsubmit.co/ajax/${targetAdminEmail}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
        body: JSON.stringify({
          _subject: `🚨 طلب جديد: ${businessName || customerName} (${targetClientEmail})`,
          _template: 'table',
          _captcha: 'false',
          'طريقة الطلب والدفع': paymentMethod,
          'اسم العميل أو النشاط': businessName || customerName,
          'البريد الإلكتروني للعميل': targetClientEmail || 'غير محدد',
          'رقم هاتف العميل': customerPhone,
          'تصنيف النشاط': category,
          'الدومين المطلوب': cleanDomain || 'غير محدد',
          'الشعار / اللوجو': logoInfo || 'بالواتساب',
          'صور النشاط والمنتجات': photosInfo || 'بالواتساب',
          'بروفايل الشركة': profileInfo || 'بالواتساب',
          'المبلغ الإجمالي': orderAmount,
          'رابط الدفع PayTabs': paymentUrl || 'لم ينشأ',
          'وقت الطلب': orderTime,
        }),
      });
    } catch (_) {}

    res.status(200).json({
      success: true,
      message: 'Order emails dispatched successfully.',
    });
  } catch (error) {
    console.error('Notify handler error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Internal Server Error',
    });
  }
}
