export const config = {
  api: {
    bodyParser: {
      sizeLimit: '15mb',
    },
  },
};

export default async function handler(req, res) {
  // CORS headers
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
    const { base64Data, fileName = 'file.bin', fileType = 'application/octet-stream' } = req.body || {};

    if (!base64Data) {
      res.status(400).json({ success: false, error: 'No base64 data provided' });
      return;
    }

    const buffer = Buffer.from(base64Data, 'base64');

    // 1. Primary: Catbox (Permanent free cloud storage)
    try {
      const formData = new FormData();
      formData.append('reqtype', 'fileupload');
      const blob = new Blob([buffer], { type: fileType });
      formData.append('fileToUpload', blob, fileName);

      const catboxRes = await fetch('https://catbox.moe/user/api.php', {
        method: 'POST',
        body: formData,
      });

      const fileUrl = (await catboxRes.text()).trim();

      if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
        res.status(200).json({
          success: true,
          fileUrl,
          fileName,
        });
        return;
      }
    } catch (_) {}

    // 2. Fallback: Litterbox Catbox
    try {
      const formData = new FormData();
      formData.append('reqtype', 'fileupload');
      formData.append('time', '72h');
      const blob = new Blob([buffer], { type: fileType });
      formData.append('fileToUpload', blob, fileName);

      const litterRes = await fetch('https://litterbox.catbox.moe/resources/internals/api.php', {
        method: 'POST',
        body: formData,
      });

      const fileUrl = (await litterRes.text()).trim();

      if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
        res.status(200).json({
          success: true,
          fileUrl,
          fileName,
        });
        return;
      }
    } catch (_) {}

    // 3. Fallback: Tmpfiles.org
    try {
      const formData = new FormData();
      const blob = new Blob([buffer], { type: fileType });
      formData.append('file', blob, fileName);

      const tmpRes = await fetch('https://tmpfiles.org/api/v1/upload', {
        method: 'POST',
        body: formData,
      });

      const tmpData = await tmpRes.json();
      const rawUrl = tmpData?.data?.url;
      if (rawUrl && rawUrl.includes('tmpfiles.org')) {
        const fileUrl = rawUrl.replace('tmpfiles.org/', 'tmpfiles.org/dl/');
        res.status(200).json({
          success: true,
          fileUrl,
          fileName,
        });
        return;
      }
    } catch (_) {}

    res.status(500).json({ success: false, error: 'All upload providers failed' });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message || 'Internal Server Error',
    });
  }
}
