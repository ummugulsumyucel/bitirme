import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class KluClub {
  final String name;
  final String url;
  final String? logoUrl;

  const KluClub({required this.name, required this.url, this.logoUrl});

  /// CORS proxy üzerinden logo URL'sini döndürür.
  /// logoUrl varsa proxy ile, yoksa null döner.
  String? get proxiedLogoUrl {
    if (logoUrl == null || logoUrl!.isEmpty) return null;
    if (logoUrl!.contains('defaultLogo')) return null;
    // CORS-Anywhere benzeri proxy kullan
    // Alternatif: https://corsproxy.io, https://api.codetabs.com/v1/proxy
    return 'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(logoUrl!)}';
  }
}

class KluClubsService {
  /// Firebase Functions (HTTPS) endpoint.
  ///
  /// Deploy sonrası URL şu formdadır:
  /// `https://us-central1-<projectId>.cloudfunctions.net/kluSupportingClubs`
  static const String _endpoint =
      'https://us-central1-bitirme-a6f96.cloudfunctions.net/kluSupportingClubs';
  static const String _sourceUrl = 'https://ogrkulup.klu.edu.tr/';
  static const String _jinaMirrorUrl =
      'https://r.jina.ai/http://ogrkulup.klu.edu.tr/';

  static const List<KluClub> fallbackClubs = [
    KluClub(
      name: 'Yapay Zeka ve Veri Bilimi Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/61',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/124b3bc11b20158aa88e96917e9e413c.jpg',
    ),
    KluClub(
      name: 'Yazılım ve Bilişim Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/1',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/eb21be46699f020fd70b2ee77dcc185d.png',
    ),
    KluClub(
      name: 'KLU Hayalgücü Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/120',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/4de022e4483907e4518fc671c7ee4d4a.jpg',
    ),
    KluClub(
      name: 'Teknofest Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/102',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/a54f9608ddd70b98cf734664a7161eba.png',
    ),
    KluClub(
      name: 'Matematik Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/122',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/97005037624f07b5781c106200dc018b.jpeg',
    ),
    KluClub(
      name: 'Endüstri Mühendisliği Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/2',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/fd4668cfe6b1b723f1567756fcd30091.jpg',
    ),
    KluClub(
      name: 'Makine Mühendisliği Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/3',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/c2ca2c0c0e1634e5e6949d6a8f3e3e3e.jpg',
    ),
    KluClub(
      name: 'Elektrik-Elektronik Mühendisliği Kulübü',
      url: 'https://ogrkulup.klu.edu.tr/Anasayfa/kulupGoruntule/4',
      logoUrl:
          'https://ogrkulup.klu.edu.tr/uploads/8f14e45fceea167a5a36dedd4bea2543.jpg',
    ),
  ];

  Future<List<KluClub>> fetchSupportingClubs() async {
    // Direkt Jina mirror kullan - en güvenilir kaynak
    try {
      final resp = await http
          .get(Uri.parse(_jinaMirrorUrl))
          .timeout(const Duration(seconds: 12));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final clubs = _extractClubsFromJina(resp.body);
        if (clubs.isNotEmpty) return clubs;
      }
    } catch (_) {
      // fallback list'e düşecek
    }

    return fallbackClubs;
  }

  List<KluClub> _parseFunctionClubs(dynamic raw) {
    if (raw is! List) return <KluClub>[];
    final out = <KluClub>[];
    for (final item in raw) {
      // Eski Function sürümünde sadece isim döner; link olmadığı için
      // bu durumda aşağıdaki HTML parse fallback'ine düşmek daha doğru.
      if (item is String) continue;
      if (item is Map) {
        final name = (item['name'] ?? '').toString().trim();
        final url = (item['url'] ?? _sourceUrl).toString().trim();
        if (name.isEmpty) continue;
        out.add(KluClub(name: name, url: _normalizeUrl(url)));
      }
    }
    return out;
  }

  List<KluClub> _extractClubs(String html) {
    final doc = html_parser.parse(html);
    final clubs = <KluClub>[];
    final seen = <String>{};

    for (final a in doc.querySelectorAll('a[href*="kulupGoruntule"]')) {
      final name = a.text.trim();
      if (name.isEmpty) continue;
      final href = (a.attributes['href'] ?? '').trim();
      if (href.isEmpty) continue;
      final url = _normalizeUrl(href);
      // Varsa yakın img tag'inden logo URL'sini çek
      final img = a.querySelector('img') ?? a.parent?.querySelector('img');
      final logoUrl = img != null
          ? _normalizeUrl(img.attributes['src'] ?? '')
          : null;
      final key = '${name.toLowerCase()}|$url';
      if (seen.contains(key)) continue;
      seen.add(key);
      clubs.add(
        KluClub(
          name: name,
          url: url,
          logoUrl: logoUrl?.isNotEmpty == true ? logoUrl : null,
        ),
      );
    }

    if (clubs.isNotEmpty) return clubs;

    // Fallback: link bulunamazsa başlıklardan isim çıkar.
    for (final el in doc.querySelectorAll('h3')) {
      final t = el.text.trim();
      if (t.isEmpty) continue;
      final low = t.toLowerCase();
      if (!(low.contains('kulüp') || low.contains('kulub'))) continue;
      if (seen.contains(t.toLowerCase())) continue;
      seen.add(t.toLowerCase());
      clubs.add(KluClub(name: t, url: _sourceUrl));
    }
    return clubs;
  }

  String _normalizeUrl(String raw) {
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) return 'https://ogrkulup.klu.edu.tr$raw';
    return 'https://ogrkulup.klu.edu.tr/$raw';
  }

  List<KluClub> _extractClubsFromJina(String content) {
    // Logo URL + kulüp URL + kulüp adını birlikte yakala
    // Pattern: [![Image X: ...](logo_url)](kulup_url) ### [kulup_adi](kulup_url)
    final reg = RegExp(
      r'\[!\[Image \d+:.*?\]\((https://ogrkulup\.klu\.edu\.tr/uploads/[^\)]+)\)\]\((https://ogrkulup\.klu\.edu\.tr/Anasayfa/kulupGoruntule/\d+)\)\s*###\s*\[([^\]]+)\]',
      multiLine: true,
    );

    final clubs = <KluClub>[];
    final seen = <String>{};
    for (final m in reg.allMatches(content)) {
      final logoUrl = (m.group(1) ?? '').trim();
      final url = (m.group(2) ?? '').trim();
      final name = (m.group(3) ?? '').trim();
      if (name.isEmpty || url.isEmpty) continue;
      final key = '${name.toLowerCase()}|$url';
      if (seen.contains(key)) continue;
      seen.add(key);
      clubs.add(
        KluClub(
          name: name,
          url: url,
          logoUrl: logoUrl.isNotEmpty ? logoUrl : null,
        ),
      );
    }

    // Fallback: sadece isim+url pattern'i (logo olmadan)
    if (clubs.isEmpty) {
      final fallbackReg = RegExp(
        r'### \[(.+?)\]\((https://ogrkulup\.klu\.edu\.tr/Anasayfa/kulupGoruntule/\d+)\)',
        multiLine: true,
      );
      for (final m in fallbackReg.allMatches(content)) {
        final name = (m.group(1) ?? '').trim();
        final url = (m.group(2) ?? '').trim();
        if (name.isEmpty || url.isEmpty) continue;
        final key = '${name.toLowerCase()}|$url';
        if (seen.contains(key)) continue;
        seen.add(key);
        clubs.add(KluClub(name: name, url: url));
      }
    }
    return clubs;
  }
}
