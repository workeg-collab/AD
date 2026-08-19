import crypto from 'crypto';

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

    const sar = Number(amountSar || 299.00);
    const baseEgp = Number((sar * Number(sarToEgpRate || 13.53)).toFixed(2));
    const taxEgp = Number((baseEgp * (Number(taxPercent || 5.0) / 100)).toFixed(2));
    const totalEgp = Number((baseEgp + taxEgp).toFixed(2));

    const merchantId = 'MID-49511-925';
    const apiKey =
      'e52fac37d9b4237a55fa1b9ca745e8c3$57813ce0ee96d77d421e225a35032b347380c1c507a86c2230283bfa189b8a9d9cc952af190c71b3fc10d50dffd1b34f';
    const orderId = `ORDER_${Date.now()}`;
    const currency = 'EGP';
    const amount = totalEgp.toFixed(2);

    const path = `/?payment=${merchantId}.${orderId}.${amount}.${currency}`;
    const hash = crypto.createHmac('sha256', apiKey).update(path).digest('hex');

    const metaData = JSON.stringify({
      customerName,
      customerPhone,
      customerEmail,
      businessName,
      domainChoice,
    });

    const redirectUrl = `https://checkout.kashier.io/?merchantId=${merchantId}&orderId=${orderId}&amount=${amount}&currency=${currency}&hash=${hash}&mode=live&metaData=${encodeURIComponent(metaData)}&merchantRedirect=${encodeURIComponent('https://sa.pom-agency.online')}&display=ar`;

    res.status(200).json({
      success: true,
      redirect_url: redirectUrl,
      order_id: orderId,
      amount: totalEgp,
      currency: 'EGP',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message || 'Internal Server Error',
    });
  }
}
