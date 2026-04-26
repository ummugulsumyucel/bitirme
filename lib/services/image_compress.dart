import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

// Web için conditional import
import 'image_compress_stub.dart'
    if (dart.library.html) 'image_compress_web.dart';

/// Resim sıkıştırma servisi
class ImageCompress {
  /// Resmi sıkıştır ve boyutunu küçült (Mobile/Desktop)
  static Future<File> compressImage(
    File file, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      // Dosyayı oku
      final bytes = await file.readAsBytes();

      // Resmi decode et
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Resim decode edilemedi');
      }

      // Boyutları hesapla
      final (newWidth, newHeight) = _calculateNewSize(
        image.width,
        image.height,
        maxWidth,
        maxHeight,
      );

      // Resmi yeniden boyutlandır
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // JPEG formatında encode et
      final compressedBytes = img.encodeJpg(resized, quality: quality);

      // Geçici dosya oluştur
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Sıkıştırılmış veriyi yaz
      await tempFile.writeAsBytes(compressedBytes);

      return tempFile;
    } catch (e) {
      debugPrint('ImageCompress.compressImage error: $e');
      // Hata durumunda orijinal dosyayı döndür
      return file;
    }
  }

  /// Web için resim sıkıştırma
  static Future<Uint8List> compressImageWeb(
    Uint8List bytes,
    String mime, {
    int maxDimension = 600,
    double quality = 0.75,
  }) async {
    if (kIsWeb) {
      // Web platformunda canvas API kullan
      return await compressImageWebImpl(
        bytes,
        mime,
        maxDimension: maxDimension,
        quality: quality,
      );
    } else {
      // Mobile/Desktop platformlarda image package kullan
      try {
        final image = img.decodeImage(bytes);
        if (image == null) return bytes;

        // Boyutları hesapla
        final (newWidth, newHeight) = _calculateNewSize(
          image.width,
          image.height,
          maxDimension,
          maxDimension,
        );

        // Resmi yeniden boyutlandır
        final resized = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.linear,
        );

        // Encode et
        final compressedBytes = mime.contains('png')
            ? img.encodePng(resized)
            : img.encodeJpg(resized, quality: (quality * 100).round());

        return Uint8List.fromList(compressedBytes);
      } catch (e) {
        debugPrint('ImageCompress.compressImageWeb error: $e');
        return bytes;
      }
    }
  }

  /// Yeni boyutları hesapla (aspect ratio korunarak)
  static (int, int) _calculateNewSize(
    int originalWidth,
    int originalHeight,
    int maxWidth,
    int maxHeight,
  ) {
    if (originalWidth <= maxWidth && originalHeight <= maxHeight) {
      return (originalWidth, originalHeight);
    }

    final aspectRatio = originalWidth / originalHeight;

    int newWidth, newHeight;

    if (aspectRatio > 1) {
      // Landscape
      newWidth = maxWidth;
      newHeight = (maxWidth / aspectRatio).round();

      if (newHeight > maxHeight) {
        newHeight = maxHeight;
        newWidth = (maxHeight * aspectRatio).round();
      }
    } else {
      // Portrait veya kare
      newHeight = maxHeight;
      newWidth = (maxHeight * aspectRatio).round();

      if (newWidth > maxWidth) {
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      }
    }

    return (newWidth, newHeight);
  }

  /// Resim dosya boyutunu kontrol et
  static Future<bool> isFileSizeValid(File file, {int maxSizeInMB = 5}) async {
    try {
      final bytes = await file.readAsBytes();
      final sizeInMB = bytes.length / (1024 * 1024);
      return sizeInMB <= maxSizeInMB;
    } catch (e) {
      debugPrint('ImageCompress.isFileSizeValid error: $e');
      return false;
    }
  }

  /// Bytes için dosya boyutu kontrolü
  static bool isByteSizeValid(Uint8List bytes, {int maxSizeInMB = 5}) {
    final sizeInMB = bytes.length / (1024 * 1024);
    return sizeInMB <= maxSizeInMB;
  }

  /// Desteklenen resim formatlarını kontrol et
  static bool isSupportedImageFormat(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }
}
