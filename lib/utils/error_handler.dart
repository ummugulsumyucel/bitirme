import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Uygulama genelinde hata yönetimi
class ErrorHandler {
  /// Firebase Auth hatalarını kullanıcı dostu mesajlara çevir
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı. Lütfen tekrar deneyin.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf. Daha güçlü bir şifre seçin.';
      case 'network-request-failed':
        return 'İnternet bağlantısı hatası. Bağlantınızı kontrol edin.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen bir süre sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor.';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor.';
      default:
        return e.message ?? 'Bilinmeyen bir hata oluştu.';
    }
  }

  /// Firestore hatalarını kullanıcı dostu mesajlara çevir
  static String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 'unavailable':
        return 'Sunucu şu anda kullanılamıyor. Lütfen tekrar deneyin.';
      case 'deadline-exceeded':
        return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case 'resource-exhausted':
        return 'Sunucu kapasitesi doldu. Lütfen daha sonra tekrar deneyin.';
      case 'failed-precondition':
        return 'İşlem gereksinimleri karşılanmadı.';
      case 'aborted':
        return 'İşlem iptal edildi. Lütfen tekrar deneyin.';
      case 'out-of-range':
        return 'Geçersiz veri aralığı.';
      case 'unimplemented':
        return 'Bu özellik henüz desteklenmiyor.';
      case 'internal':
        return 'Sunucu hatası oluştu. Lütfen tekrar deneyin.';
      case 'data-loss':
        return 'Veri kaybı oluştu. Lütfen tekrar deneyin.';
      default:
        return e.message ?? 'Veritabanı hatası oluştu.';
    }
  }

  /// Network hatalarını kontrol et
  static String getNetworkErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'İnternet bağlantısı yok. Bağlantınızı kontrol edin.';
    }
    if (error is TimeoutException) {
      return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
    }
    if (error is HttpException) {
      return 'Sunucu hatası oluştu. Lütfen tekrar deneyin.';
    }
    return 'Bağlantı hatası oluştu. Lütfen tekrar deneyin.';
  }

  /// Dosya işlem hatalarını kontrol et
  static String getFileErrorMessage(dynamic error) {
    if (error is FileSystemException) {
      switch (error.osError?.errorCode) {
        case 2:
          return 'Dosya bulunamadı.';
        case 13:
          return 'Dosya erişim izni reddedildi.';
        case 28:
          return 'Depolama alanı yetersiz.';
        default:
          return 'Dosya işlemi başarısız: ${error.message}';
      }
    }
    return 'Dosya hatası oluştu.';
  }

  /// Resim işlem hatalarını kontrol et
  static String getImageErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('permission')) {
      return 'Kamera veya galeri erişim izni gerekli.';
    }
    if (errorStr.contains('size') || errorStr.contains('large')) {
      return 'Resim dosyası çok büyük. Lütfen daha küçük bir resim seçin.';
    }
    if (errorStr.contains('format') || errorStr.contains('invalid')) {
      return 'Desteklenmeyen resim formatı. JPG, PNG veya GIF kullanın.';
    }
    if (errorStr.contains('corrupt')) {
      return 'Resim dosyası bozuk. Lütfen başka bir resim seçin.';
    }

    return 'Resim işlemi başarısız. Lütfen tekrar deneyin.';
  }

  /// Genel hata mesajı al
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return getAuthErrorMessage(error);
    }
    if (error is FirebaseException) {
      return getFirestoreErrorMessage(error);
    }
    if (error is SocketException ||
        error is TimeoutException ||
        error is HttpException) {
      return getNetworkErrorMessage(error);
    }
    if (error is FileSystemException) {
      return getFileErrorMessage(error);
    }

    // Resim hatalarını kontrol et
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('image') ||
        errorStr.contains('camera') ||
        errorStr.contains('gallery')) {
      return getImageErrorMessage(error);
    }

    return error.toString();
  }

  /// Hata snackbar göster
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final message = getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  /// Başarı snackbar göster
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Uyarı snackbar göster
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Bilgi snackbar göster
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Retry mekanizması ile async işlem yürütücü
class RetryHandler {
  /// Retry ile async işlem yürüt
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;

        // Son deneme ise hatayı fırlat
        if (attempts >= maxRetries) {
          rethrow;
        }

        // Retry yapılıp yapılmayacağını kontrol et
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        // Network hatalarında retry yap
        if (error is SocketException ||
            error is TimeoutException ||
            (error is FirebaseException && _isRetryableFirebaseError(error))) {
          await Future.delayed(delay * attempts); // Exponential backoff
          continue;
        }

        // Diğer hatalar için retry yapma
        rethrow;
      }
    }

    throw Exception('Maximum retry attempts exceeded');
  }

  /// Firebase hatasının retry edilebilir olup olmadığını kontrol et
  static bool _isRetryableFirebaseError(FirebaseException error) {
    const retryableCodes = [
      'unavailable',
      'deadline-exceeded',
      'resource-exhausted',
      'aborted',
      'internal',
      'network-request-failed',
    ];

    return retryableCodes.contains(error.code);
  }
}

/// Loading state yönetimi için mixin
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Loading state'i güncelle
  void setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  /// Loading ile async işlem yürüt
  Future<R> executeWithLoading<R>(Future<R> Function() operation) async {
    setLoading(true);
    try {
      return await operation();
    } finally {
      setLoading(false);
    }
  }

  /// Retry ile loading async işlem yürüt
  Future<R> executeWithLoadingAndRetry<R>(
    Future<R> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    setLoading(true);
    try {
      return await RetryHandler.executeWithRetry(
        operation,
        maxRetries: maxRetries,
        delay: delay,
      );
    } finally {
      setLoading(false);
    }
  }
}
