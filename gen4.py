import json

with open('assets/data/chatbot_data.json', encoding='utf-8') as f:
    existing = json.load(f)

new_entries = [

  # ── ADAY ÖĞRENCİ PORTALI GENEL ───────────────────────────────────────────
  {
    "intent": "klu_aday",
    "question": "Aday öğrenci portalı nedir?",
    "answer": "KLU Aday Öğrenci Portalı, üniversiteye başvurmak isteyen adaylar için hazırlanmış bilgi platformudur. Puan/kontenjanlar, yurt imkânları, öğrenci değişim programları ve SSS gibi bilgilere ulaşabilirsiniz. Web: https://aday.klu.edu.tr/"
  },
  {
    "intent": "klu_aday",
    "question": "KLU aday öğrenci sitesi nedir?",
    "answer": "KLU Aday Öğrenci Portalı: https://aday.klu.edu.tr/ — Puan/kontenjanlar, yurt bilgileri, değişim programları ve sıkça sorulan sorulara buradan ulaşabilirsiniz."
  },
  {
    "intent": "klu_aday",
    "question": "KLU tanıtım kataloğu nerede?",
    "answer": "KLU tanıtım kataloğuna Aday Öğrenci Portalı üzerinden ulaşabilirsiniz: https://aday.klu.edu.tr/"
  },

  # ── PUAN VE KONTENJANLAR ──────────────────────────────────────────────────
  {
    "intent": "klu_aday",
    "question": "KLU puan ve kontenjanlar nerede?",
    "answer": "KLU 2025 YKS puan ve kontenjan bilgilerine şu adresten ulaşabilirsiniz:\nhttps://aday.klu.edu.tr/Sayfalar/3493-puan-ve-kontenjanlar.klu\n\nLisans ve ön lisans kontenjan PDF'leri bu sayfada yayımlanmaktadır."
  },
  {
    "intent": "klu_aday",
    "question": "KLU taban puanları nedir?",
    "answer": "KLU taban puanları ve kontenjanlar için Aday Öğrenci Portalı'nı ziyaret edin:\nhttps://aday.klu.edu.tr/Sayfalar/3493-puan-ve-kontenjanlar.klu\n\nGüncel YKS lisans ve ön lisans kontenjan listeleri PDF olarak indirilebilir."
  },
  {
    "intent": "klu_aday",
    "question": "KLU YKS kontenjanları nerede bulunur?",
    "answer": "KLU YKS kontenjanları için:\nhttps://aday.klu.edu.tr/Sayfalar/3493-puan-ve-kontenjanlar.klu\n\nSayfada 2025 yılı lisans ve ön lisans kontenjan PDF dosyaları mevcuttur."
  },

  # ── YURT VE BARINMA ───────────────────────────────────────────────────────
  {
    "intent": "klu_kampus",
    "question": "KLU yurt kapasitesi ne kadar?",
    "answer": "KLU kampüsü yakınındaki KYK yurtları:\n• Merkez kampüs yakını: 4.250 kız + 1.500 erkek öğrenci\n• Kırklareli merkez: 780 kız + 600 erkek öğrenci\n• Lüleburgaz: 384 kız + 400 erkek öğrenci\n• Babaeski: 300 kişilik kız öğrenci yurdu\n\nAyrıca merkez ve ilçelerde özel yurt, pansiyon ve oteller de mevcuttur.\nDetay: https://aday.klu.edu.tr/Sayfalar/14250-yurt-ve-barinma-imkanlari.klu"
  },
  {
    "intent": "klu_kampus",
    "question": "KLU KYK yurdu var mı?",
    "answer": "Evet, KLU kampüsü yakınında Kredi ve Yurtlar Kurumu'na (KYK) bağlı yurtlar bulunmaktadır. Toplam kapasite: kampüs yakını 5.750, Kırklareli merkez 1.380, Lüleburgaz 784, Babaeski 300 öğrenci. KYK yurt müdürlükleri: https://kygm.gsb.gov.tr/YurtMudurlukleri"
  },
  {
    "intent": "klu_kampus",
    "question": "KLU özel yurt var mı?",
    "answer": "Evet, Kırklareli merkez ve ilçelerinde çok sayıda özel yurt, pansiyon ve otel bulunmaktadır. Detaylı bilgi için: https://aday.klu.edu.tr/Sayfalar/14250-yurt-ve-barinma-imkanlari.klu"
  },
  {
    "intent": "klu_kampus",
    "question": "KLU burs imkânları neler?",
    "answer": "KLU öğrencileri için burs imkânları:\n• KYK karşılıksız bursları\n• Çeşitli kurum bursları\n• Üniversite yemek bursu (başarılı ve düşük gelirli öğrencilere)\n• Kısmi Zamanlı Öğrenci Çalıştırma Programı (her eğitim yılı başında duyurulur)\nDetay: https://aday.klu.edu.tr/Sayfalar/14250-yurt-ve-barinma-imkanlari.klu"
  },
  {
    "intent": "klu_kampus",
    "question": "KLU kısmi zamanlı çalışma programı nedir?",
    "answer": "KLU Rektörlük birimlerinde 'Kısmi Zamanlı Öğrenci Çalıştırma Programı' uygulanmaktadır. Program her eğitim yılı başında öğrencilere duyurulur. Detay: https://aday.klu.edu.tr/Sayfalar/14250-yurt-ve-barinma-imkanlari.klu"
  },
  {
    "intent": "klu_kampus",
    "question": "Lüleburgaz yurt var mı?",
    "answer": "Evet, Lüleburgaz ilçesinde KYK'ya ait kız öğrenciler için 384 kişilik, erkek öğrenciler için 400 kişilik yurt bulunmaktadır."
  },
  {
    "intent": "klu_kampus",
    "question": "Babaeski yurt var mı?",
    "answer": "Evet, Babaeski ilçesinde KYK'ya ait 300 kişi kapasiteli kız öğrenci yurdu bulunmaktadır."
  },

  # ── ÖĞRENCİ DEĞİŞİM PROGRAMLARI ─────────────────────────────────────────
  {
    "intent": "klu_degisim",
    "question": "KLU öğrenci değişim programları neler?",
    "answer": "KLU'de üç öğrenci değişim programı bulunmaktadır:\n• Erasmus+ (Avrupa) — erasmus.klu.edu.tr\n• Farabi (Yurt içi) — farabi.klu.edu.tr\n• Mevlana (Uluslararası) — mevlana.klu.edu.tr\nDetay: https://aday.klu.edu.tr/Sayfalar/14232-ogrenci-degisimi-programlari.klu"
  },
  {
    "intent": "klu_degisim",
    "question": "Farabi programı nedir?",
    "answer": "Farabi Değişim Programı, Türkiye'deki üniversiteler arasında öğrenci ve öğretim üyesi değişimini sağlayan yurt içi bir programdır. KLU Farabi koordinatörlüğü: farabi.klu.edu.tr"
  },
  {
    "intent": "klu_degisim",
    "question": "Mevlana programı nedir?",
    "answer": "Mevlana Değişim Programı, Türkiye ile yabancı ülkelerdeki yükseköğretim kurumları arasında öğrenci ve öğretim üyesi değişimini sağlayan uluslararası bir programdır. KLU Mevlana koordinatörlüğü: mevlana.klu.edu.tr"
  },
  {
    "intent": "klu_degisim",
    "question": "KLU yurt dışı değişim programı var mı?",
    "answer": "Evet, KLU'de yurt dışı değişim için Erasmus+ ve Mevlana programları mevcuttur.\n• Erasmus+: erasmus.klu.edu.tr\n• Mevlana: mevlana.klu.edu.tr"
  },
  {
    "intent": "klu_degisim",
    "question": "KLU yurt içi değişim programı var mı?",
    "answer": "Evet, KLU'de yurt içi üniversiteler arası değişim için Farabi Programı mevcuttur. Detay: farabi.klu.edu.tr"
  },

  # ── ENSTİTÜLER ────────────────────────────────────────────────────────────
  {
    "intent": "klu_ogrenci_sss",
    "question": "KLU enstitüleri hangileri?",
    "answer": "KLU'de 3 enstitü bulunmaktadır:\n• Fen Bilimleri Enstitüsü — fbe.klu.edu.tr\n• Sağlık Bilimleri Enstitüsü — sabe.klu.edu.tr\n• Sosyal Bilimler Enstitüsü — sbe.klu.edu.tr"
  },
  {
    "intent": "klu_ogrenci_sss",
    "question": "Fen Bilimleri Enstitüsü web sitesi nedir?",
    "answer": "KLU Fen Bilimleri Enstitüsü: https://fbe.klu.edu.tr/"
  },
  {
    "intent": "klu_ogrenci_sss",
    "question": "Sosyal Bilimler Enstitüsü web sitesi nedir?",
    "answer": "KLU Sosyal Bilimler Enstitüsü: https://sbe.klu.edu.tr/"
  },
  {
    "intent": "klu_ogrenci_sss",
    "question": "Sağlık Bilimleri Enstitüsü web sitesi nedir?",
    "answer": "KLU Sağlık Bilimleri Enstitüsü: https://sabe.klu.edu.tr/"
  },

  # ── MESLEK YÜKSEKOKULLARI ─────────────────────────────────────────────────
  {
    "intent": "klu_ogrenci_sss",
    "question": "KLU meslek yüksekokulları hangileri?",
    "answer": "KLU'de 7 Meslek Yüksekokulu bulunmaktadır:\n• Babaeski MYO — babaeskimyo.klu.edu.tr\n• Lüleburgaz MYO — luleburgazmyo.klu.edu.tr\n• Pınarhisar MYO — pmyo.klu.edu.tr\n• Sağlık Hizmetleri MYO — shmyo.klu.edu.tr\n• Sosyal Bilimler MYO — sbmyo.klu.edu.tr\n• Teknik Bilimler MYO — tbmyo.klu.edu.tr\n• Vize MYO — vizemyo.klu.edu.tr"
  },
  {
    "intent": "klu_ogrenci_sss",
    "question": "Lüleburgaz Meslek Yüksekokulu web sitesi nedir?",
    "answer": "KLU Lüleburgaz Meslek Yüksekokulu: https://luleburgazmyo.klu.edu.tr/"
  },
  {
    "intent": "klu_ogrenci_sss",
    "question": "Sağlık Hizmetleri MYO web sitesi nedir?",
    "answer": "KLU Sağlık Hizmetleri Meslek Yüksekokulu: https://shmyo.klu.edu.tr/"
  },
  {
    "intent": "klu_ogrenci_sss",
    "question": "Vize Meslek Yüksekokulu web sitesi nedir?",
    "answer": "KLU Vize Meslek Yüksekokulu: https://vizemyo.klu.edu.tr/"
  },

  # ── SSS — KAYIT VE AKADEMİK ──────────────────────────────────────────────
  {
    "intent": "klu_aday",
    "question": "KLU kesin kayıt nasıl yapılır?",
    "answer": "YKS ile KLU'ye yerleşen öğrenciler, ÖSYM tarafından belirlenen kesin kayıt tarihleri içinde kayıt yaptırmalıdır. Kayıt için lise diploması veya mezuniyet belgesi, nüfus cüzdanı ve fotoğraf gereklidir. Detay için Öğrenci İşleri Daire Başkanlığı: oidb@klu.edu.tr"
  },
  {
    "intent": "klu_aday",
    "question": "Liseden henüz mezun olmadım KLU kaydı yapabilir miyim?",
    "answer": "Evet, lise mezuniyetiniz kesin kayıt tarihine kadar gerçekleşecekse geçici kayıt yaptırabilirsiniz. Mezuniyet belgenizi teslim ettiğinizde kaydınız kesinleşir. Detay için Öğrenci İşleri Daire Başkanlığı ile iletişime geçin: oidb@klu.edu.tr"
  },
  {
    "intent": "klu_aday",
    "question": "KLU kesin kayıt yaptırmazsam ne olur?",
    "answer": "Belirlenen süre içinde kesin kaydını yaptırmayan öğrenciler kayıt haklarını kaybeder. Ek yerleştirme haklarından yararlanmak için ÖSYM'nin duyurularını takip etmeniz gerekir."
  },
  {
    "intent": "klu_aday",
    "question": "Lise diplomamı kaybettim kayıt için ne yapmalıyım?",
    "answer": "Lise diplomasını kaybeden öğrenciler, mezun oldukları okuldan 'diploma kaybı' için dilekçe ile başvurarak yeni diploma veya resmi onaylı belge alabilirler. Bu belgeyle KLU Öğrenci İşleri'ne başvurabilirsiniz."
  },
  {
    "intent": "klu_aday",
    "question": "KLU katkı payı ne zaman ödenir?",
    "answer": "Katkı payı/öğrenim ücreti her yarıyıl başında, ders kayıt döneminde ödenir. Ödeme yöntemi ve tutarlar için Öğrenci İşleri Daire Başkanlığı'nı (oidb@klu.edu.tr) veya OBS'yi kontrol edin."
  },
  {
    "intent": "klu_aday",
    "question": "KLU öğrenim ücreti nasıl belirleniyor?",
    "answer": "Öğrenim ücretleri her yıl Bakanlar Kurulu kararıyla belirlenir. Güncel tutarlar için Öğrenci İşleri Daire Başkanlığı (oidb@klu.edu.tr) veya OBS üzerinden bilgi alabilirsiniz."
  },
  {
    "intent": "klu_aday",
    "question": "Öğrenci belgesi nereden alınır?",
    "answer": "Öğrenci belgesi OBS (Öğrenci Bilgi Sistemi) üzerinden online olarak alınabilir: https://obs.klu.edu.tr/ — Ayrıca Öğrenci İşleri Daire Başkanlığı'ndan da temin edilebilir."
  },
  {
    "intent": "klu_aday",
    "question": "KLU ders alma işlemleri nasıl yapılır?",
    "answer": "Yeni kayıt yaptıran öğrenciler, danışman onayıyla OBS üzerinden ders seçimi yapar. OBS adresi: https://obs.klu.edu.tr/ — Danışmanınız bölümünüz tarafından atanır."
  },
  {
    "intent": "klu_aday",
    "question": "Danışman nedir?",
    "answer": "Danışman, öğrencinin ders seçimi, akademik planlama ve üniversite hayatına uyum sürecinde rehberlik eden öğretim üyesidir. Her öğrenciye bölümü tarafından bir danışman atanır."
  },
  {
    "intent": "klu_aday",
    "question": "KLU kayıt dondurma yapılabilir mi?",
    "answer": "Evet, KLU'de belirli koşullar altında kayıt dondurma yapılabilir. Başvuru için Öğrenci İşleri Daire Başkanlığı'na (oidb@klu.edu.tr) dilekçeyle başvurmanız gerekir. Kayıt dondurduğunuz dönem için öğrenim ücreti ödenmez."
  },
  {
    "intent": "klu_aday",
    "question": "Ders ve sınav programları nereden öğrenilir?",
    "answer": "Ders ve sınav programları OBS (Öğrenci Bilgi Sistemi) üzerinden takip edilebilir: https://obs.klu.edu.tr/ — Ayrıca bölüm/fakülte web siteleri ve ilan panoları da kullanılabilir."
  },
  {
    "intent": "klu_aday",
    "question": "Öğrenci kimliğim yoksa sınava girebilir miyim?",
    "answer": "Öğrenci kimlik kartı yanınızda yoksa nüfus cüzdanı veya pasaport gibi resmi kimlik belgesiyle sınava girebilirsiniz. Kimlik kartı için Öğrenci İşleri Daire Başkanlığı'na başvurun."
  },
  {
    "intent": "klu_aday",
    "question": "Başka üniversiteden ders muafiyeti nasıl alınır?",
    "answer": "Daha önce başka bir yükseköğretim kurumunda başarılı olduğunuz dersler için muafiyet başvurusu yapabilirsiniz. Transkript ve ders içerikleriyle birlikte bölüm başkanlığınıza dilekçeyle başvurmanız gerekir."
  },
  {
    "intent": "klu_aday",
    "question": "KLU kaydı nasıl silinir?",
    "answer": "Kaydını sildirmek isteyen öğrenciler, Öğrenci İşleri Daire Başkanlığı'na dilekçeyle başvurmalıdır. İletişim: oidb@klu.edu.tr"
  },
  {
    "intent": "klu_aday",
    "question": "KLU askerlik tecil işlemleri nasıl yapılır?",
    "answer": "Üniversiteye kayıt yaptıran erkek öğrencilerin askerlik tecil işlemleri Öğrenci İşleri Daire Başkanlığı tarafından otomatik olarak yapılır. Detay için: oidb@klu.edu.tr"
  },

  # ── NEDEN KLU / KIRKLARELI HAYAT ─────────────────────────────────────────
  {
    "intent": "klu_aday",
    "question": "Neden Kırklareli Üniversitesi tercih edilmeli?",
    "answer": "KLU'yu tercih etmek için nedenler:\n• 11 fakülte, 7 MYO, 3 enstitü ile geniş program yelpazesi\n• Erasmus+, Farabi, Mevlana değişim programları\n• KYK yurtları ve uygun barınma imkânları\n• Aktif öğrenci kulüpleri ve sosyal etkinlikler\n• Trakya'nın doğal güzellikleri ve sakin şehir yaşamı\n• Uygun yaşam maliyeti\nDetay: https://aday.klu.edu.tr/"
  },
  {
    "intent": "klu_aday",
    "question": "Kırklareli'nde hayat nasıl?",
    "answer": "Kırklareli, sakin ve güvenli bir şehirdir. Yaşam maliyeti büyük şehirlere göre oldukça uygundur. Trakya'nın doğal güzellikleri, tarihi dokusu ve sosyal ortamıyla öğrenci hayatı için elverişli bir ortam sunar. Detay: https://aday.klu.edu.tr/"
  },
  {
    "intent": "klu_aday",
    "question": "Kırklareli'ne ulaşım nasıl?",
    "answer": "Kırklareli'ne ulaşım:\n• İstanbul'dan otobüs: yaklaşık 2,5-3 saat\n• Edirne'den otobüs: yaklaşık 1 saat\n• Trakya Otogarı üzerinden şehirlerarası otobüs bağlantıları mevcuttur.\nKampüse ulaşım için şehir içi otobüsler ve kampüs servisleri kullanılabilir."
  },
  {
    "intent": "klu_aday",
    "question": "KLU kampüsüne ulaşım nasıl?",
    "answer": "KLU Kayalı Kampüsü'ne şehir içi otobüsler ve kampüs servisleriyle ulaşılabilir. Detaylı güzergah bilgisi için Öğrenci İşleri veya www.klu.edu.tr adresini kontrol edin."
  },
  {
    "intent": "klu_aday",
    "question": "KLU sosyal ve kültürel imkânlar neler?",
    "answer": "KLU'de sosyal ve kültürel imkânlar:\n• Çok sayıda aktif öğrenci kulübü\n• Spor tesisleri (kapalı salon, açık alan, fitness)\n• Kültürel etkinlikler ve seminerler\n• Öğrenci toplulukları ve sosyal projeler\n• Trakya'nın tarihi ve doğal güzellikleri\nDetay: https://aday.klu.edu.tr/"
  },

  # ── KISA YAZIM VARYANTLARI ────────────────────────────────────────────────
  {
    "intent": "klu_aday",
    "question": "klu kayıt",
    "answer": "KLU kesin kayıt için ÖSYM tarafından belirlenen tarihlerde Öğrenci İşleri Daire Başkanlığı'na başvurmanız gerekir. Detay: oidb@klu.edu.tr veya https://aday.klu.edu.tr/"
  },
  {
    "intent": "klu_aday",
    "question": "klu yurt",
    "answer": "KLU kampüsü yakınında KYK yurtları mevcuttur. Toplam kapasite 7.000'in üzerindedir. Detay: https://aday.klu.edu.tr/Sayfalar/14250-yurt-ve-barinma-imkanlari.klu"
  },
  {
    "intent": "klu_aday",
    "question": "klu puan",
    "answer": "KLU taban puanları ve kontenjanlar için: https://aday.klu.edu.tr/Sayfalar/3493-puan-ve-kontenjanlar.klu"
  },
  {
    "intent": "klu_degisim",
    "question": "farabi nedir",
    "answer": "Farabi Değişim Programı, Türkiye'deki üniversiteler arasında öğrenci değişimini sağlayan yurt içi programdır. KLU Farabi: farabi.klu.edu.tr"
  },
  {
    "intent": "klu_degisim",
    "question": "mevlana nedir",
    "answer": "Mevlana Değişim Programı, Türkiye ile yabancı ülkeler arasında öğrenci değişimini sağlayan uluslararası programdır. KLU Mevlana: mevlana.klu.edu.tr"
  },
]

all_data = existing + new_entries

with open('assets/data/chatbot_data.json', 'w', encoding='utf-8') as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print(f'Toplam: {len(all_data)} kayit (eski: {len(existing)}, yeni: {len(new_entries)})')
