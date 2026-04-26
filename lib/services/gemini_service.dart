import 'package:cloud_firestore/cloud_firestore.dart';

class GeminiService {
  // Kırklareli Üniversitesi hakkında temel bilgiler
  static const String _universityInfo = '''
🎓 **Kırklareli Üniversitesi Hakkında**

📅 **Kuruluş:** 29 Mayıs 2007 (5662 sayılı kanun)
👨‍🎓 **Öğrenci Sayısı:** Yaklaşık 20.000-25.000 öğrenci
🏛️ **Kampüs:** Kayalı Kampüsü, Merkez / Kırklareli
📞 **Telefon:** 444 40 39 / 0 288 212 96 79
📧 **E-posta:** kirklarelirektorluk@klu.edu.tr
🌐 **Web:** www.klu.edu.tr
🌍 **Balkan Üniversiteler Ağı** üyesidir

👔 **Yönetim:**
• **Rektör:** Prof. Dr. Mustafa Aykaç
• Her fakültenin kendi dekanı bulunmaktadır
• Detaylı yönetim bilgileri için www.klu.edu.tr adresini ziyaret edebilirsiniz

**8 Fakülte:**
🎓 Fen-Edebiyat Fakültesi
🔧 Mühendislik Fakültesi
💼 İktisadi ve İdari Bilimler Fakültesi
🏥 Sağlık Bilimleri Fakültesi
🏗️ Mimarlık Fakültesi
💻 Teknoloji Fakültesi
✈️ Turizm Fakültesi
🕌 İlahiyat Fakültesi

**Meslek Yüksekokulları:**
• Babaeski MYO
• Lüleburgaz MYO
• Pınarhisar MYO
• Vize MYO
• Kofçaz MYO
• Pehlivanköy MYO
ve daha fazlası...

**Enstitüler:**
• Fen Bilimleri Enstitüsü
• Sosyal Bilimler Enstitüsü
• Sağlık Bilimleri Enstitüsü

**Önemli Birimler:**
🌍 Erasmus Ofisi (erasmus.klu.edu.tr)
💼 Kariyer Merkezi (kariyer.klu.edu.tr)
📚 Bologna Koordinatörlüğü (bologna.klu.edu.tr)
🎭 Öğrenci Kulüpleri (ogrkulup.klu.edu.tr)
📖 Kütüphane (kddb.klu.edu.tr)
🎪 Sosyal Etkinlikler Merkezi (sem.klu.edu.tr)

**Dijital Hizmetler:**
• Öğrenci Bilgi Sistemi (obs.klu.edu.tr)
• Bilgi Yönetim Sistemi (bys.klu.edu.tr)
• Öğrenci E-posta (ogrenci.kirklareli.edu.tr)
• Öğrenci Destek Portalı (ogrdestek.klu.edu.tr)
• Mezunlar Portalı (mezuntakip.klu.edu.tr)
• KLU Mobil Uygulama (iOS & Android)

**Sosyal Medya:**
📘 Facebook: /kirklaruni39
🐦 Twitter: @kirklaruni
📸 Instagram: @kirklar_uni
📺 YouTube: /krluni
''';

  final List<Map<String, String>> _chatHistory = [];

  GeminiService();

  /// Kullanıcı mesajını analiz eder ve uygun yanıt döner.
  Future<String> sendMessage(String userMessage) async {
    try {
      _chatHistory.add({'role': 'user', 'message': userMessage});

      final lowerMessage = userMessage.toLowerCase().trim();

      // Akıllı yanıt sistemi - kelime bazlı analiz
      String? response = await _analyzeAndRespond(lowerMessage);
      if (response != null) return response;

      // Varsayılan yanıt
      return _getSmartDefaultResponse(lowerMessage);
    } catch (e) {
      return '❌ Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Mesajı analiz edip en uygun yanıtı döner
  Future<String?> _analyzeAndRespond(String msg) async {
    // 1. Selamlama
    if (_contains(msg, ['merhaba', 'selam', 'hey', 'günaydın', 'iyi günler'])) {
      return _getGreeting();
    }

    // 2. Rektör soruları
    if (_contains(msg, ['rektör', 'rektor']) &&
        _contains(msg, ['kim', 'kimdir', 'adı'])) {
      return '👔 **Rektör Bilgisi**\n\n'
          'Kırklareli Üniversitesi Rektörü: **Prof. Dr. Mustafa Aykaç**\n\n'
          '📞 Rektörlük İletişim:\n'
          '• Telefon: 444 40 39\n'
          '• E-posta: kirklarelirektorluk@klu.edu.tr\n'
          '• Adres: Kayalı Kampüsü, Merkez / Kırklareli\n\n'
          'Rektörlük hakkında daha fazla bilgi için www.klu.edu.tr adresini ziyaret edebilirsin.';
    }

    // 3. Dekan soruları
    if (_contains(msg, ['dekan']) && _contains(msg, ['kim', 'kimdir'])) {
      return '👨‍🏫 **Dekan Bilgisi**\n\n'
          'Her fakültenin kendi dekanı bulunmaktadır:\n\n'
          '🎓 Fen-Edebiyat Fakültesi Dekanı\n'
          '🔧 Mühendislik Fakültesi Dekanı\n'
          '💼 İktisadi ve İdari Bilimler Fakültesi Dekanı\n'
          '🏥 Sağlık Bilimleri Fakültesi Dekanı\n'
          '🏗️ Mimarlık Fakültesi Dekanı\n'
          '💻 Teknoloji Fakültesi Dekanı\n'
          '✈️ Turizm Fakültesi Dekanı\n'
          '🕌 İlahiyat Fakültesi Dekanı\n\n'
          'Hangi fakültenin dekanını öğrenmek istiyorsun? Fakülte adını söylersen detaylı bilgi verebilirim.\n\n'
          'Veya www.klu.edu.tr adresinden ilgili fakültenin sayfasını ziyaret edebilirsin.';
    }

    // 4. OBS soruları
    if (_contains(msg, ['obs'])) {
      if (_contains(msg, ['gir', 'nasıl', 'kullan', 'şifre'])) {
        return '💻 **OBS (Öğrenci Bilgi Sistemi) Kullanımı**\n\n'
            '🌐 **Adres:** obs.klu.edu.tr\n\n'
            '**Giriş Bilgileri:**\n'
            '• Kullanıcı Adı: Öğrenci numaranız\n'
            '• Şifre: Size verilen şifre (ilk giriş için T.C. kimlik numaranız olabilir)\n\n'
            '**OBS\'de Neler Yapabilirsin:**\n'
            '📝 Ders kayıt işlemleri\n'
            '📊 Not görüntüleme\n'
            '📄 Transkript alma\n'
            '📅 Ders programını görüntüleme\n'
            '📋 Sınav programı\n'
            '📬 Dilekçe işlemleri\n\n'
            '**Şifre Sorunları:**\n'
            'Şifrenizi unuttuysanız veya giriş yapamıyorsanız:\n'
            '1. OBS giriş sayfasındaki "Şifremi Unuttum" linkini kullanın\n'
            '2. Bilgi İşlem Daire Başkanlığı ile iletişime geçin\n'
            '3. Öğrenci İşleri Daire Başkanlığı\'na başvurun\n\n'
            '💡 **İpucu:** İlk girişte şifrenizi mutlaka değiştirin!';
      }
      return '💻 **OBS (Öğrenci Bilgi Sistemi)**\n\n'
          '🌐 obs.klu.edu.tr\n\n'
          'OBS, öğrenci işlemlerinizi online olarak yapabileceğiniz sistemdir.\n\n'
          '**Özellikler:**\n'
          '• Ders kayıt\n'
          '• Not görüntüleme\n'
          '• Transkript\n'
          '• Ders programı\n\n'
          'Daha detaylı bilgi için "OBS nasıl kullanılır?" diye sorabilirsin!';
    }

    // 5. E-posta soruları
    if (_contains(msg, ['e-posta', 'mail', 'eposta']) &&
        !_contains(msg, ['iletişim'])) {
      return '📧 **Öğrenci E-posta Sistemi**\n\n'
          '🌐 **Adres:** ogrenci.kirklareli.edu.tr\n\n'
          '**E-posta Hesabınız:**\n'
          '• Format: ogrenci_numaraniz@ogrenci.kirklareli.edu.tr\n'
          '• Örnek: 2021123456@ogrenci.kirklareli.edu.tr\n\n'
          '**Neden Önemli:**\n'
          '✅ Resmi duyurular bu adrese gelir\n'
          '✅ Hocalarla iletişim için kullanılır\n'
          '✅ Üniversite sistemlerine giriş için gerekli\n'
          '✅ Akademik bildirimler\n\n'
          '**İlk Giriş:**\n'
          '1. ogrenci.kirklareli.edu.tr adresine git\n'
          '2. Öğrenci numaranı ve şifreni gir\n'
          '3. İlk girişte şifreni değiştir\n\n'
          '**Şifre Sorunları:**\n'
          'Bilgi İşlem Daire Başkanlığı ile iletişime geçebilirsin.\n\n'
          '💡 **İpucu:** E-postanı düzenli kontrol et, önemli duyuruları kaçırma!';
    }

    // 6. Fakülte soruları
    if (_contains(msg, ['fakülte', 'fakülteler', 'bölüm', 'bölümler'])) {
      if (_contains(msg, ['hangi', 'neler', 'kaç'])) {
        return '🏛️ **Kırklareli Üniversitesi Fakülteleri**\n\n'
            'Üniversitemizde **8 fakülte** bulunmaktadır:\n\n'
            '1️⃣ **Fen-Edebiyat Fakültesi**\n'
            '   • Matematik, Fizik, Kimya, Biyoloji\n'
            '   • Türk Dili ve Edebiyatı, Tarih\n\n'
            '2️⃣ **Mühendislik Fakültesi**\n'
            '   • Bilgisayar Mühendisliği\n'
            '   • Elektrik-Elektronik Mühendisliği\n'
            '   • İnşaat Mühendisliği\n\n'
            '3️⃣ **İktisadi ve İdari Bilimler Fakültesi**\n'
            '   • İşletme, İktisat\n'
            '   • Kamu Yönetimi\n\n'
            '4️⃣ **Sağlık Bilimleri Fakültesi**\n'
            '   • Hemşirelik, Fizyoterapi\n'
            '   • Beslenme ve Diyetetik\n\n'
            '5️⃣ **Mimarlık Fakültesi**\n'
            '   • Mimarlık, İç Mimarlık\n'
            '   • Peyzaj Mimarlığı\n\n'
            '6️⃣ **Teknoloji Fakültesi**\n'
            '   • Bilgisayar Teknolojileri\n\n'
            '7️⃣ **Turizm Fakültesi**\n'
            '   • Turizm İşletmeciliği\n'
            '   • Gastronomi ve Mutfak Sanatları\n\n'
            '8️⃣ **İlahiyat Fakültesi**\n'
            '   • İlahiyat\n\n'
            '**Ayrıca:**\n'
            '• 6+ Meslek Yüksekokulu\n'
            '• 3 Enstitü (Fen, Sosyal, Sağlık Bilimleri)\n\n'
            'Belirli bir fakülte hakkında detaylı bilgi almak ister misin?';
      }
    }

    // 7. Kampüs soruları
    if (_contains(msg, ['kampüs', 'kampus', 'nerede', 'adres'])) {
      return '🏛️ **Kampüs Bilgileri**\n\n'
          '📍 **Ana Kampüs:** Kayalı Kampüsü\n'
          '🗺️ **Adres:** Merkez / Kırklareli\n\n'
          '**Kampüs İmkanları:**\n\n'
          '📚 **Kütüphane ve Dokümantasyon Merkezi**\n'
          '   • Geniş kitap koleksiyonu\n'
          '   • Çalışma alanları\n'
          '   • Online kaynak erişimi\n'
          '   • Web: kddb.klu.edu.tr\n\n'
          '🏋️ **Spor Tesisleri**\n'
          '   • Kapalı spor salonu\n'
          '   • Açık spor alanları\n'
          '   • Fitness merkezi\n\n'
          '🍽️ **Yemekhane ve Kafeterya**\n'
          '   • Öğle: 11:30 - 14:00\n'
          '   • Akşam: 17:30 - 19:30\n'
          '   • Uygun fiyatlı öğrenci menüleri\n\n'
          '🏨 **Öğrenci Yurtları**\n'
          '   • KYK yurtları\n'
          '   • Özel yurtlar\n\n'
          '🚌 **Ulaşım**\n'
          '   • Kampüs servisleri\n'
          '   • Şehir içi otobüsler\n\n'
          '🏥 **Sağlık Merkezi**\n'
          '   • İlk yardım\n'
          '   • Sağlık danışmanlığı\n\n'
          '🎭 **Sosyal Tesisler**\n'
          '   • Konferans salonları\n'
          '   • Öğrenci kulüpleri\n'
          '   • Sosyal etkinlik alanları\n\n'
          'Başka bir konuda yardımcı olabilir miyim?';
    }

    // 8. Etkinlik soruları
    if (_contains(msg, [
      'etkinlik',
      'event',
      'konser',
      'seminer',
      'ne var',
      'neler var',
    ])) {
      return await _getEventsInfo();
    }

    // 9. İlan soruları
    if (_contains(msg, ['ilan', 'kayıp', 'bulundu', 'satılık', 'kiralık'])) {
      return await _getListingsInfo();
    }

    // 10. Not soruları
    if (_contains(msg, ['not', 'ders notu', 'sınav', 'ödev'])) {
      return await _getNotesInfo();
    }

    // 11. Yemek menüsü
    if (_contains(msg, ['yemek', 'menü', 'yemekhane'])) {
      return '🍽️ **Yemek Menüsü ve Yemekhane Bilgileri**\n\n'
          '**Yemekhane Saatleri:**\n'
          '🕐 Öğle Yemeği: 11:30 - 14:00\n'
          '🕕 Akşam Yemeği: 17:30 - 19:30\n\n'
          '**Menü Bilgisi:**\n'
          'Günlük yemek menüsünü görmek için:\n'
          '• Ana sayfadaki "Günün Menüsü" bölümünü kontrol et\n'
          '• Üniversite web sitesini ziyaret et\n'
          '• Yemekhane girişindeki panolardan takip et\n\n'
          '**Ödeme:**\n'
          '💳 Öğrenci kartı ile ödeme yapılır\n'
          '💰 Uygun öğrenci fiyatları\n\n'
          '**Kafeterya:**\n'
          '☕ Gün boyu açık\n'
          '🥪 Atıştırmalık ve içecekler\n\n'
          'Afiyet olsun! 😊';
    }

    // 12. Kariyer ve staj
    if (_contains(msg, ['kariyer', 'staj', 'iş', 'mezuniyet'])) {
      return '💼 **Kariyer Merkezi ve Staj İmkanları**\n\n'
          '🌐 **Web:** kariyer.klu.edu.tr\n\n'
          '**Kariyer Merkezi Hizmetleri:**\n\n'
          '📋 **Staj İmkanları**\n'
          '   • Zorunlu staj başvuruları\n'
          '   • Staj ilanları\n'
          '   • Staj değerlendirme\n\n'
          '💼 **İş İmkanları**\n'
          '   • Part-time iş ilanları\n'
          '   • Mezun iş ilanları\n'
          '   • Kariyer fuarları\n\n'
          '📚 **Eğitimler**\n'
          '   • CV hazırlama\n'
          '   • Mülakat teknikleri\n'
          '   • Kişisel gelişim seminerleri\n\n'
          '🤝 **Şirket İşbirlikleri**\n'
          '   • Sektör buluşmaları\n'
          '   • Kampüs görüşmeleri\n\n'
          '**İletişim:**\n'
          'Kariyer Merkezi ile iletişime geçerek:\n'
          '• Kariyer danışmanlığı alabilirsin\n'
          '• Staj başvurusu yapabilirsin\n'
          '• İş ilanlarını takip edebilirsin\n\n'
          'Geleceğini şekillendir! 🚀';
    }

    // 13. Erasmus
    if (_contains(msg, ['erasmus', 'yurtdışı', 'değişim', 'exchange'])) {
      return '🌍 **Erasmus ve Uluslararası Değişim Programları**\n\n'
          '🌐 **Web:** erasmus.klu.edu.tr\n\n'
          '**Erasmus+ Programı:**\n\n'
          '✈️ **Öğrenci Hareketliliği**\n'
          '   • Avrupa üniversitelerinde eğitim\n'
          '   • 1-2 dönem süreyle\n'
          '   • Burs desteği\n\n'
          '📋 **Başvuru Koşulları:**\n'
          '   • En az 1 yıl tamamlamış olmak\n'
          '   • Minimum not ortalaması\n'
          '   • Dil yeterliliği\n\n'
          '💰 **Burs Desteği:**\n'
          '   • Aylık burs\n'
          '   • Seyahat desteği\n'
          '   • Sigorta\n\n'
          '🗓️ **Başvuru Dönemi:**\n'
          '   • Genellikle Kasım-Aralık ayları\n'
          '   • Duyurular erasmus.klu.edu.tr\'de\n\n'
          '**Diğer Programlar:**\n'
          '• Mevlana Değişim Programı\n'
          '• Farabi Değişim Programı\n'
          '• İkili anlaşmalar\n\n'
          '**İletişim:**\n'
          'Erasmus Ofisi:\n'
          '• Web: erasmus.klu.edu.tr\n'
          '• Detaylı bilgi ve başvuru için ofisi ziyaret et\n\n'
          'Dünyayı keşfet! 🌏';
    }

    // 14. Kütüphane
    if (_contains(msg, ['kütüphane', 'kitap', 'kaynak'])) {
      return '📚 **Kütüphane ve Dokümantasyon Daire Başkanlığı**\n\n'
          '🌐 **Web:** kddb.klu.edu.tr\n\n'
          '**Kütüphane Hizmetleri:**\n\n'
          '📖 **Kitap Ödünç Alma**\n'
          '   • Öğrenci kartınla ödünç alabilirsin\n'
          '   • Ödünç süresi: 15 gün\n'
          '   • Online rezervasyon imkanı\n\n'
          '💻 **Online Kaynaklar**\n'
          '   • E-kitaplar\n'
          '   • E-dergiler\n'
          '   • Akademik veritabanları\n'
          '   • Tez arşivi\n\n'
          '🔍 **Katalog Arama**\n'
          '   • Web sitesinden kitap arama\n'
          '   • Rafta olup olmadığını kontrol et\n'
          '   • Rezervasyon yap\n\n'
          '📝 **Çalışma Alanları**\n'
          '   • Sessiz çalışma salonları\n'
          '   • Grup çalışma odaları\n'
          '   • Bilgisayarlı çalışma alanları\n\n'
          '⏰ **Çalışma Saatleri:**\n'
          '   • Hafta içi: 08:00 - 22:00\n'
          '   • Hafta sonu: 09:00 - 18:00\n'
          '   (Sınav dönemlerinde 24 saat açık olabilir)\n\n'
          '**İpuçları:**\n'
          '• Öğrenci kartını yanında taşı\n'
          '• Kitapları zamanında iade et\n'
          '• Online kaynaklara kampüs dışından VPN ile erişebilirsin\n\n'
          'Başarılı çalışmalar! 📖';
    }

    // 15. Öğrenci kulüpleri
    if (_contains(msg, ['kulüp', 'club', 'topluluk', 'sosyal'])) {
      return '🎭 **Öğrenci Kulüpleri ve Sosyal Etkinlikler**\n\n'
          '🌐 **Web:** ogrkulup.klu.edu.tr\n\n'
          '**Öğrenci Kulüpleri:**\n\n'
          'Kampüsümüzde birçok öğrenci kulübü aktif olarak faaliyet göstermektedir:\n\n'
          '🎨 **Sanat ve Kültür Kulüpleri**\n'
          '   • Müzik kulübü\n'
          '   • Tiyatro kulübü\n'
          '   • Fotoğrafçılık kulübü\n'
          '   • Sinema kulübü\n\n'
          '⚽ **Spor Kulüpleri**\n'
          '   • Futbol\n'
          '   • Basketbol\n'
          '   • Voleybol\n'
          '   • Fitness ve yoga\n\n'
          '💻 **Akademik Kulüpler**\n'
          '   • Bilgisayar kulübü\n'
          '   • Mühendislik kulübü\n'
          '   • Edebiyat kulübü\n\n'
          '🌱 **Sosyal Sorumluluk**\n'
          '   • Çevre kulübü\n'
          '   • Gönüllü kulübü\n'
          '   • Hayvan hakları kulübü\n\n'
          '**Kulübe Nasıl Katılırım:**\n'
          '1. ogrkulup.klu.edu.tr adresini ziyaret et\n'
          '2. İlgilendiğin kulübü seç\n'
          '3. Başvuru formunu doldur\n'
          '4. Kulüp toplantılarına katıl\n\n'
          '**Faydaları:**\n'
          '✅ Yeni arkadaşlıklar\n'
          '✅ Sosyal beceriler\n'
          '✅ Etkinlik organizasyonu deneyimi\n'
          '✅ CV\'ne ekleyebileceğin aktiviteler\n\n'
          'Kampüs hayatını renklendır! 🎉';
    }

    // 16. Yardım
    if (_contains(msg, ['yardım', 'help', 'komut'])) {
      return _getHelpInfo();
    }

    // 17. Üniversite hakkında genel
    if (_contains(msg, [
      'üniversite',
      'klu',
      'kırklareli',
      'hakkında',
      'tanıt',
    ])) {
      return _universityInfo;
    }

    return null;
  }

  /// Kelime listesinin mesajda olup olmadığını kontrol eder
  bool _contains(String msg, List<String> keywords) {
    return keywords.any((keyword) => msg.contains(keyword));
  }

  /// Akıllı varsayılan yanıt - kullanıcının sorusuna göre öneriler sunar
  String _getSmartDefaultResponse(String msg) {
    // Soru işareti varsa, yardım öner
    if (msg.contains('?')) {
      return '🤔 **İlginç bir soru!**\n\n'
          'Şu anda bu konuda detaylı bilgim yok, ama şunları deneyebilirsin:\n\n'
          '**Popüler Konular:**\n'
          '• "Rektör kimdir?"\n'
          '• "OBS nasıl kullanılır?"\n'
          '• "Hangi fakülteler var?"\n'
          '• "Etkinlikler"\n'
          '• "Kampüs nerede?"\n'
          '• "Erasmus başvurusu"\n'
          '• "Kütüphane saatleri"\n\n'
          '💡 "Yardım" yazarak tüm komutları görebilirsin!';
    }

    // Kısa mesajlar için
    if (msg.length < 10) {
      return '👋 Merhaba! Sana nasıl yardımcı olabilirim?\n\n'
          '**Hızlı Erişim:**\n'
          '• Etkinlikler\n'
          '• OBS\n'
          '• Fakülteler\n'
          '• Kampüs\n'
          '• Yardım\n\n'
          'Yukarıdakilerden birini seçebilir veya kendi sorunuzu sorabilirsiniz! 😊';
    }

    // Genel varsayılan
    return '🎓 **Kampüs Asistanı**\n\n'
        'Üzgünüm, tam olarak anlayamadım. Daha spesifik bir soru sorabilir misin?\n\n'
        '**Şunlar hakkında bilgi verebilirim:**\n\n'
        '🏛️ **Üniversite:**\n'
        '• Genel bilgi, rektör, fakülteler\n'
        '• İletişim, kampüs, yönetim\n\n'
        '💻 **Öğrenci Sistemleri:**\n'
        '• OBS, e-posta, BYS\n'
        '• Kütüphane, kariyer merkezi\n\n'
        '🎉 **Kampüs Yaşamı:**\n'
        '• Etkinlikler, kulüpler\n'
        '• Yemek menüsü, yurtlar\n'
        '• Erasmus, staj imkanları\n\n'
        '📚 **Akademik:**\n'
        '• Notlar, ilanlar\n'
        '• Ders programı\n\n'
        '💡 "Yardım" yazarak detaylı bilgi alabilirsin!';
  }

  String _getGreeting() {
    final greetings = [
      '👋 Merhaba! Ben KLU UniConnect Asistanı. Kırklareli Üniversitesi hakkında her şeyi sorabilirsin!\n\n'
          '**Popüler Konular:**\n'
          '• OBS ve e-posta\n'
          '• Fakülteler ve bölümler\n'
          '• Etkinlikler\n'
          '• Kampüs bilgileri\n'
          '• Erasmus ve kariyer\n\n'
          'Ne öğrenmek istersin? 😊',

      '🎓 Selam! Kampüs hayatı hakkında sana yardımcı olabilirim.\n\n'
          'Şunları sorabilirsin:\n'
          '• "Rektör kimdir?"\n'
          '• "OBS nasıl kullanılır?"\n'
          '• "Etkinlikler neler?"\n'
          '• "Kütüphane saatleri"\n\n'
          'Başka ne merak ediyorsun?',

      '✨ Hey! Kırklareli Üniversitesi hakkında bilgi almak için doğru yerdesin!\n\n'
          '💡 İpucu: "Yardım" yazarak tüm komutları görebilirsin.\n\n'
          'Sana nasıl yardımcı olabilirim?',
    ];
    return greetings[DateTime.now().second % greetings.length];
  }

  Future<String> _getEventsInfo() async {
    try {
      final eventsSnap = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      if (eventsSnap.docs.isEmpty) {
        return '📅 **Yaklaşan Etkinlikler**\n\n'
            'Şu anda yaklaşan bir etkinlik bulunmuyor.\n\n'
            'Yeni etkinlikler eklendiğinde burada görünecek!\n\n'
            '💡 **İpucu:** Etkinlikler sayfasını düzenli kontrol et, sosyal medya hesaplarımızı takip et!';
      }

      final buffer = StringBuffer('🎉 **Yaklaşan Etkinlikler:**\n\n');

      for (final doc in eventsSnap.docs) {
        final d = doc.data();
        final title = d['title'] ?? 'Etkinlik';
        final date = d['date'] ?? '';
        final place = d['place'] ?? '';
        final category = d['category'] ?? '';

        buffer.writeln('📌 **$title**');
        if (date.isNotEmpty) buffer.writeln('   📅 Tarih: $date');
        if (place.isNotEmpty) buffer.writeln('   📍 Yer: $place');
        if (category.isNotEmpty) buffer.writeln('   🏷️ Kategori: $category');
        buffer.writeln();
      }

      buffer.writeln(
        'Detaylar için Etkinlikler sayfasını ziyaret edebilirsin! 🎊',
      );
      return buffer.toString();
    } catch (e) {
      return '❌ Etkinlikler yüklenirken bir hata oluştu. Lütfen daha sonra tekrar dene.';
    }
  }

  Future<String> _getListingsInfo() async {
    try {
      final listingsSnap = await FirebaseFirestore.instance
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      if (listingsSnap.docs.isEmpty) {
        return '📢 **İlanlar**\n\n'
            'Şu anda aktif ilan bulunmuyor.\n\n'
            'İlan vermek veya ilanları görüntülemek için İlanlar sayfasını ziyaret edebilirsin!';
      }

      final buffer = StringBuffer('📢 **Son İlanlar:**\n\n');

      for (final doc in listingsSnap.docs) {
        final d = doc.data();
        final title = d['title'] ?? 'İlan';
        final type = d['type'] ?? '';
        final category = d['category'] ?? '';

        buffer.writeln('• **$title**');
        if (type.isNotEmpty) buffer.writeln('  📋 Tür: $type');
        if (category.isNotEmpty) buffer.writeln('  🏷️ Kategori: $category');
        buffer.writeln();
      }

      buffer.writeln('Daha fazla ilan için İlanlar sayfasını ziyaret et!');
      return buffer.toString();
    } catch (e) {
      return '❌ İlanlar yüklenirken bir hata oluştu. Lütfen daha sonra tekrar dene.';
    }
  }

  Future<String> _getNotesInfo() async {
    try {
      final notesSnap = await FirebaseFirestore.instance
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      if (notesSnap.docs.isEmpty) {
        return '📚 **Ders Notları**\n\n'
            'Henüz paylaşılan not bulunmuyor.\n\n'
            'Sen de notlarını paylaşarak arkadaşlarına yardımcı olabilirsin! 🤝';
      }

      final buffer = StringBuffer('📚 **Son Paylaşılan Notlar:**\n\n');

      for (final doc in notesSnap.docs) {
        final d = doc.data();
        final title = d['title'] ?? 'Not';
        final course = d['course'] ?? '';
        final category = d['category'] ?? '';

        buffer.writeln('📝 **$title**');
        if (course.isNotEmpty) buffer.writeln('   📖 Ders: $course');
        if (category.isNotEmpty) buffer.writeln('   🏷️ Tür: $category');
        buffer.writeln();
      }

      buffer.writeln('Daha fazla not için Notlar sayfasını ziyaret et!');
      return buffer.toString();
    } catch (e) {
      return '❌ Notlar yüklenirken bir hata oluştu. Lütfen daha sonra tekrar dene.';
    }
  }

  String _getHelpInfo() {
    return '❓ **Yardım - Komut Listesi**\n\n'
        'Bana şunları sorabilirsin:\n\n'
        '**🏛️ Üniversite Hakkında:**\n'
        '• "Kırklareli Üniversitesi hakkında"\n'
        '• "Rektör kimdir?"\n'
        '• "Dekan kimdir?"\n'
        '• "Hangi fakülteler var?"\n'
        '• "Kampüs nerede?"\n'
        '• "İletişim bilgileri"\n\n'
        '**💻 Öğrenci Sistemleri:**\n'
        '• "OBS nasıl kullanılır?"\n'
        '• "E-posta nasıl kullanılır?"\n'
        '• "Şifremi unuttum"\n'
        '• "Kütüphane saatleri"\n\n'
        '**🎉 Kampüs Yaşamı:**\n'
        '• "Yaklaşan etkinlikler"\n'
        '• "Öğrenci kulüpleri"\n'
        '• "Yemek menüsü"\n'
        '• "Son ilanlar"\n'
        '• "Paylaşılan notlar"\n\n'
        '**🌍 Fırsatlar:**\n'
        '• "Erasmus başvurusu"\n'
        '• "Kariyer merkezi"\n'
        '• "Staj imkanları"\n\n'
        '💡 Daha spesifik sorular sorabilirsin, sana yardımcı olmaya çalışacağım! 😊';
  }

  /// Sohbet geçmişini sıfırlar.
  void resetChat() {
    _chatHistory.clear();
  }
}
