const functions = require('firebase-functions');
const fetch = require('node-fetch');

exports.fetchKluMenu = functions.https.onRequest(async (req, res) => {
  // CORS başlıklarını ekle
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    const response = await fetch(
      'https://sks.klu.edu.tr/Takvimler/73-yemek-takvimi.klu',
      {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'tr-TR,tr;q=0.9',
        },
        timeout: 15000,
      }
    );

    if (!response.ok) {
      res.status(response.status).send('KLU sitesine erişilemedi');
      return;
    }

    const html = await response.text();
    res.status(200).send(html);
  } catch (error) {
    console.error('Hata:', error);
    res.status(500).send('Sunucu hatası: ' + error.message);
  }
});
