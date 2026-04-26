# KLU UniConnect

Kırklareli Üniversitesi öğrencileri için geliştirilmiş kapsamlı kampüs uygulaması.

## 🚀 Özellikler

### 🔐 Güvenlik ve Kimlik Doğrulama
- **Güvenli Kayıt ve Giriş**: Firebase Authentication ile güvenli kullanıcı yönetimi
- **E-posta Doğrulama**: Hesap güvenliği için zorunlu e-posta doğrulaması
- **Şifre Güvenliği**: Güçlü şifre gereksinimleri ve şifre gücü göstergesi
- **Şifre Sıfırlama**: E-posta ile güvenli şifre sıfırlama

### 👤 Kullanıcı Profili
- **Profil Fotoğrafı**: Kamera veya galeriden fotoğraf seçme
- **Kişisel Bilgiler**: Ad, soyad, e-posta, telefon, bölüm, sınıf bilgileri
- **Rol Yönetimi**: Öğrenci ve kulüp başkanı rolleri

### 📱 Gelişmiş UI/UX
- **Material Design 3**: Modern ve tutarlı tasarım
- **Tema Desteği**: Açık/koyu tema seçenekleri
- **Renk Özelleştirme**: Kişiselleştirilebilir ana renk seçenekleri
- **Responsive Tasarım**: Mobil ve tablet uyumlu arayüz
- **Loading Animasyonları**: Shimmer efektleri ve yükleme göstergeleri

### 🔔 Bildirim Sistemi
- **Push Notifications**: Firebase Cloud Messaging ile anlık bildirimler
- **Local Notifications**: Uygulama içi bildirimler
- **Bildirim Yönetimi**: Okundu/okunmadı durumu takibi
- **Kategori Bazlı Bildirimler**: Etkinlik, duyuru, sistem bildirimleri

### 🌐 Network ve Bağlantı
- **Bağlantı Durumu**: Gerçek zamanlı internet bağlantısı takibi
- **Offline Destek**: Bağlantı kesildiğinde kullanıcı bilgilendirmesi
- **Retry Mekanizması**: Başarısız işlemler için otomatik yeniden deneme

### 🛡️ Güvenlik Özellikleri
- **Veri Şifreleme**: Hassas verilerin güvenli saklanması
- **Input Sanitization**: XSS ve injection saldırılarına karşı koruma
- **Secure Token Generation**: Güvenli token üretimi
- **Data Masking**: E-posta ve telefon numarası maskeleme

### 📊 Hata Yönetimi
- **Kapsamlı Hata Yakalama**: Firebase, network ve dosya hatalarının yönetimi
- **Kullanıcı Dostu Mesajlar**: Teknik hataların anlaşılır mesajlara çevrilmesi
- **Hata Raporlama**: Detaylı hata logları ve debugging desteği

## 🛠️ Teknoloji Stack

### Frontend
- **Flutter**: Cross-platform mobil uygulama geliştirme
- **Dart**: Programlama dili
- **Material Design 3**: UI framework

### Backend ve Servisler
- **Firebase Authentication**: Kullanıcı kimlik doğrulama
- **Cloud Firestore**: NoSQL veritabanı
- **Firebase Storage**: Dosya depolama
- **Firebase Cloud Messaging**: Push notifications

### State Management
- **Provider**: Durum yönetimi
- **Shared Preferences**: Yerel veri saklama

### Güvenlik
- **Crypto**: Şifreleme işlemleri
- **Security Service**: Özel güvenlik katmanı

### Network ve Connectivity
- **Dio**: HTTP client
- **Connectivity Plus**: Bağlantı durumu takibi

### UI/UX Kütüphaneleri
- **Shimmer**: Loading animasyonları
- **Lottie**: Gelişmiş animasyonlar
- **Cached Network Image**: Resim önbellekleme
- **Image Picker**: Kamera ve galeri erişimi

## 📋 Gereksinimler

### Sistem Gereksinimleri
- **Flutter**: 3.8.0+
- **Dart**: 3.8.0+
- **Android**: API 21+ (Android 5.0+)
- **iOS**: 12.0+

### Geliştirme Ortamı
- **Android Studio** veya **VS Code**
- **Xcode** (iOS geliştirme için)
- **Firebase CLI**

## 🚀 Kurulum

### 1. Projeyi Klonlayın
```bash
git clone https://github.com/your-username/klu-uniconnect.git
cd klu-uniconnect
```

### 2. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 3. Firebase Konfigürasyonu
1. [Firebase Console](https://console.firebase.google.com/)'da yeni proje oluşturun
2. Android ve iOS uygulamalarını ekleyin
3. `google-services.json` dosyasını `android/app/` klasörüne kopyalayın
4. `GoogleService-Info.plist` dosyasını `ios/Runner/` klasörüne kopyalayın

### 4. Firebase Servislerini Etkinleştirin
- **Authentication**: E-posta/şifre provider'ını etkinleştirin
- **Firestore Database**: Veritabanını oluşturun
- **Storage**: Dosya depolama servisini etkinleştirin
- **Cloud Messaging**: Push notification servisini etkinleştirin

### 5. Uygulamayı Çalıştırın
```bash
flutter run
```

## 🧪 Test

### Unit Testleri Çalıştırma
```bash
flutter test
```

### Test Kapsamı
- **Security Service**: Şifreleme ve güvenlik fonksiyonları
- **Validators**: Form validasyon kuralları
- **Widget Tests**: UI bileşenleri

### Test Dosyaları
- `test/services/security_service_test.dart`
- `test/utils/validators_test.dart`
- `test/widgets/password_strength_indicator_test.dart`

## 📁 Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── models/                   # Veri modelleri
├── screens/                  # Ekran widget'ları
│   ├── register_page.dart    # Kayıt ekranı
│   └── login_page.dart       # Giriş ekranı
├── services/                 # İş mantığı servisleri
│   ├── auth_service.dart     # Kimlik doğrulama
│   ├── security_service.dart # Güvenlik işlemleri
│   ├── connectivity_service.dart # Bağlantı yönetimi
│   ├── notification_service.dart # Bildirim yönetimi
│   └── image_compress.dart   # Resim sıkıştırma
├── utils/                    # Yardımcı sınıflar
│   ├── validators.dart       # Form validasyonları
│   └── error_handler.dart    # Hata yönetimi
├── widgets/                  # Yeniden kullanılabilir widget'lar
│   ├── profile_photo_picker.dart
│   ├── password_strength_indicator.dart
│   ├── loading_widget.dart
│   └── error_widget.dart
└── providers/                # State management
    ├── auth_provider.dart    # Kimlik doğrulama durumu
    └── theme_provider.dart   # Tema yönetimi
```

## 🔧 Konfigürasyon

### Firebase Güvenlik Kuralları

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar sadece kendi verilerine erişebilir
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bildirimler
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🚀 Deployment

### Android APK Oluşturma
```bash
flutter build apk --release
```

### iOS IPA Oluşturma
```bash
flutter build ios --release
```

### App Bundle (Google Play)
```bash
flutter build appbundle --release
```

## 🤝 Katkıda Bulunma

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Proje Sahibi**: [Your Name]
- **E-posta**: your.email@example.com
- **GitHub**: [@your-username](https://github.com/your-username)

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Firebase ekibine güçlü backend servisleri için
- Kırklareli Üniversitesi'ne ilham için

---

**KLU UniConnect** - Kampüs hayatını dijitalleştiren, öğrencileri birbirine bağlayan platform 🎓