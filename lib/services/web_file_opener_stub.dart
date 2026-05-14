import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

/// Mobil platformlar için dosya açma
Future<void> openFileInBrowser(String url, {String? fileName}) async {
  try {
    // Base64 data URL kontrolü
    if (url.startsWith('data:')) {
      await _openBase64File(url, fileName);
      return;
    }

    // Firebase Storage veya diğer URL'ler için
    final uri = Uri.parse(url);

    // URL'yi tarayıcıda veya uygun uygulamada aç
    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('URL başlatılamadı: $url');
        throw Exception('Dosya açılamadı. Lütfen tarayıcınızı kontrol edin.');
      }
    } else {
      debugPrint('URL desteklenmiyor: $url');
      throw Exception('Bu dosya türü desteklenmiyor.');
    }
  } catch (e) {
    debugPrint('Dosya açma hatası: $e');
    rethrow;
  }
}

/// Base64 data URL'yi geçici dosyaya kaydet ve aç
Future<void> _openBase64File(String dataUrl, String? fileName) async {
  try {
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex == -1) {
      throw Exception('Geçersiz data URL formatı');
    }

    // MIME type ve base64 verisini ayır
    final meta = dataUrl.substring(5, commaIndex); // "application/pdf;base64"
    final mimeType = meta.split(';').first;
    final base64Data = dataUrl.substring(commaIndex + 1);

    // Base64'ü decode et
    final bytes = base64Decode(base64Data);

    // Dosya uzantısını belirle
    String extension = '.pdf';
    if (mimeType.contains('pdf')) {
      extension = '.pdf';
    } else if (mimeType.contains('image')) {
      if (mimeType.contains('png')) {
        extension = '.png';
      } else if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
        extension = '.jpg';
      }
    } else if (mimeType.contains('text')) {
      extension = '.txt';
    }

    // Dosya adını oluştur
    final name = fileName ?? 'dosya_${DateTime.now().millisecondsSinceEpoch}';
    final finalFileName = name.endsWith(extension) ? name : '$name$extension';

    // Geçici dizine kaydet
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$finalFileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    debugPrint('Dosya kaydedildi: $filePath');

    // Dosyayı aç
    final result = await OpenFile.open(filePath);

    if (result.type != ResultType.done) {
      debugPrint('Dosya açma sonucu: ${result.type} - ${result.message}');
      throw Exception('Dosya açılamadı: ${result.message}');
    }
  } catch (e) {
    debugPrint('Base64 dosya açma hatası: $e');
    rethrow;
  }
}

/// Mobil platformlar için dosya indirme
Future<void> downloadFileInBrowser(String url, {String? fileName}) async {
  try {
    // Base64 data URL kontrolü
    if (url.startsWith('data:')) {
      await _downloadBase64File(url, fileName);
      return;
    }

    // Mobilde indirme genellikle tarayıcı üzerinden yapılır
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('İndirme başlatılamadı: $url');
        throw Exception(
          'İndirme başlatılamadı. Lütfen tarayıcınızı kontrol edin.',
        );
      }
    } else {
      debugPrint('URL desteklenmiyor: $url');
      throw Exception('Bu dosya türü desteklenmiyor.');
    }
  } catch (e) {
    debugPrint('Dosya indirme hatası: $e');
    rethrow;
  }
}

/// Base64 data URL'yi Downloads klasörüne kaydet
Future<void> _downloadBase64File(String dataUrl, String? fileName) async {
  try {
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex == -1) {
      throw Exception('Geçersiz data URL formatı');
    }

    // MIME type ve base64 verisini ayır
    final meta = dataUrl.substring(5, commaIndex);
    final mimeType = meta.split(';').first;
    final base64Data = dataUrl.substring(commaIndex + 1);

    // Base64'ü decode et
    final bytes = base64Decode(base64Data);

    // Dosya uzantısını belirle
    String extension = '.pdf';
    if (mimeType.contains('pdf')) {
      extension = '.pdf';
    } else if (mimeType.contains('image')) {
      if (mimeType.contains('png')) {
        extension = '.png';
      } else if (mimeType.contains('jpeg') || mimeType.contains('jpg')) {
        extension = '.jpg';
      }
    } else if (mimeType.contains('text')) {
      extension = '.txt';
    }

    // Dosya adını oluştur
    final name = fileName ?? 'dosya_${DateTime.now().millisecondsSinceEpoch}';
    final finalFileName = name.endsWith(extension) ? name : '$name$extension';

    // Downloads dizinine kaydet
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        downloadsDir = await getExternalStorageDirectory();
      }
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    if (downloadsDir == null) {
      throw Exception('İndirme dizini bulunamadı');
    }

    final filePath = '${downloadsDir.path}/$finalFileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    debugPrint('Dosya indirildi: $filePath');

    // Dosyayı aç
    await OpenFile.open(filePath);
  } catch (e) {
    debugPrint('Base64 dosya indirme hatası: $e');
    rethrow;
  }
}
