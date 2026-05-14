import json

with open('assets/data/chatbot_data.json', encoding='utf-8') as f:
    existing = json.load(f)

new_entries = [

  # ── FEN EDEBİYAT FAKÜLTESİ ───────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Fen Edebiyat Fakültesi hangi bölümler var?",
    "answer": "KLU Fen Edebiyat Fakültesi bölümleri:\n• Batı Dilleri ve Edebiyatları\n• Çağdaş Türk Lehçeleri ve Edebiyatları\n• Eğitim Bilimleri\n• Felsefe\n• Fizik\n• Kimya\n• Matematik\n• Moleküler Biyoloji ve Genetik\n• Mütercim ve Tercümanlık\n• Psikoloji\n• Sosyoloji\n• Tarih\n• Türk Dili ve Edebiyatı\nWeb: fef.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "Fen Edebiyat Fakültesi web sitesi nedir?",
    "answer": "KLU Fen Edebiyat Fakültesi resmi web sitesi: https://fef.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Batı Dilleri ve Edebiyatları bölümü nerede?",
    "answer": "KLU Batı Dilleri ve Edebiyatları Bölümü, Fen Edebiyat Fakültesi bünyesindedir. Web: https://bde.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Moleküler Biyoloji ve Genetik bölümü var mı?",
    "answer": "Evet, KLU Fen Edebiyat Fakültesi bünyesinde Moleküler Biyoloji ve Genetik bölümü bulunmaktadır. Web: https://mbg.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Mütercim Tercümanlık bölümü var mı?",
    "answer": "Evet, KLU Fen Edebiyat Fakültesi bünyesinde Mütercim ve Tercümanlık bölümü bulunmaktadır. Web: https://mtb.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Psikoloji bölümü hangi fakültede?",
    "answer": "KLU Psikoloji Bölümü, Fen Edebiyat Fakültesi bünyesindedir. Web: https://psikoloji.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Eğitim Bilimleri bölümü var mı?",
    "answer": "Evet, KLU Fen Edebiyat Fakültesi bünyesinde Eğitim Bilimleri bölümü bulunmaktadır. Web: https://ebb.klu.edu.tr/"
  },

  # ── HUKUK FAKÜLTESİ ──────────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Hukuk Fakültesi web sitesi nedir?",
    "answer": "KLU Hukuk Fakültesi resmi web sitesi: https://hukuk.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Hukuk Fakültesi hangi bölümler var?",
    "answer": "KLU Hukuk Fakültesi tek bölümlü bir fakültedir. Hukuk lisans programı sunulmaktadır. Web: https://hukuk.klu.edu.tr/"
  },

  # ── İİBF ─────────────────────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "İktisadi ve İdari Bilimler Fakültesi hangi bölümler var?",
    "answer": "KLU İİBF bölümleri:\n• Çalışma Ekonomisi ve Endüstri İlişkileri\n• Ekonometri\n• İktisat\n• İşletme\n• İnsan Kaynakları Yönetimi\n• Maliye\n• Siyaset Bilimi ve Kamu Yönetimi\n• Uluslararası İlişkiler\n• Yönetim Bilişim Sistemleri\nWeb: iibf.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "İİBF web sitesi nedir?",
    "answer": "KLU İktisadi ve İdari Bilimler Fakültesi resmi web sitesi: https://iibf.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Çalışma Ekonomisi bölümü var mı?",
    "answer": "Evet, KLU İİBF bünyesinde Çalışma Ekonomisi ve Endüstri İlişkileri bölümü bulunmaktadır. Web: https://ceko.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Ekonometri bölümü var mı?",
    "answer": "Evet, KLU İİBF bünyesinde Ekonometri bölümü bulunmaktadır. Web: https://ekonometri.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Kamu Yönetimi bölümü var mı?",
    "answer": "Evet, KLU İİBF bünyesinde Siyaset Bilimi ve Kamu Yönetimi bölümü bulunmaktadır. Web: https://kamu.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Yönetim Bilişim Sistemleri bölümü var mı?",
    "answer": "Evet, KLU İİBF bünyesinde Yönetim Bilişim Sistemleri (YBS) bölümü bulunmaktadır. Detaylar için iibf.klu.edu.tr adresini ziyaret edin."
  },
  {
    "intent": "klu_bolum",
    "question": "Maliye bölümü var mı?",
    "answer": "Evet, KLU İİBF bünyesinde Maliye bölümü bulunmaktadır. Web: https://maliye.klu.edu.tr/"
  },

  # ── İLAHİYAT FAKÜLTESİ ───────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "İlahiyat Fakültesi web sitesi nedir?",
    "answer": "KLU İlahiyat Fakültesi resmi web sitesi: https://ilahiyat.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "İlahiyat Fakültesi hangi bölümler var?",
    "answer": "KLU İlahiyat Fakültesi tek bölümlü bir fakültedir. İlahiyat lisans programı sunulmaktadır. Web: https://ilahiyat.klu.edu.tr/"
  },

  # ── MİMARLIK FAKÜLTESİ ───────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Mimarlık Fakültesi hangi bölümler var?",
    "answer": "KLU Mimarlık Fakültesi bölümleri:\n• Mimarlık\n• Peyzaj Mimarlığı\n• Şehir ve Bölge Planlama\n• İç Mimarlık\nWeb: mimarlik.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "Mimarlık Fakültesi web sitesi nedir?",
    "answer": "KLU Mimarlık Fakültesi resmi web sitesi: https://mimarlik.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Peyzaj Mimarlığı bölümü var mı?",
    "answer": "Evet, KLU Mimarlık Fakültesi bünyesinde Peyzaj Mimarlığı bölümü bulunmaktadır. Web: https://peyzaj.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Şehir ve Bölge Planlama bölümü var mı?",
    "answer": "Evet, KLU Mimarlık Fakültesi bünyesinde Şehir ve Bölge Planlama bölümü bulunmaktadır. Web: https://sbp.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "İç Mimarlık bölümü var mı?",
    "answer": "Evet, KLU Mimarlık Fakültesi bünyesinde İç Mimarlık bölümü bulunmaktadır. Web: https://icmimarlik.klu.edu.tr/"
  },

  # ── MÜHENDİSLİK FAKÜLTESİ ────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Mühendislik Fakültesi hangi bölümler var?",
    "answer": "KLU Mühendislik Fakültesi bölümleri:\n• Elektrik Elektronik Mühendisliği\n• Endüstri Mühendisliği\n• Gıda Mühendisliği\n• İnşaat Mühendisliği\n• Makine Mühendisliği\n• Yazılım Mühendisliği\nWeb: muh.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "Mühendislik Fakültesi web sitesi nedir?",
    "answer": "KLU Mühendislik Fakültesi resmi web sitesi: https://muh.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Elektrik Elektronik Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Mühendislik Fakültesi bünyesinde Elektrik Elektronik Mühendisliği bölümü bulunmaktadır. Web: https://eem.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Endüstri Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Mühendislik Fakültesi bünyesinde Endüstri Mühendisliği bölümü bulunmaktadır. Web: https://endustri.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Gıda Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Mühendislik Fakültesi bünyesinde Gıda Mühendisliği bölümü bulunmaktadır. Web: https://gida.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Makine Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Mühendislik Fakültesi bünyesinde Makine Mühendisliği bölümü bulunmaktadır. Web: https://makine.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Yazılım Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Mühendislik Fakültesi bünyesinde Yazılım Mühendisliği bölümü bulunmaktadır. Web: https://yazilim.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "İnşaat Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Mühendislik Fakültesi bünyesinde İnşaat Mühendisliği bölümü bulunmaktadır. Web: https://insaat.klu.edu.tr/"
  },

  # ── SAĞLIK BİLİMLERİ FAKÜLTESİ ───────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Sağlık Bilimleri Fakültesi hangi bölümler var?",
    "answer": "KLU Sağlık Bilimleri Fakültesi bölümleri:\n• Beslenme ve Diyetetik\n• Çocuk Gelişimi\n• Ebelik\n• Fizyoterapi ve Rehabilitasyon\n• Hemşirelik\n• Sağlık Yönetimi\n• Sosyal Hizmet\nWeb: sbf.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "Sağlık Bilimleri Fakültesi web sitesi nedir?",
    "answer": "KLU Sağlık Bilimleri Fakültesi resmi web sitesi: https://sbf.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Beslenme ve Diyetetik bölümü var mı?",
    "answer": "Evet, KLU Sağlık Bilimleri Fakültesi bünyesinde Beslenme ve Diyetetik bölümü bulunmaktadır. Web: https://beslenme.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Çocuk Gelişimi bölümü var mı?",
    "answer": "Evet, KLU Sağlık Bilimleri Fakültesi bünyesinde Çocuk Gelişimi bölümü bulunmaktadır. Web: https://cocuk.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Ebelik bölümü var mı?",
    "answer": "Evet, KLU Sağlık Bilimleri Fakültesi bünyesinde Ebelik bölümü bulunmaktadır. Web: https://ebelik.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Fizyoterapi ve Rehabilitasyon bölümü var mı?",
    "answer": "Evet, KLU Sağlık Bilimleri Fakültesi bünyesinde Fizyoterapi ve Rehabilitasyon bölümü bulunmaktadır. Web: https://ftr.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Hemşirelik bölümü var mı?",
    "answer": "Evet, KLU Sağlık Bilimleri Fakültesi bünyesinde Hemşirelik bölümü bulunmaktadır. Web: https://hemsirelik.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Sağlık Yönetimi bölümü var mı?",
    "answer": "Evet, KLU Sağlık Bilimleri Fakültesi bünyesinde Sağlık Yönetimi bölümü bulunmaktadır. Web: https://saglikyonetimi.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Sosyal Hizmet bölümü var mı?",
    "answer": "Evet, KLU Sağlık Bilimleri Fakültesi bünyesinde Sosyal Hizmet bölümü bulunmaktadır. Web: https://sosyalhizmet.klu.edu.tr/"
  },

  # ── TEKNOLOJİ FAKÜLTESİ ──────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Teknoloji Fakültesi hangi bölümler var?",
    "answer": "KLU Teknoloji Fakültesi bölümleri:\n• Enerji Sistemleri Mühendisliği\n• Mekatronik Mühendisliği\nWeb: tf.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "Teknoloji Fakültesi web sitesi nedir?",
    "answer": "KLU Teknoloji Fakültesi resmi web sitesi: https://tf.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Enerji Sistemleri Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Teknoloji Fakültesi bünyesinde Enerji Sistemleri Mühendisliği bölümü bulunmaktadır. Web: https://esm.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Mekatronik Mühendisliği bölümü var mı?",
    "answer": "Evet, KLU Teknoloji Fakültesi bünyesinde Mekatronik Mühendisliği bölümü bulunmaktadır. Web: https://mekatronik.klu.edu.tr/"
  },

  # ── TIP FAKÜLTESİ ────────────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Tıp Fakültesi web sitesi nedir?",
    "answer": "KLU Tıp Fakültesi resmi web sitesi: https://tip.klu.edu.tr/"
  },

  # ── TURİZM FAKÜLTESİ ─────────────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Turizm Fakültesi hangi bölümler var?",
    "answer": "KLU Turizm Fakültesi bölümleri:\n• Gastronomi ve Mutfak Sanatları\n• Rekreasyon Yönetimi\n• Turizm İşletmeciliği\n• Turizm Rehberliği\nWeb: turizm.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "Turizm Fakültesi web sitesi nedir?",
    "answer": "KLU Turizm Fakültesi resmi web sitesi: https://turizm.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Gastronomi ve Mutfak Sanatları bölümü var mı?",
    "answer": "Evet, KLU Turizm Fakültesi bünyesinde Gastronomi ve Mutfak Sanatları bölümü bulunmaktadır. Web: https://turizmgms.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Rekreasyon Yönetimi bölümü var mı?",
    "answer": "Evet, KLU Turizm Fakültesi bünyesinde Rekreasyon Yönetimi bölümü bulunmaktadır. Web: https://turizmry.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Turizm Rehberliği bölümü var mı?",
    "answer": "Evet, KLU Turizm Fakültesi bünyesinde Turizm Rehberliği bölümü bulunmaktadır. Web: https://turizmsitr.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Turizm İşletmeciliği bölümü var mı?",
    "answer": "Evet, KLU Turizm Fakültesi bünyesinde Turizm İşletmeciliği bölümü bulunmaktadır. Web: https://turizmib.klu.edu.tr/"
  },

  # ── UYGULAMALI BİLİMLER FAKÜLTESİ ────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "Uygulamalı Bilimler Fakültesi hangi bölümler var?",
    "answer": "KLU Uygulamalı Bilimler Fakültesi bölümleri:\n• Finans ve Bankacılık\n• Muhasebe ve Finans Yönetimi\n• Uluslararası Ticaret ve Lojistik\nWeb: ubf.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "Uygulamalı Bilimler Fakültesi web sitesi nedir?",
    "answer": "KLU Uygulamalı Bilimler Fakültesi resmi web sitesi: https://ubf.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Finans ve Bankacılık bölümü var mı?",
    "answer": "Evet, KLU Uygulamalı Bilimler Fakültesi bünyesinde Finans ve Bankacılık bölümü bulunmaktadır. Web: https://fvb.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Muhasebe ve Finans Yönetimi bölümü var mı?",
    "answer": "Evet, KLU Uygulamalı Bilimler Fakültesi bünyesinde Muhasebe ve Finans Yönetimi bölümü bulunmaktadır. Web: https://mvf.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "Uluslararası Ticaret ve Lojistik bölümü var mı?",
    "answer": "Evet, KLU Uygulamalı Bilimler Fakültesi bünyesinde Uluslararası Ticaret ve Lojistik bölümü bulunmaktadır. Web: https://utl.klu.edu.tr/"
  },

  # ── TÜM FAKÜLTELERİN LİSTESİ ─────────────────────────────────────────────
  {
    "intent": "klu_bolum",
    "question": "KLU fakülteleri listesi nedir?",
    "answer": "KLU Fakülteleri:\n1. Fen Edebiyat Fakültesi (fef.klu.edu.tr)\n2. Hukuk Fakültesi (hukuk.klu.edu.tr)\n3. İktisadi ve İdari Bilimler Fakültesi (iibf.klu.edu.tr)\n4. İlahiyat Fakültesi (ilahiyat.klu.edu.tr)\n5. Mimarlık Fakültesi (mimarlik.klu.edu.tr)\n6. Mühendislik Fakültesi (muh.klu.edu.tr)\n7. Sağlık Bilimleri Fakültesi (sbf.klu.edu.tr)\n8. Teknoloji Fakültesi (tf.klu.edu.tr)\n9. Tıp Fakültesi (tip.klu.edu.tr)\n10. Turizm Fakültesi (turizm.klu.edu.tr)\n11. Uygulamalı Bilimler Fakültesi (ubf.klu.edu.tr)\nDetaylar: www.klu.edu.tr"
  },
  {
    "intent": "klu_bolum",
    "question": "KLU hangi fakülteler var?",
    "answer": "KLU'de 11 fakülte bulunmaktadır:\n• Fen Edebiyat\n• Hukuk\n• İktisadi ve İdari Bilimler (İİBF)\n• İlahiyat\n• Mimarlık\n• Mühendislik\n• Sağlık Bilimleri\n• Teknoloji\n• Tıp\n• Turizm\n• Uygulamalı Bilimler\nDetaylar için www.klu.edu.tr adresini ziyaret edin."
  },
  {
    "intent": "klu_bolum",
    "question": "Bilgisayar Mühendisliği bölümü var mı?",
    "answer": "KLU'de Bilgisayar Mühendisliği bölümü bulunmamaktadır. Yazılım Mühendisliği (yazilim.klu.edu.tr) ve Elektrik Elektronik Mühendisliği (eem.klu.edu.tr) bölümleri mevcuttur."
  },
  {
    "intent": "klu_bolum",
    "question": "Çağdaş Türk Lehçeleri bölümü var mı?",
    "answer": "Evet, KLU Fen Edebiyat Fakültesi bünyesinde Çağdaş Türk Lehçeleri ve Edebiyatları bölümü bulunmaktadır. Web: https://ctle.klu.edu.tr/"
  },
  {
    "intent": "klu_bolum",
    "question": "İnsan Kaynakları Yönetimi bölümü var mı?",
    "answer": "Evet, KLU İİBF bünyesinde İnsan Kaynakları Yönetimi bölümü bulunmaktadır. Detaylar için iibf.klu.edu.tr adresini ziyaret edin."
  },
  {
    "intent": "klu_bolum",
    "question": "Uluslararası İlişkiler bölümü var mı?",
    "answer": "Evet, KLU İİBF bünyesinde Uluslararası İlişkiler bölümü bulunmaktadır. Web: https://uluslararasi.klu.edu.tr/"
  },
]

all_data = existing + new_entries

with open('assets/data/chatbot_data.json', 'w', encoding='utf-8') as f:
    json.dump(all_data, f, ensure_ascii=False, indent=2)

print(f'Toplam: {len(all_data)} kayit (eski: {len(existing)}, yeni: {len(new_entries)})')
