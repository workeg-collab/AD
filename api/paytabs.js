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
      customerPhone = '+201500682755',
      customerEmail = 'customer@ad-landing.com',
      businessName = 'طلب جديد',
      domainChoice = '',
      amountSar = 299.00,
      sarToEgpRate = 13.53,
      taxPercent = 5.0,
    } = req.body || {};

    // 1. SAR: 299.00 SAR
    const sar = Number(amountSar || 299.00);
    // 2. USD: ~ $79.73 USD
    const usd = Number((sar / 3.75).toFixed(2));
    // 3. EGP Base (قبل الضريبة): 299 * 13.53 = 4,045.47 EGP
    const baseEgp = Number((sar * Number(sarToEgpRate || 13.53)).toFixed(2));
    // 4. Tax 5%: 4,045.47 * 0.05 = 202.27 EGP
    const taxEgp = Number((baseEgp * (Number(taxPercent || 5.0) / 100)).toFixed(2));
    // 5. Total with Tax: 4,045.47 + 202.27 = 4,247.74 EGP
    const totalEgp = Number((baseEgp + taxEgp).toFixed(2));

    const profileId = 154004;
    const serverKey = 'SHJ9WHMT6Z-J9KRRLTHBG-2HBDZKRTWR';
    const cartId = `ORDER_${Date.now()}`;
    let description = `تصميم صفحة لـ ${businessName} (299 SAR + TAX 5% = ${totalEgp} ج.م)`;
    if (domainChoice) {
      description += ` + دومين ${domainChoice}`;
    }

    const payload = {
      profile_id: profileId,
      tran_type: 'sale',
      tran_class: 'ecom',
      cart_id: cartId,
      cart_description: description,
      cart_currency: 'EGP',
      cart_amount: totalEgp,
      customer_details: {
        name: customerName || 'عميل كريم',
        email: customerEmail || 'customer@ad-landing.com',
        phone: customerPhone || '+201500682755',
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
