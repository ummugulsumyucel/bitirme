import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

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
  static const String _newsUrl =
      'https://www.klu.edu.tr/Sayfa_Gruplari/84-haberler.klu/detay/';

  /// KLU haberler sayfasından haberleri çeker
  static Future<List<KluNews>> fetchNews() async {
    // Şimdilik fallback haberler kullan
    // TODO: KLU API entegrasyonu tamamlanacak
    print('Fallback haberler kullanılıyor');
    print('Haber 1 URL: ${_fallbackNews[0].url}');
    print('Haber 2 URL: ${_fallbackNews[1].url}');
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => _fallbackNews,
    );

    /* API entegrasyonu için kod (şimdilik devre dışı):
    try {
      final response = await http.get(
        Uri.parse(_newsUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final content = utf8.decode(response.bodyBytes);
        return _parseNewsFromHtml(content);
      }
    } catch (e) {
      print('Haberler yüklenirken hata: $e');
    }
    return _fallbackNews;
    */
  }

  /// HTML içeriğinden haberleri parse eder
  static List<KluNews> _parseNewsFromHtml(String htmlContent) {
    final List<KluNews> news = [];

    try {
      // Markdown içeriğini temizle ve tek satır yap
      final cleanContent = htmlContent
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ');

      print('Temizlenmiş içerik (ilk 500 karakter):');
      print(
        cleanContent.substring(
          0,
          cleanContent.length > 500 ? 500 : cleanContent.length,
        ),
      );

      // Pattern: (Ay Gün)[Başlık](URL) ... (Sayı) Okunma
      // Örnek: Nis 17[Rektörümüz...](https://...) ... 108 Okunma
      final pattern = RegExp(
        r'(Nis|Oca|Şub|Mar|May|Haz|Tem|Ağu|Eyl|Eki|Kas|Ara)\s+(\d{1,2})\[([^\]]+)\]\(([^)]+)\).*?(\d+)\s+Okunma',
        caseSensitive: false,
      );

      final matches = pattern.allMatches(cleanContent);

      print('Bulunan eşleşme sayısı: ${matches.length}');

      for (final match in matches) {
        final month = match.group(1);
        final day = match.group(2);
        final title = match.group(3);
        final url = match.group(4);
        final viewCount = match.group(5);

        if (title != null && url != null && title.length > 5) {
          news.add(
            KluNews(
              title: title.trim().toUpperCase(),
              url: url.startsWith('http') ? url : 'https://www.klu.edu.tr$url',
              date: '$day/$month/2026',
              views: '$viewCount okunma',
            ),
          );

          print(
            '✓ Haber eklendi: ${title.substring(0, title.length > 50 ? 50 : title.length)}...',
          );

          if (news.length >= 5) break;
        }
      }

      print('Toplam ${news.length} haber bulundu');
    } catch (e) {
      print('Parse hatası: $e');
    }

    return news.isNotEmpty ? news : _fallbackNews;
  }

  /// Fallback haberler (API çalışmazsa)
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
