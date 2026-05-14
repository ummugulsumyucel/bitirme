import json

with open('assets/data/chatbot_data.json', encoding='utf-8') as f:
    existing = json.load(f)

new_entries = [

  # ── YÖNETİM KURULU DEKANLARI ─────────────────────────────────────────────
  {"intent":"klu_dekanlik","question":"Saglik Bilimleri Fakultesi dekani kim?","answer":"Prof. Dr. Meryem CAMUR DEMIR - Saglik Bilimleri Fakultesi Dekani V."},
  {"intent":"klu_dekanlik","question":"IIBF dekani kim?","answer":"Prof. Dr. Raif CERGIBOZAN - Iktisadi ve Idari Bilimler Fakultesi Dekani"},
  {"intent":"klu_dekanlik","question":"Tip Fakultesi dekani kim?","answer":"Prof. Dr. Baran Heval KOMUR - Tip Fakultesi Dekani V."},
  {"intent":"klu_dekanlik","question":"Hukuk Fakultesi dekani kim?","answer":"Prof. Dr. Ahmet Mithat GUNES - Hukuk Fakultesi Dekani V."},
  {"intent":"klu_dekanlik","question":"Fen Edebiyat Fakultesi dekani kim?","answer":"Prof. Dr. Ertug CAN - Fen Edebiyat Fakultesi Dekani V."},
  {"intent":"klu_dekanlik","question":"Ilahiyat Fakultesi dekani kim?","answer":"Prof. Dr. Mustafa CANLI - Ilahiyat Fakultesi Dekani V."},
  {"intent":"klu_dekanlik","question":"Uygulamali Bilimler Fakultesi dekani kim?","answer":"Prof. Dr. Suleyman KALE - Uygulamali Bilimler Fakultesi Dekani"},
  {"intent":"klu_dekanlik","question":"Muhendislik Fakultesi dekani kim?","answer":"Prof. Dr. Erol TURKES - Muhendislik Fakultesi Dekani"},
  {"intent":"klu_dekanlik","question":"Teknoloji Fakultesi dekani kim?","answer":"Prof. Dr. Fatih Semerci - Teknoloji Fakultesi Dekani V."},
  {"intent":"klu_dekanlik","question":"Mimarlik Fakultesi dekani kim?","answer":"Prof. Dr. Furuzan CELIK - Mimarlik Fakultesi Dekani"},
  {"intent":"klu_dekanlik","question":"Turizm Fakultesi dekani kim?","answer":"Prof. Dr. Mustafa Cevdet ALTUNEL - Turizm Fakultesi Dekani V."},
  {"intent":"klu_dekanlik","question":"KLU yonetim kurulu uyeleri kimler?","answer":"Yonetim Kurulu: Prof. Dr. Rengin AK (Rektor), Ahmet SIMSEK (Genel Sekreter), Prof. Dr. Meryem CAMUR DEMIR, Prof. Dr. Raif CERGIBOZAN, Prof. Dr. Baran Heval KOMUR, Prof. Dr. Ahmet Mithat GUNES, Prof. Dr. Ertug CAN, Prof. Dr. Mustafa CANLI, Prof. Dr. Suleyman KALE, Prof. Dr. Erol TURKES, Prof. Dr. Fatih Semerci, Prof. Dr. Furuzan CELIK, Prof. Dr. Mustafa Cevdet ALTUNEL, Prof. Dr. Ahmet TURKMEN, Prof. Dr. Yasin UNLUTURK, Prof. Dr. Ayfer EKIM GUNAYDIN"},

  # ── YABANCI DİLLER YO ────────────────────────────────────────────────────
  {"intent":"klu_ydyo","question":"Yabanci Diller Yuksekokulu ne zaman kuruldu?","answer":"KLU Yabanci Diller Yuksekokulu, 30 Ekim 2010 tarihli 27744 Sayili Resmi Gazete'de yayimlanan 2010/941 Sayili Bakanlar Kurulu Karari ile kurulmustur."},
  {"intent":"klu_ydyo","question":"Yabanci Diller Yuksekokulu ne is yapar?","answer":"YDYO; Fen-Edebiyat, Ilahiyat ve IIBF Fakultelerinin Zorunlu Yabanci Dil Hazirlik egitimlerini ve universitenin tum birimlerinde zorunlu yabanci dil derslerini yurutmektedir."},
  {"intent":"klu_ydyo","question":"Hazirlik egitimi hangi fakultelerde zorunlu?","answer":"Fen-Edebiyat Fakultesi, Ilahiyat Fakultesi ve Iktisadi ve Idari Bilimler Fakultesinde zorunlu yabanci dil hazirlik egitimi uygulanmaktadir."},
  {"intent":"klu_ydyo","question":"KLU hazirlik sinifi var mi?","answer":"Evet, KLU Yabanci Diller Yuksekokulu bazi fakultelerde zorunlu yabanci dil hazirlik egitimi vermektedir. Detaylar icin ydyo.klu.edu.tr adresini kontrol edin."},

  # ── ÖĞRENCİ KULÜPLERİ DETAY ─────────────────────────────────────────────
  {"intent":"klu_kulupler","question":"Kulup kurmak icin hangi belgeler gerekli?","answer":"Kulup kurmak icin: a) Basvuru dilekce, b) Kulup Tuzugu, c) Akademik Danisman, d) SKSDB gorusu, e) Rektorluk onayi gereklidir. En az 5 ogrenci ve bir akademik danismanin yazili basvurusu sarttir."},
  {"intent":"klu_kulupler","question":"Kulup uyeligi nasil olur?","answer":"Kulup uyeligi sadece KLU ogrencilerine aciktir. Uyelik icin basvuru dilekce ve ogrenci kimlik belgesi fotokopisi gereklidir. Bir ogrenci birden fazla kulube uye olabilir ancak yalniz bir kulupte yoneticilik yapabilir."},
  {"intent":"klu_kulupler","question":"Kulup faaliyetleri kim tarafindan onaylanir?","answer":"Kulup faaliyetleri Saglik Kultur ve Spor Daire Baskanligi (SKSDB) tarafindan onaylanir. Akademik danismanin bilgisi ve onayi olmadan faaliyet duzenlenemez."},
  {"intent":"klu_kulupler","question":"Kulup genel kurulu ne zaman yapilir?","answer":"Genel kurul her akademik yilin bitiminden once yapilir. Toplantiya katilabilmek icin aktif uye olmak gerekir. Aktif uye sayisi 10 kisinin altina duserse kulup faaliyetlerine son verilir."},
  {"intent":"klu_kulupler","question":"Kulup yonetim kurulu nasil secilir?","answer":"Yonetim kurulu; bir baskan, bir baskan yardimcisi, bir sekreter ve en az iki uyeden olusan 5 asil ve 5 yedek uyeden olusur. Her akademik yil sonunda genel kurul tarafindan gizli oylama ile secilir."},
  {"intent":"klu_kulupler","question":"Kulup etkinligi icin izin nasil alinir?","answer":"Kulup etkinlikleri icin SKSDB onayi gereklidir. Diger kurumlari ilgilendiren faaliyetler icin etkinlik tarihinden 15 gun once yazili olarak SKSDB'na bildirim zorunludur."},
  {"intent":"klu_kulupler","question":"Kulup kapatilabilir mi?","answer":"SKSDB; yasa, yonetmelik ve yonergeleri ihlal eden veya belirlenen alanlara uymayan faaliyetlerde bulunan kuluplerin faaliyetlerini askiya alabilir veya kapatabilir."},

  # ── ERASMUS DETAY ────────────────────────────────────────────────────────
  {"intent":"klu_erasmus","question":"2026-2027 Erasmus basvuru tarihleri nedir?","answer":"2026-2027 Erasmus+ Ogrenim Hareketliligi basvurusu 26 Ocak 2026 (08:30) - 12 Subat 2026 (17:30) tarihleri arasinda TURNAPortal uzerinden alinmistir. Guncel tarihler icin erasmus.klu.edu.tr adresini kontrol edin."},
  {"intent":"klu_erasmus","question":"Erasmus basvurusu nasil yapilir?","answer":"Erasmus basvurusu TURNAPortal uzerinden e-Devlet ile giris yapilarak yapilir. Adimlar: 1) Kisisel bilgiler ve fotograf yukle, 2) Egitim bilgilerini gir, 3) Universite tercihlerini sec, 4) Yabanci dil bilgilerini gir, 5) Transkript yukle, 6) BASVURUYU TAMAMLA butonuna tikla."},
  {"intent":"klu_erasmus","question":"Erasmus icin not ortalamasi kac olmali?","answer":"Lisans/Onlisans ogrencileri icin kumülatif not ortalamasi en az 2.20/4.00, Yuksek Lisans ve Doktora ogrencileri icin en az 2.50/4.00 olmalidir."},
  {"intent":"klu_erasmus","question":"Erasmus hibe miktarlari ne kadar?","answer":"1-2. Grup ulkeler (Almanya, Fransa, Italya vb.): Ogrenim 600 Euro/ay, Staj 750 Euro/ay. 3. Grup ulkeler (Bulgaristan, Polonya, Romanya vb.): Ogrenim 450 Euro/ay, Staj 600 Euro/ay."},
  {"intent":"klu_erasmus","question":"Erasmus secim kriterleri nelerdir?","answer":"Secim kriterleri: Akademik basari %50 (100 puan uzerinden) + Dil seviyesi %50 (100 puan uzerinden). Ek puanlar: Sehit/gazi cocuklari +15, Engelli ogrenciler +10, Afetzede yakinlari +10. Eksiltmeler: Daha once yararlanma -10, Vatandasi olunan ulkede hareketlilik -10."},
  {"intent":"klu_erasmus","question":"Erasmus icin kac AKTS gerekli?","answer":"Ogrenim hareketliligi icin bir donem icin 30 AKTS, bir akademik yil icin 60 AKTS ders yuku olmasi gereklidir."},
  {"intent":"klu_erasmus","question":"Erasmus seyahat hibesi ne kadar?","answer":"Seyahat mesafesine gore: 100-499 km: 211 Euro, 500-1999 km: 309 Euro, 2000-2999 km: 395 Euro, 3000-3999 km: 580 Euro, 4000-7999 km: 1188 Euro. Yesil seyahat (otobüs/tren) icin daha yuksek miktarlar uygulanir."},
  {"intent":"klu_erasmus","question":"Erasmus ilave hibe destegi kimler alabilir?","answer":"Ilave hibe destegi: 2828 sayili kanuna tabi olanlar, yetim/olum ayligi baglananlar, sehit/gazi es ve cocuklari, muhtaclik ayligi baglananlar, engelliler (%50 ve uzeri), afetzede yakinlari alabilir."},
  {"intent":"klu_erasmus","question":"Erasmus basvurusunda hangi belgeler gerekli?","answer":"Gerekli belgeler: Fotograf, Transkript (e-Devlet veya OBS'den PDF), Yabanci dil puani. Ek olarak: Engel belgesi, sehit/gazi belgesi, muhtaclik belgesi, pasaport (cift vatandaslik varsa) gerekebilir."},
  {"intent":"klu_erasmus","question":"Erasmus basvurusu hakkinda iletisim?","answer":"Erasmus basvuru sorulari icin: erasmusogrenci@klu.edu.tr adresine e-posta gonderebilirsiniz. Destek sadece e-posta yoluyla saglanmaktadir."},
  {"intent":"klu_erasmus","question":"Erasmus hibesiz katilim mumkun mu?","answer":"Evet, ogrenciler hibe almaksizin da Erasmus faaliyetlerine katilabilir. Hibesiz ogrenciler de genel degerlendirmeye tabi tutulur ve ayni surecten gecer; sadece bütce hesaplamalarına dahil edilmez."},
  {"intent":"klu_erasmus","question":"Erasmus kac ay surebilir?","answer":"Mevcut ogrenim kademesi icinde toplam 12 ayi gecmeyecek sekilde Erasmus'tan yararlanilabilir. 2 yari donem kalsa da 1 yari donem icin hibe destegi verilebilir."},

  # ── GENEL ÖĞRENCİ SORULARI ───────────────────────────────────────────────
  {"intent":"klu_ogrenci_sss","question":"KLU kac fakulte var?","answer":"KLU'de 11 fakulte bulunmaktadir: Fen-Edebiyat, IIBF, Teknoloji, Turizm, Muhendislik, Ilahiyat, Mimarlik, Hukuk, Tip, Uygulamali Bilimler, Saglik Bilimleri Fakulteleri. Ayrica Luleburgaz Havacilik ve Uzay Bilimleri Fakultesi de vardir."},
  {"intent":"klu_ogrenci_sss","question":"KLU kac meslek yuksekokulu var?","answer":"KLU'de 7 Meslek Yuksekokulu vardir: Teknik Bilimler, Sosyal Bilimler, Saglik Hizmetleri, Luleburgaz, Babaeski, Pinarhisar ve Vize MYO."},
  {"intent":"klu_ogrenci_sss","question":"KLU kac enstitu var?","answer":"KLU'de 3 enstitu vardir: Fen Bilimleri Enstitusu, Sosyal Bilimler Enstitusu ve Saglik Bilimleri Enstitusu."},
  {"intent":"klu_ogrenci_sss","question":"KLU kac arastirma merkezi var?","answer":"KLU'de 15 Uygulama ve Arastirma Merkezi bulunmaktadir."},
  {"intent":"klu_ogrenci_sss","question":"KLU kampusu nerede?","answer":"KLU ana kampusu Kayali Kampusu, Merkez / Kirklareli adresinde bulunmaktadir."},
  {"intent":"klu_ogrenci_sss","question":"KLU ogrenci sayisi kac?","answer":"KLU'de yaklasik 23.000 ogrenci bulunmaktadir. Guncel bilgi icin www.klu.edu.tr adresini kontrol edin."},
  {"intent":"klu_ogrenci_sss","question":"KLU hangi sehirde?","answer":"Kirklareli Universitesi, Kirklareli ilinde bulunmaktadir. Ana kampus Kayali Kampusu, Merkez / Kirklareli adresindedir."},
  {"intent":"klu_ogrenci_sss","question":"KLU devlet universitesi mi?","answer":"Evet, Kirklareli Universitesi bir devlet universitesidir. 29.05.2007 tarihinde 5662 sayili Kanunla kurulmustur."},

  # ── BÖLÜM/PROGRAM SORULARI ───────────────────────────────────────────────
  {"intent":"klu_bolum","question":"KLU Muhendislik Fakultesinde hangi bolumler var?","answer":"Muhendislik Fakultesinde Bilgisayar Muhendisligi, Elektrik-Elektronik Muhendisligi, Insaat Muhendisligi ve Yazilim Muhendisligi bolumleri bulunmaktadir."},
  {"intent":"klu_bolum","question":"KLU Fen-Edebiyat Fakultesinde hangi bolumler var?","answer":"Fen-Edebiyat Fakultesinde Matematik, Fizik, Kimya, Biyoloji, Turk Dili ve Edebiyati, Tarih, Cografya, Felsefe, Sosyoloji, Psikoloji ve Ingiliz Dili ve Edebiyati bolumleri bulunmaktadir."},
  {"intent":"klu_bolum","question":"KLU Saglik Bilimleri Fakultesinde hangi bolumler var?","answer":"Saglik Bilimleri Fakultesinde Hemsirelik, Fizyoterapi ve Rehabilitasyon, Beslenme ve Diyetetik, Sosyal Hizmet bolumleri bulunmaktadir."},
  {"intent":"klu_bolum","question":"KLU Turizm Fakultesinde hangi bolumler var?","answer":"Turizm Fakultesinde Turizm Isletmeciligi, Gastronomi ve Mutfak Sanatlari, Rekreasyon Yonetimi bolumleri bulunmaktadir."},
  {"intent":"klu_bolum","question":"KLU IIBF hangi bolumler var?","answer":"Iktisadi ve Idari Bilimler Fakultesinde Isletme, Iktisat, Kamu Yonetimi, Uluslararasi Iliskiler, Finans ve Bankacilik bolumleri bulunmaktadir."},
  {"intent":"klu_bolum","question":"KLU Mimarlik Fakultesinde hangi bolumler var?","answer":"Mimarlik Fakultesinde Mimarlik, Ic Mimarlik ve Cevre Tasarimi, Peyzaj Mimarlik bolumleri bulunmaktadir."},
  {"intent":"klu_bolum","question":"KLU Hukuk Fakultesi var mi?","answer":"Evet, KLU Hukuk Fakultesi 2016 yilinda kurulmustur. Iletisim: hukuk@klu.edu.tr, Tel: 0288 214 97 47"},
  {"intent":"klu_bolum","question":"KLU Tip Fakultesi var mi?","answer":"Evet, KLU Tip Fakultesi 2018 yilinda kurulmustur. Iletisim: tip@klu.edu.tr, Tel: 0288 214 95 15"},

  # ── KAMPÜS YAŞAMI ────────────────────────────────────────────────────────
  {"intent":"klu_kampus","question":"KLU yurt imkanlari var mi?","answer":"KLU kampusunde KYK yurtlari ve ozel yurtlar bulunmaktadir. Barinma Destek Birimi icin Ogrenci menusu altindaki ilgili baglantidan bilgi alabilirsiniz."},
  {"intent":"klu_kampus","question":"KLU spor tesisleri var mi?","answer":"KLU kampusunde kapali spor salonu, acik spor alanlari ve fitness merkezi bulunmaktadir. SKS Daire Baskanligi (sks.klu.edu.tr) spor tesislerini yonetmektedir."},
  {"intent":"klu_kampus","question":"KLU yemekhane saatleri nedir?","answer":"Yemekhane saatleri: Ogle yemegi 11:30-14:00, Aksam yemegi 17:30-19:30. Guncel bilgi icin SKS Daire Baskanligi ile iletisime gecin."},
  {"intent":"klu_kampus","question":"KLU saglik merkezi var mi?","answer":"Evet, KLU kampusunde saglik merkezi bulunmaktadir. Saglik hizmetleri icin SKS Daire Baskanligi ile iletisime gecebilirsiniz."},
  {"intent":"klu_kampus","question":"KLU ulasim nasil?","answer":"KLU kampusune kampus servisleri ve sehir ici otobuslerle ulasim saglanabilir. Detayli ulasim bilgisi icin www.klu.edu.tr adresini ziyaret edin."},
  {"intent":"klu_kampus","question":"KLU konferans salonu var mi?","answer":"Evet, KLU kampusunde konferans salonlari ve sosyal etkinlik alanlari bulunmaktadir. Rezervasyon icin ilgili birimle iletisime gecin."},

  # ── GENEL SORULAR ────────────────────────────────────────────────────────
  {"intent":"klu_genel","question":"KLU hangi agda uye?","answer":"KLU, Balkan Universiteler Aginin uyesidir."},
  {"intent":"klu_genel","question":"KLU akreditasyon durumu nedir?","answer":"KLU kalite ve akreditasyon surecleri Kalite Gelistirme Koordinatorlugu tarafindan yurutulmektedir. Guncel bilgi icin www.klu.edu.tr adresini ziyaret edin."},
  {"intent":"klu_genel","question":"KLU lisansustu program var mi?","answer":"Evet, KLU'de Fen Bilimleri, Sosyal Bilimler ve Saglik Bilimleri Enstitulerinde lisansustu programlar bulunmaktadir. Detaylar icin ilgili enstitu sayfalarini ziyaret edin."},
  {"intent":"klu_genel","question":"KLU yabanci uyruklu ogrenci kabul ediyor mu?","answer":"Evet, KLU uluslararasi ogrenci kabul etmektedir. Uluslararasi Ogrenci Ofisi: yuo@klu.edu.tr, Tel: 0288 212 42 11"},
  {"intent":"klu_genel","question":"KLU burs imkanlari var mi?","answer":"KLU ogrencileri icin cesitli burs imkanlari mevcuttur. Detayli bilgi icin Ogrenci Isleri Daire Baskanligi (oidb@klu.edu.tr) ile iletisime gecin."},
  {"intent":"klu_genel","question":"KLU uzaktan egitim var mi?","answer":"Evet, KLU Uzaktan Egitim Uygulama ve Arastirma Merkezi (UZEM) uzaktan egitim hizmetleri sunmaktadir. Iletisim: uzem@klu.edu.tr, Web: uzem.klu.edu.tr"},
  {"intent":"klu_genel","question":"KLU teknoloji transfer ofisi var mi?","answer":"Evet, KLU Teknoloji Transfer Ofisi (TTO) bulunmaktadir. Iletisim: tto@klu.edu.tr, Tel: 444 40 39 Dahili 1029/1082"},
  {"intent":"klu_genel","question":"KLU Kirklareli sehir merkezine uzakligi nedir?","answer":"KLU Kayali Kampusu Kirklareli sehir merkezine yakin konumdadir. Detayli ulasim bilgisi icin www.klu.edu.tr adresini ziyaret edin."},

  # ── YAZIM VARYANTLARI ────────────────────────────────────────────────────
  {"intent":"klu_genel","question":"klu nerede","answer":"Kirklareli Universitesi, Kirklareli ilinde Kayali Kampusu, Merkez / Kirklareli adresinde bulunmaktadir. Telefon: 444 40 39"},
  {"intent":"klu_genel","question":"klu hakkinda bilgi ver","answer":"Kirklareli Universitesi 2007 yilinda kurulmus bir devlet universitesidir. 11 fakulte, 3 enstitu, 7 MYO, 1 yuksekokul, 1 konservatuvar ve 15 arastirma merkezi ile hizmet vermektedir. Web: www.klu.edu.tr, Tel: 444 40 39"},
  {"intent":"klu_iletisim","question":"klu telefon","answer":"KLU ana telefon: 444 40 39, Alternatif: 0 288 212 96 79"},
  {"intent":"klu_iletisim","question":"klu mail","answer":"KLU resmi e-posta: kirklarelirektorluk@klu.edu.tr"},
  {"intent":"klu_iletisim","question":"klu adres","answer":"Kayali Kampusu, Merkez / Kirklareli"},
  {"intent":"klu_erasmus","question":"erasmus ne zaman basvuru","answer":"Erasmus basvuru tarihleri her yil Erasmus Koordinatorlugu tarafindan duyurulur. Guncel tarihler icin erasmus.klu.edu.tr adresini takip edin veya erasmus@klu.edu.tr adresine yazin."},
  {"intent":"klu_erasmus","question":"erasmus kac puan lazim","answer":"Lisans/Onlisans icin kumulatif not ortalamasi en az 2.20/4.00, Yuksek Lisans/Doktora icin en az 2.50/4.00 olmalidir. Ayrica yabanci dil puan kriteri de saglanmalidir."},
  {"intent":"klu_kulupler","question":"kulup nasil kurulur","answer":"Kulup kurmak icin en az 5 KLU ogrencisi ve bir akademik danismanin yazili basvurusu gereklidir. Basvuru dilekce, kulup tuzugu hazirlanip SKSDB'na teslim edilir, Rektorluk onayi alinir."},
  {"intent":"klu_kulupler","question":"kac kulup var","answer":"KLU'de cok sayida aktif ogrenci kulubu bulunmaktadir. Guncel liste icin ogrkulup.klu.edu.tr adresini ziyaret edin."},
  {"intent":"klu_dekanlik","question":"dekanlar kimler","answer":"KLU Dekanlar: Saglik Bilimleri - Prof. Dr. Meryem CAMUR DEMIR, IIBF - Prof. Dr. Raif CERGIBOZAN, Tip - Prof. Dr. Baran Heval KOMUR, Hukuk - Prof. Dr. Ahmet Mithat GUNES, Fen-Edebiyat - Prof. Dr. Ertug CAN, Ilahiyat - Prof. Dr. Mustafa CANLI, Uygulamali Bilimler - Prof. Dr. Suleyman KALE, Muhendislik - Prof. Dr. Erol TURKES, Teknoloji - Prof. Dr. Fatih Semerci, Mimarlik - Prof. Dr. Furuzan CELIK, Turizm - Prof. Dr. Mustafa Cevdet ALTUNEL"},
]

all_data = existing + new_entries
with open('assets/data/chatbot_data.json', 'w', encoding='utf-8') as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print(f'Toplam: {len(all_data)} kayit (eski: {len(existing)}, yeni: {len(new_entries)})')
