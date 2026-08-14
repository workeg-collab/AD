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

    // 1. Upload to Catbox (Permanent, free cloud storage for all file types: images, PDFs, docs)
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

    // 2. Fallback for images via Free ImgBB API
    if (fileType.startsWith('image/')) {
      try {
        const imgForm = new FormData();
        imgForm.append('image', base64Data);

        const imgbbRes = await fetch('https://api.imgbb.com/1/upload?key=2d0b57e4e03d4201712a76f2b43a9dc6', {
          method: 'POST',
          body: imgForm,
        });

        const imgbbData = await imgbbRes.json();
        if (imgbbData?.data?.url) {
          res.status(200).json({
            success: true,
            fileUrl: imgbbData.data.url,
            fileName,
          });
          return;
        }
      } catch (_) {}
    }

    // 3. Fallback for documents via File.io
    try {
      const fileioForm = new FormData();
      const blob = new Blob([buffer], { type: fileType });
      fileioForm.append('file', blob, fileName);

      const fileioRes = await fetch('https://file.io', {
        method: 'POST',
        body: fileioForm,
      });

      const fileioData = await fileioRes.json();
      if (fileioData?.link) {
        res.status(200).json({
          success: true,
          fileUrl: fileioData.link,
          fileName,
        });
        return;
      }
    } catch (_) {}

    res.status(500).json({ success: false, error: 'Could not upload file to cloud storage' });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message || 'Internal Server Error',
    });
  }
}
