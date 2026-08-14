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
      customerName = 'عميل كريم',
      customerPhone = '+201093706027',
      customerEmail = 'customer@ad-landing.com',
      businessName = 'طلب جديد',
      domainChoice = '',
      amount = 2990.00,
      currency = 'EGP',
    } = req.body || {};

    const profileId = 154004;
    const serverKey = 'SHJ9WHMT6Z-J9KRRLTHBG-2HBDZKRTWR';
    const cartId = `ORDER_${Date.now()}`;
    let description = `تصميم صفحة تعريفية لـ ${businessName}`;
    if (domainChoice) {
      description += ` + دومين ${domainChoice}`;
    }

    const payload = {
      profile_id: profileId,
      tran_type: 'sale',
      tran_class: 'ecom',
      cart_id: cartId,
      cart_description: description,
      cart_currency: currency,
      cart_amount: Number(amount) || 2990.00,
      customer_details: {
        name: customerName || 'عميل كريم',
        email: customerEmail || 'customer@ad-landing.com',
        phone: customerPhone || '+201093706027',
        street1: 'Online Order',
        city: 'Cairo',
        state: 'Cairo',
        country: 'EG',
      },
    };

    const response = await fetch('https://secure-egypt.paytabs.com/payment/request', {
      method: 'POST',
      headers: {
        'Authorization': serverKey,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    const data = await response.json();

    if (data.redirect_url) {
      res.status(200).json({
        success: true,
        redirect_url: data.redirect_url,
        tran_ref: data.tran_ref,
      });
    } else {
      res.status(400).json({
        success: false,
        error: data.message || 'Payment creation failed',
        data,
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message || 'Internal Server Error',
    });
  }
}
