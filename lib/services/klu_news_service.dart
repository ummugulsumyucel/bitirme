import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

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
  // Önbellek: son çekilen haberler ve zaman damgası
  static List<KluNews>? _cache;
  static DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 30);

  /// KLU haberler sayfasından güncel haberleri çeker.
  /// 30 dakika önbellek kullanır; başarısız olursa fallback döner.
  static Future<List<KluNews>> fetchNews() async {
    // Önbellek geçerliyse direkt döndür
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      debugPrint(
        '[KluNewsService] Önbellekten ${_cache!.length} haber döndürüldü',
      );
      return _cache!;
    }

    try {
      final result = await _fetchFromWeb();
      if (result.isNotEmpty) {
        _cache = result;
        _cacheTime = DateTime.now();
        debugPrint('[KluNewsService] Web\'den ${result.length} haber çekildi');
        return result;
      }
    } catch (e) {
      debugPrint('[KluNewsService] Web çekme hatası: $e');
    }

    // Web başarısız → önbellek varsa eski veriyi kullan
    if (_cache != null && _cache!.isNotEmpty) {
      debugPrint('[KluNewsService] Eski önbellek kullanılıyor');
      return _cache!;
    }

    // Son çare: fallback
    debugPrint('[KluNewsService] Fallback haberler kullanılıyor');
    return fallbackNews.take(6).toList();
  }

  /// Önbelleği temizler (zorla yenileme için)
  static void clearCache() {
    _cache = null;
    _cacheTime = null;
  }

  // ── Web scraping ──────────────────────────────────────────────────────────

  static Future<List<KluNews>> _fetchFromWeb() async {
    const url = 'https://www.klu.edu.tr/Sayfa_Gruplari/74-duyurular.klu/detay';

    final response = await http
        .get(
          Uri.parse(url),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'text/html,application/xhtml+xml',
            'Accept-Language': 'tr-TR,tr;q=0.9',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    return _parseNewsPage(response.body);
  }

  static List<KluNews> _parseNewsPage(String body) {
    final document = html_parser.parse(body);
    final news = <KluNews>[];

    // Önce link tabanlı parse dene - her haberin kendi URL'sini al
    final newsLinks = document.querySelectorAll('a[href*="/Sayfalar/"]');

    for (final link in newsLinks) {
      if (news.length >= 6) break;

      final href = link.attributes['href'] ?? '';
      if (href.isEmpty || !href.contains('.klu')) continue;

      // Başlığı al
      var title = link.text.trim();
      if (title.isEmpty || title.length < 10) continue;

      // Gereksiz metinleri temizle
      title = title
          .replaceAll('Kurumsal İletişim Koordinatörlüğü', '')
          .replaceAll('Eğitim Öğretim Geliştirme Koordinatörlüğü', '')
          .replaceAll('Sosyal Bilimler Enstitüsü', '')
          .replaceAll(RegExp(r'\s+\d+\s+Okunma'), '')
          .trim();

      if (title.isEmpty || title.length < 5) continue;

      // URL'yi oluştur
      final newsUrl = href.startsWith('http')
          ? href
          : 'https://www.klu.edu.tr$href';

      // Okunma sayısını bul (link içinde veya yakınında olabilir)
      String? views;
      final okunmaMatch = RegExp(r'(\d+)\s+Okunma').firstMatch(link.text);
      if (okunmaMatch != null) {
        views = '${okunmaMatch.group(1)} okunma';
      }

      // Tarihi bul (parent veya sibling elementlerde olabilir)
      String? date;
      final parent = link.parent;
      if (parent != null) {
        final dateMatch = RegExp(r'\d{2}/\d{2}/\d{4}').firstMatch(parent.text);
        if (dateMatch != null) {
          date = dateMatch.group(0);
        }
      }

      news.add(
        KluNews(
          title: title.toUpperCase(),
          url: newsUrl,
          views: views,
          date: date,
        ),
      );
    }

    // Eğer link tabanlı parse başarısız olursa eski yöntemi dene
    if (news.isEmpty) {
      return _parseFallbackLinks(document);
    }

    return news;
  }

  /// Alternatif: sayfadaki <a> linklerinden haber çek
  static List<KluNews> _parseFallbackLinks(dynamic document) {
    final news = <KluNews>[];
    final links = document.querySelectorAll('a[href*="klu.edu.tr"]');

    for (final link in links.take(6)) {
      final title = link.text.trim();
      final href = link.attributes['href'] ?? '';
      if (title.isEmpty || href.isEmpty || title.length < 10) continue;

      news.add(
        KluNews(
          title: title.toUpperCase(),
          url: href.startsWith('http') ? href : 'https://www.klu.edu.tr$href',
          views: null,
          date: null,
        ),
      );
    }

    return news;
  }

  // ── Fallback (statik) haberler — public ──────────────────────────────────
  static const List<KluNews> fallbackNews = [
    KluNews(
      title: 'MÜHENDİSLİK FAKÜLTESİ PROJE PAZARI',
      url:
          'https://www.klu.edu.tr/Sayfalar/43728-muhendislik-fakultesi-proje-pazari.klu',
      date: null,
      views: '164 okunma',
    ),
    KluNews(
      title: 'AKADEMİ ODAKLI VERİ BİLİMİ VE KAMU VERİLERİ PANELİ',
      url:
          'https://www.klu.edu.tr/Sayfalar/43727-akademi-odakli-veri-bilimi-ve-kamu-verileri-paneli.klu',
      date: '04/05/2026',
      views: '166 okunma',
    ),
    KluNews(
      title: 'TRAKYA FİNANS ZİRVESİ AÇILIŞ OTURUMU İLE BAŞLADI',
      url:
          'https://www.klu.edu.tr/Sayfalar/43726-trakya-finans-zirvesi-acilis-oturumu-ile-basladi.klu',
      date: '29/04/2026',
      views: '207 okunma',
    ),
    KluNews(
      title: '"TARLADAN SOFRAYA GIDA GÜVENLİĞİ" PANELİ GERÇEKLEŞTİRİLDİ',
      url:
          'https://www.klu.edu.tr/Sayfalar/43725-tarladan-sofraya-gida-guvenligi-paneli-gerceklestirildi.klu',
      date: '29/04/2026',
      views: '196 okunma',
    ),
    KluNews(
      title: '18. SPOR ŞENLİKLERİ BAŞLIYOR',
      url:
          'https://www.klu.edu.tr/Sayfalar/43724-18-spor-senlikleri-basliyor.klu',
      date: '13/04/2026',
      views: '1344 okunma',
    ),
    KluNews(
      title: 'KIRKLARELİ ÜNİVERSİTESİ 15. KARİYER GÜNLERİ',
      url:
          'https://kariyer.klu.edu.tr/Sayfalar/43713-kirklareli-universitesi-15-kariyer-gunleri-48-mayis-tarihlerinde-duzenlenecek.klu',
      date: null,
      views: '376 okunma',
    ),
  ];
}
