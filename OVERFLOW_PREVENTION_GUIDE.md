# Overflow Hatalarını Önleme Rehberi

Bu dokümanda uygulamada overflow hatalarını önlemek için uygulanması gereken kurallar ve best practice'ler açıklanmaktadır.

## 🎯 Genel Kurallar

### 1. Text Widget'ları
Her Text widget'ında mutlaka `overflow` ve `maxLines` parametrelerini kullanın:

```dart
// ❌ YANLIŞ
Text('Çok uzun bir metin...')

// ✅ DOĞRU
Text(
  'Çok uzun bir metin...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### 2. Row İçinde Text
Row içinde Text kullanırken mutlaka `Expanded` veya `Flexible` ile sarın:

```dart
// ❌ YANLIŞ
Row(
  children: [
    Icon(Icons.person),
    Text('Uzun kullanıcı adı...'),
  ],
)

// ✅ DOĞRU
Row(
  children: [
    Icon(Icons.person),
    SizedBox(width: 8),
    Expanded(
      child: Text(
        'Uzun kullanıcı adı...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

### 3. Column İçinde Scrollable İçerik
Column içinde liste veya uzun içerik varsa `SingleChildScrollView` kullanın:

```dart
// ❌ YANLIŞ
Column(
  children: [
    Header(),
    VeryLongContent(),
    Footer(),
  ],
)

// ✅ DOĞRU
SingleChildScrollView(
  child: Column(
    children: [
      Header(),
      VeryLongContent(),
      Footer(),
    ],
  ),
)
```

### 4. Scaffold Yapılandırması
Form içeren sayfalarda `resizeToAvoidBottomInset: true` kullanın:

```dart
// ✅ DOĞRU
Scaffold(
  resizeToAvoidBottomInset: true,
  body: SingleChildScrollView(
    child: Form(...),
  ),
)
```

### 5. TextField ve TextFormField
Keyboard açıldığında overflow önlemek için:

```dart
// ✅ DOĞRU
Scaffold(
  resizeToAvoidBottomInset: true,
  body: SingleChildScrollView(
    child: Column(
      children: [
        TextField(
          textInputAction: TextInputAction.next,
          maxLines: 1,
        ),
      ],
    ),
  ),
)
```

### 6. ListView ve GridView
Sabit yükseklikte ListView kullanırken `shrinkWrap` kullanın:

```dart
// ❌ YANLIŞ (Column içinde)
Column(
  children: [
    ListView(children: [...]),
  ],
)

// ✅ DOĞRU
Column(
  children: [
    Expanded(
      child: ListView(children: [...]),
    ),
  ],
)

// VEYA

Column(
  children: [
    ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [...],
    ),
  ],
)
```

### 7. Container ve SizedBox
Sabit boyutlar yerine responsive boyutlar kullanın:

```dart
// ❌ YANLIŞ
Container(
  width: 500,  // Küçük ekranlarda overflow
  child: ...,
)

// ✅ DOĞRU
Container(
  width: MediaQuery.of(context).size.width * 0.9,
  child: ...,
)

// VEYA

LayoutBuilder(
  builder: (context, constraints) {
    return Container(
      width: constraints.maxWidth * 0.9,
      child: ...,
    );
  },
)
```

### 8. Padding ve Margin
Responsive padding kullanın:

```dart
// ❌ YANLIŞ
Padding(
  padding: EdgeInsets.all(50),  // Küçük ekranlarda çok fazla
  child: ...,
)

// ✅ DOĞRU
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 32,
    vertical: 16,
  ),
  child: ...,
)
```

## 🛠️ Yardımcı Widget'lar

Projede overflow önlemek için hazır widget'lar:

### SafeText
```dart
import 'package:bitirme/widgets/safe_text.dart';

SafeText(
  'Uzun metin...',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### FlexibleText
```dart
Row(
  children: [
    Icon(Icons.person),
    FlexibleText('Uzun kullanıcı adı...'),
  ],
)
```

### ExpandedText
```dart
Row(
  children: [
    Icon(Icons.person),
    ExpandedText('Uzun kullanıcı adı...'),
  ],
)
```

### ResponsiveUtils
```dart
import 'package:bitirme/utils/responsive_utils.dart';

// Responsive padding
double padding = ResponsiveUtils.getHorizontalPadding(context);

// Responsive font size
double fontSize = ResponsiveUtils.getResponsiveFontSize(context, 16);

// Güvenli metin
String safeText = ResponsiveUtils.getSafeText('Uzun metin...', 50);
```

## 📱 Test Etme

Overflow hatalarını test etmek için:

1. **Küçük ekran cihazlarda test edin** (iPhone SE, küçük Android telefonlar)
2. **Büyük font boyutlarıyla test edin** (Ayarlar > Ekran > Font Boyutu)
3. **Yatay modda test edin** (Landscape orientation)
4. **Uzun metinlerle test edin** (Çok uzun kullanıcı adları, başlıklar, vb.)

## 🔍 Sık Karşılaşılan Hatalar

### 1. "RenderFlex overflowed by X pixels"
**Sebep:** Row veya Column içinde sabit genişlikte widget'lar
**Çözüm:** Expanded veya Flexible kullanın

### 2. "Bottom overflowed by X pixels"
**Sebep:** Keyboard açıldığında içerik sığmıyor
**Çözüm:** SingleChildScrollView ve resizeToAvoidBottomInset: true

### 3. "A RenderFlex overflowed on the right"
**Sebep:** Row içinde Text widget'ı Expanded olmadan kullanılmış
**Çözüm:** Text'i Expanded ile sarın

## ✅ Checklist

Yeni sayfa eklerken kontrol edin:

- [ ] Tüm Text widget'larında overflow ve maxLines var mı?
- [ ] Row içindeki Text'ler Expanded/Flexible ile sarılı mı?
- [ ] Scrollable içerik SingleChildScrollView içinde mi?
- [ ] Form sayfalarında resizeToAvoidBottomInset: true var mı?
- [ ] Sabit boyutlar yerine responsive boyutlar kullanılmış mı?
- [ ] Küçük ekranlarda test edildi mi?
- [ ] Büyük font boyutlarıyla test edildi mi?

## 📚 Kaynaklar

- [Flutter Layout Cheat Sheet](https://medium.com/flutter-community/flutter-layout-cheat-sheet-5363348d037e)
- [Dealing with Overflow in Flutter](https://docs.flutter.dev/ui/layout/constraints)
- [Responsive Design in Flutter](https://docs.flutter.dev/ui/layout/responsive/adaptive-responsive)
