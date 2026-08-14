export const config = {
  api: {
    bodyParser: {
      sizeLimit: '25mb',
    },
  },
};

export default async function handler(req, res) {
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

    const cleanBase64 = base64Data.includes(',') ? base64Data.split(',')[1] : base64Data;
    const fileBuffer = Buffer.from(cleanBase64, 'base64');

    const supabaseUrl = 'https://spvlwhdtpnfuenwrfayv.supabase.co';
    const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwdmx3aGR0cG5mdWVud3JmYXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY3MTgwNjMsImV4cCI6MjEwMjI5NDA2M30.1jc8ahuejtrfIRMTOFO-aVYMwOd7einjtUQdou2kNBY';
    const bucket = 'orders';

    const cleanFileName = fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
    const uniquePath = `${Date.now()}_${cleanFileName}`;
    const uploadUrl = `${supabaseUrl}/storage/v1/object/${bucket}/${uniquePath}`;

    const uploadRes = await fetch(uploadUrl, {
      method: 'POST',
      headers: {
        apikey: supabaseKey,
        Authorization: `Bearer ${supabaseKey}`,
        'Content-Type': fileType,
      },
      body: fileBuffer,
    });

    if (uploadRes.status === 200 || uploadRes.status === 201) {
      const publicUrl = `${supabaseUrl}/storage/v1/object/public/${bucket}/${uniquePath}`;
      res.status(200).json({
        success: true,
        fileUrl: publicUrl,
        fileName,
      });
      return;
    }

    const errorData = await uploadRes.text();
    res.status(500).json({ success: false, error: errorData });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}
