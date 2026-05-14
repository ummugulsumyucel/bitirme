import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tek bir soru-cevap kaydı
class _QAEntry {
  final String intent;
  final String question;
  final String answer;
  const _QAEntry({
    required this.intent,
    required this.question,
    required this.answer,
  });
  factory _QAEntry.fromJson(Map<String, dynamic> j) => _QAEntry(
    intent: (j['intent'] as String?) ?? '',
    question: (j['question'] as String?) ?? '',
    answer: (j['answer'] as String?) ?? '',
  );
}

/// Intent → anahtar kelime haritası.
/// Kullanıcı mesajı bu kelimelerden birini içeriyorsa ilgili intent'e
/// ait kayıtlar önce aranır; bu sayede kısa/belirsiz sorgularda
/// doğru cevaba daha hızlı ulaşılır.
const _intentKeywords = <String, List<String>>{
  'klu_dekanlik': [
    'dekan',
    'dekanlar',
    'fakulte baskani',
    'saglik bilimleri dekani',
    'iibf dekani',
    'tip dekani',
    'hukuk dekani',
    'fen edebiyat dekani',
    'ilahiyat dekani',
    'uygulamali bilimler dekani',
    'muhendislik dekani',
    'teknoloji dekani',
    'mimarlik dekani',
    'turizm dekani',
    'yonetim kurulu',
  ],
  'klu_erasmus': [
    'erasmus',
    'hareketlilik',
    'yurt disi egitim',
    'turna',
    'turnaport',
    'staj hibe',
    'erasmus hibe',
    'erasmus basvuru',
    'erasmus puan',
    'erasmus not',
  ],
  'klu_kulupler': [
    'kulup',
    'kulupler',
    'ogrenci kulubu',
    'kulup kur',
    'kulup uye',
    'kulup etkinlik',
    'sksdb',
    'kulup izin',
    'kulup genel kurul',
  ],
  'klu_ydyo': [
    'hazirlik',
    'yabanci dil hazirlik',
    'ydyo',
    'yabanci diller yuksekokulu',
    'ingilizce hazirlik',
    'hazirlik sinifi',
  ],
  'klu_bolum': [
    'bolum',
    'program',
    'hangi bolumler',
    'muhendislik bolum',
    'fen edebiyat bolum',
    'saglik bilimleri bolum',
    'turizm bolum',
    'iibf bolum',
    'mimarlik bolum',
    'hukuk fakultesi',
    'tip fakultesi',
    'teknoloji fakultesi',
    'uygulamali bilimler',
    'ilahiyat fakultesi',
    'yazilim muhendisligi',
    'elektrik elektronik',
    'endustri muhendisligi',
    'gida muhendisligi',
    'insaat muhendisligi',
    'makine muhendisligi',
    'mekatronik',
    'enerji sistemleri',
    'hemsirelik',
    'fizyoterapi',
    'ebelik',
    'beslenme diyetetik',
    'cocuk gelisimi',
    'saglik yonetimi',
    'sosyal hizmet',
    'gastronomi',
    'rekreasyon',
    'turizm rehberligi',
    'turizm isletmeciligi',
    'finans bankacilik',
    'muhasebe finans',
    'uluslararasi ticaret',
    'lojistik',
    'psikoloji bolum',
    'sosyoloji bolum',
    'matematik bolum',
    'fizik bolum',
    'kimya bolum',
    'tarih bolum',
    'felsefe bolum',
    'mutercim tercumanlik',
    'molekuler biyoloji',
    'bati dilleri',
    'cagdas turk lehceleri',
    'egitim bilimleri',
    'ekonometri',
    'iktisat bolum',
    'isletme bolum',
    'maliye bolum',
    'kamu yonetimi',
    'uluslararasi iliskiler',
    'yonetim bilisim',
    'insan kaynaklari',
    'peyzaj mimarlik',
    'ic mimarlik',
    'sehir bolge planlama',
    'mimarlik bolumu',
  ],
  'klu_kampus': [
    'yurt',
    'yemekhane',
    'spor tesisi',
    'saglik merkezi',
    'ulasim',
    'konferans salonu',
    'kampus imkan',
    'kampus yasam',
    'kyk',
    'barinma',
    'ozel yurt',
    'pansiyon',
    'luleburgaz yurt',
    'babaeski yurt',
    'kismi zamanli',
    'yemek bursu',
  ],
  'klu_ogrenci_sss': [
    'kac fakulte',
    'klu de kac',
    'kac myo',
    'kac enstitu',
    'kac arastirma',
    'ogrenci sayisi',
    'devlet universitesi',
    'ne zaman kuruldu',
    'klu kurulus',
    'fakulte sayisi',
    'kac bolum',
  ],
  'klu_iletisim': [
    'telefon',
    'adres',
    'mail',
    'eposta',
    'iletisim',
    'rektorluk',
    'kep',
  ],
  'klu_aday': [
    'aday',
    'aday ogrenci',
    'kayit',
    'kesin kayit',
    'taban puan',
    'kontenjan',
    'yks',
    'tercih',
    'neden klu',
    'klu tercih',
    'ogretim ucreti',
    'katki payi',
    'ogrenim ucreti',
    'diploma kayip',
    'kayit dondur',
    'muafiyet',
    'askerlik tecil',
    'tanitim katalog',
    'aday portal',
  ],
  'klu_degisim': [
    'farabi',
    'mevlana',
    'degisim programi',
    'ogrenci degisimi',
    'yurt ici degisim',
    'yurt disi degisim',
  ],
  'klu_genel': [
    'klu nerede',
    'klu hakkinda',
    'web sitesi',
    'resmi site',
    'balkan universiteler',
    'akreditasyon',
    'lisansustu',
    'uzaktan egitim',
    'uzem',
    'tto',
    'teknoloji transfer',
    'uluslararasi ogrenci',
    'burs',
  ],
};

/// JSON tabanlı chatbot servisi.
/// Kullanıcı sorusunu normalize edip veri setindeki sorularla
/// kelime örtüşmesi (Jaccard + intent boost) ile eşleştirir.
class GeminiService {
  static List<_QAEntry>? _entries;

  // Intent → entry listesi önbelleği (ilk yüklemede doldurulur)
  static Map<String, List<_QAEntry>>? _byIntent;

  final List<Map<String, String>> _chatHistory = [];

  GeminiService();

  // ── Veri yükleme ──────────────────────────────────────────────────────────

  static Future<void> _ensureLoaded() async {
    if (_entries != null) return;
    try {
      final raw = await rootBundle.loadString('assets/data/chatbot_data.json');
      final list = json.decode(raw) as List<dynamic>;
      _entries = list
          .map((e) => _QAEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      // Intent bazlı indeks oluştur
      _byIntent = {};
      for (final e in _entries!) {
        (_byIntent![e.intent] ??= []).add(e);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ChatbotService] JSON yüklenemedi: $e');
      _entries = null;
      _byIntent = null;
    }
  }

  // ── Ana giriş noktası ─────────────────────────────────────────────────────

  Future<String> sendMessage(String userMessage) async {
    try {
      await _ensureLoaded();
      _chatHistory.add({'role': 'user', 'message': userMessage});

      final normalized = _normalize(userMessage);

      // 1. JSON veri setinde eşleşme ara (en güvenilir kaynak)
      if (_entries != null && _entries!.isNotEmpty) {
        final jsonReply = _findBestMatch(normalized);
        if (jsonReply != null) return jsonReply;
      }

      // 2. JSON'da bulunamazsa Firestore canlı verisi dene
      final liveReply = await _tryLiveData(normalized);
      if (liveReply != null) return liveReply;

      // 3. Varsayılan yanıt
      return _defaultReply(normalized);
    } catch (e) {
      return 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  // ── Canlı Firestore verileri ──────────────────────────────────────────────

  Future<String?> _tryLiveData(String msg) async {
    // Etkinlik soruları
    if (_hasAny(msg, [
      'etkinlik',
      'event',
      'konser',
      'seminer',
      'aktivite',
      'yaklasan',
    ])) {
      return _getEventsInfo();
    }
    // İlan soruları
    if (_hasAny(msg, ['ilan', 'kayip', 'satilik', 'kiralik', 'bulundu'])) {
      return _getListingsInfo();
    }
    // Not soruları
    if (_hasAny(msg, ['not', 'ders notu', 'dokuman']) &&
        _hasAny(msg, ['paylas', 'yukle', 'bul', 'goster', 'indir'])) {
      return _getNotesInfo();
    }
    return null;
  }

  // ── JSON eşleştirme ───────────────────────────────────────────────────────

  String? _findBestMatch(String normalizedInput) {
    if (_entries == null || _entries!.isEmpty) return null;

    final inputTokens = _tokenize(normalizedInput);
    if (inputTokens.isEmpty) return null;

    // Hangi intent'lerin öncelikli aranacağını belirle
    final priorityIntents = _detectPriorityIntents(normalizedInput);

    double bestScore = 0.0;
    _QAEntry? bestEntry;

    // Önce öncelikli intent'leri tara (varsa)
    final priorityCandidates = priorityIntents.isNotEmpty
        ? priorityIntents.expand((i) => _byIntent?[i] ?? <_QAEntry>[]).toList()
        : <_QAEntry>[];

    // Sonra tüm kayıtları tara
    final allCandidates = _entries!;

    // Önce priority, sonra genel — ama her ikisini de değerlendir
    for (final entry in [...priorityCandidates, ...allCandidates]) {
      final qNorm = _normalize(entry.question);
      final qTokens = _tokenize(qNorm);

      // 1. Jaccard benzerliği
      final jScore = _jaccardSimilarity(inputTokens, qTokens);

      // 2. Tam alt-dizi eşleşmesi bonusu
      double bonus = 0.0;
      if (qNorm.contains(normalizedInput) || normalizedInput.contains(qNorm)) {
        bonus = 0.5;
      }

      // 3. Uzun token örtüşmesi bonusu (>=4 karakter)
      final importantOverlap = inputTokens
          .where((t) => t.length >= 4 && qTokens.contains(t))
          .length;
      final importantBonus = importantOverlap * 0.15;

      // 4. Priority intent bonusu — doğru kategorideyse hafif boost
      final intentBonus = priorityIntents.contains(entry.intent) ? 0.12 : 0.0;

      final score = jScore + bonus + importantBonus + intentBonus;

      if (score > bestScore) {
        bestScore = score;
        bestEntry = entry;
      }
    }

    if (bestEntry != null) {
      final qTokens = _tokenize(_normalize(bestEntry.question));
      final hasImportantMatch = inputTokens.any(
        (t) => t.length >= 4 && qTokens.contains(t),
      );

      // Priority intent eşleşmesinde eşiği biraz düşür
      final isPriority = priorityIntents.contains(bestEntry.intent);
      final threshold = isPriority ? 0.18 : 0.25;
      final lowThreshold = isPriority ? 0.08 : 0.10;

      if (bestScore >= threshold ||
          (bestScore >= lowThreshold && hasImportantMatch)) {
        return bestEntry.answer;
      }
    }

    return null;
  }

  /// Kullanıcı mesajındaki anahtar kelimelere göre öncelikli intent'leri döndürür.
  List<String> _detectPriorityIntents(String normalizedMsg) {
    final result = <String>[];
    for (final entry in _intentKeywords.entries) {
      if (entry.value.any((kw) => normalizedMsg.contains(kw))) {
        result.add(entry.key);
      }
    }
    return result;
  }

  // ── Yardımcı metotlar ─────────────────────────────────────────────────────

  /// Metni normalize eder:
  /// 1) Büyük Türkçe harfleri önce küçüğe çevirir
  /// 2) Türkçe karakterleri ASCII karşılığına dönüştürür
  /// 3) Noktalama ve özel karakterleri boşluğa çevirir
  String _normalize(String text) {
    var s = text
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .replaceAll('Ğ', 'g')
        .replaceAll('Ü', 'u')
        .replaceAll('Ş', 's')
        .replaceAll('Ö', 'o')
        .replaceAll('Ç', 'c')
        .toLowerCase();
    s = s
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    s = s
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return s;
  }

  Set<String> _tokenize(String text) {
    // Stopword'leri çıkar — bunlar eşleştirmeyi gürültülü yapar
    const stopwords = {
      'mi',
      'mu',
      'mı',
      've',
      'bir',
      'bu',
      'da',
      'de',
      'ki',
      'ile',
      'icin',
      'yok',
      'nedir',
      'nerede',
      'kim',
      'hangi',
      'olan',
      'olur',
      'oldu',
      'ise',
      'gibi',
      'daha',
      'cok',
      'en',
      'her',
      'biz',
      'siz',
      'ben',
      'sen',
    };
    return text
        .split(' ')
        .where((t) => t.length > 1 && !stopwords.contains(t))
        .toSet();
  }

  double _jaccardSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    final intersection = a.intersection(b).length;
    final union = a.union(b).length;
    return intersection / union;
  }

  bool _hasAny(String msg, List<String> keywords) =>
      keywords.any((k) => msg.contains(k));

  // ── Varsayılan yanıt ──────────────────────────────────────────────────────

  String _defaultReply(String msg) {
    if (msg.contains('yardim') || msg.contains('ne sorabilir')) {
      return 'Şunları sorabilirsin:\n\n'
          '🎓 Akademik\n'
          '• Fakülteler ve bölümler\n'
          '• Dekanlar ve yönetim\n'
          '• Erasmus başvurusu\n'
          '• Hazırlık eğitimi (YDYO)\n\n'
          '🏫 Kampüs\n'
          '• Yurt ve barınma\n'
          '• Yemekhane saatleri\n'
          '• Spor tesisleri\n'
          '• Ulaşım\n\n'
          '📱 Uygulama\n'
          '• Etkinlikler\n'
          '• Not paylaşımı\n'
          '• İlanlar\n\n'
          '📞 İletişim\n'
          '• KLU telefon ve adres\n'
          '• Birim iletişim bilgileri\n\n'
          'Örnek: "Erasmus başvurusu nasıl yapılır?" veya "Mühendislik Fakültesi dekanı kim?"';
    }

    if (msg.length > 15) {
      return 'Bu konuda tam bilgim yok. Farklı bir şekilde sorabilir veya "yardım" yazarak konuları görebilirsin.';
    }

    return 'Merhaba! Ben UniConnect Asistanı 👋\n\n'
        'Kampüs hayatın hakkında sana yardımcı olabilirim.\n\n'
        '"Yardım" yazarak tüm konuları görebilirsin!';
  }

  // ── Firestore canlı veri ──────────────────────────────────────────────────

  Future<String> _getEventsInfo() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      if (snap.docs.isEmpty) {
        return 'Şu anda yaklaşan bir etkinlik bulunmuyor.\n\n'
            'Yeni etkinlikler eklendiğinde burada görünecek!';
      }

      final buf = StringBuffer('Yaklaşan Etkinlikler:\n\n');
      for (final doc in snap.docs) {
        final d = doc.data();
        buf.writeln('• ${d['title'] ?? 'Etkinlik'}');
        if ((d['date'] as String?)?.isNotEmpty == true) {
          buf.writeln('  Tarih: ${d['date']}');
        }
        if ((d['place'] as String?)?.isNotEmpty == true) {
          buf.writeln('  Yer: ${d['place']}');
        }
        buf.writeln();
      }
      buf.writeln('Detaylar için Etkinlikler sayfasını ziyaret et!');
      return buf.toString();
    } catch (_) {
      return 'Etkinlikler yüklenirken hata oluştu. Lütfen daha sonra tekrar dene.';
    }
  }

  Future<String> _getListingsInfo() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      if (snap.docs.isEmpty) {
        return 'Şu anda aktif ilan bulunmuyor.\n\n'
            'İlan vermek için İlanlar sayfasını ziyaret edebilirsin!';
      }

      final buf = StringBuffer('Son İlanlar:\n\n');
      for (final doc in snap.docs) {
        final d = doc.data();
        buf.writeln('• ${d['title'] ?? 'İlan'}');
        if ((d['category'] as String?)?.isNotEmpty == true) {
          buf.writeln('  Kategori: ${d['category']}');
        }
        buf.writeln();
      }
      buf.writeln('Daha fazla ilan için İlanlar sayfasını ziyaret et!');
      return buf.toString();
    } catch (_) {
      return 'İlanlar yüklenirken hata oluştu. Lütfen daha sonra tekrar dene.';
    }
  }

  Future<String> _getNotesInfo() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      if (snap.docs.isEmpty) {
        return 'Henüz paylaşılan not bulunmuyor.\n\n'
            'Sen de notlarını paylaşarak arkadaşlarına yardımcı olabilirsin!';
      }

      final buf = StringBuffer('Son Paylaşılan Notlar:\n\n');
      for (final doc in snap.docs) {
        final d = doc.data();
        buf.writeln('• ${d['title'] ?? 'Not'}');
        if ((d['course'] as String?)?.isNotEmpty == true) {
          buf.writeln('  Ders: ${d['course']}');
        }
        buf.writeln();
      }
      buf.writeln('Daha fazla not için Notlar sayfasını ziyaret et!');
      return buf.toString();
    } catch (_) {
      return 'Notlar yüklenirken hata oluştu. Lütfen daha sonra tekrar dene.';
    }
  }

  /// Sohbet geçmişini sıfırlar.
  void resetChat() {
    _chatHistory.clear();
    _entries = null;
    _byIntent = null;
  }
}
