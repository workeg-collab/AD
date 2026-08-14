export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    const supabaseUrl = 'https://spvlwhdtpnfuenwrfayv.supabase.co';
    const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwdmx3aGR0cG5mdWVud3JmYXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY3MTgwNjMsImV4cCI6MjEwMjI5NDA2M30.1jc8ahuejtrfIRMTOFO-aVYMwOd7einjtUQdou2kNBY';
    const bucket = 'orders';

    const now = Date.now();
    const twentyFourHoursAgo = now - 24 * 60 * 60 * 1000;
    const deletedFiles = [];

    // Helper to recursively list and find old files
    async function scanAndCollectOldFiles(prefix = '') {
      const listRes = await fetch(`${supabaseUrl}/storage/v1/object/list/${bucket}`, {
        method: 'POST',
        headers: {
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          prefix: prefix,
          limit: 100,
        }),
      });

      if (!listRes.ok) return [];

      const items = await listRes.json();
      const filesToDelete = [];

      for (const item of items) {
        const itemPath = prefix ? `${prefix}/${item.name}` : item.name;

        // If item is a folder (id is null)
        if (!item.id && !item.metadata) {
          const subFiles = await scanAndCollectOldFiles(itemPath);
          filesToDelete.push(...subFiles);
        } else {
          // Check creation date or timestamp in filename
          let itemTime = item.created_at ? new Date(item.created_at).getTime() : 0;

          // If created_at is missing, extract timestamp from filename (e.g., logo_1786735501234.png)
          if (!itemTime || isNaN(itemTime)) {
            const match = item.name.match(/(\d{13})/);
            if (match) {
              itemTime = parseInt(match[1], 10);
            }
          }

          if (itemTime && itemTime < twentyFourHoursAgo) {
            filesToDelete.push(itemPath);
          }
        }
      }

      return filesToDelete;
    }

    const filesToDelete = await scanAndCollectOldFiles('');

    if (filesToDelete.length > 0) {
      // Delete collected old files in batches
      const deleteRes = await fetch(`${supabaseUrl}/storage/v1/object/${bucket}`, {
        method: 'DELETE',
        headers: {
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          prefixes: filesToDelete,
        }),
      });

      if (deleteRes.ok) {
        deletedFiles.push(...filesToDelete);
      }
    }

    res.status(200).json({
      success: true,
      message: `Cleaned up ${deletedFiles.length} files older than 24 hours.`,
      deletedCount: deletedFiles.length,
      deletedFiles,
    });
  } catch (error) {
    console.error('Cleanup error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}
