import 'package:flutter/foundation.dart' show debugPrint;

class KluNews {
  final String title;
  final String? imageUrl;
  final String? date;
  final String url;
  final String? department;
  final String? views;
  final String? description;

  const KluNews({
    required this.title,
    this.imageUrl,
    this.date,
    required this.url,
    this.department,
    this.views,
    this.description,
  });
}

class KluNewsService {
  /// KLU haberler sayfasından haberleri çeker (şimdilik fallback)
  static Future<List<KluNews>> fetchNews() async {
    debugPrint('KluNewsService: fallback haberler kullanılıyor');
    return Future.delayed(
      const Duration(milliseconds: 300),
      () => _fallbackNews,
    );
  }

  static const List<KluNews> _fallbackNews = [
    KluNews(
      title: 'REKTÖRÜMÜZ TURİZM HAFTASI RESEPSİYONUNA KATILDI',
      url:
          'https://kurumsaliletisim.klu.edu.tr/Sayfalar/43628-rektorumuz-turizm-haftasi-resepsiyonuna-katildi.klu',
      date: '17/04/2026',
      views: '108 okunma',
    ),
    KluNews(
      title:
          'ÜNİVERSİTEMİZ İLE TÜBİTAK MAM ARASINDA İŞ BİRLİĞİ OLANAKLARI GÖRÜŞÜLDÜ',
      url:
          'https://kurumsaliletisim.klu.edu.tr/Sayfalar/43626-universitemiz-ile-tubitak-mam-arasinda-is-birligi-olanaklari-gorusuldu.klu',
      date: '17/04/2026',
      views: '66 okunma',
    ),
    KluNews(
      title:
          'ASES 2. ULUSLARARASI KIRKLARELİ BİLİMSEL ÇALIŞMALAR KONGRESİ AÇILIŞ PROGRAMI GERÇEKLEŞTİRİLDİ',
      url:
          'https://kurumsaliletisim.klu.edu.tr/Sayfalar/43624-ases-2-uluslararasi-kirklareli-bilimsel-calismalar-kongresi-acilis-programi-gerceklestirildi.klu',
      date: '17/04/2026',
      views: '262 okunma',
    ),
    KluNews(
      title: 'ÜNİVERSİTE ADAYI ÖĞRENCİLER LÜLEBURGAZ YERLEŞKESİNİ GEZDİ',
      url:
          'https://kurumsaliletisim.klu.edu.tr/Sayfalar/43622-universite-adayi-ogrenciler-luleburgaz-yerlesekesini-gezdi.klu',
      date: '17/04/2026',
      views: '149 okunma',
    ),
  ];
}
