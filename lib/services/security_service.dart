import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Güvenlik işlemleri servisi
class SecurityService {
  /// Şifreyi hash'le (SHA-256 + salt)
  static String hashPassword(String password) {
    try {
      // Random salt oluştur
      final salt = _generateSalt();

      // Password + salt kombinasyonu
      final combined = password + salt;

      // SHA-256 hash
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);

      // Salt + hash kombinasyonu döndür
      return '$salt:${digest.toString()}';
    } catch (e) {
      debugPrint('SecurityService.hashPassword error: $e');
      rethrow;
    }
  }

  /// Şifreyi doğrula
  static bool verifyPassword(String password, String hashedPassword) {
    try {
      // Hash'i parçala
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final hash = parts[1];

      // Girilen şifreyi aynı salt ile hash'le
      final combined = password + salt;
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);

      // Hash'leri karşılaştır
      return digest.toString() == hash;
    } catch (e) {
      debugPrint('SecurityService.verifyPassword error: $e');
      return false;
    }
  }

  /// Random salt oluştur
  static String _generateSalt({int length = 32}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();

    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Güvenli random string oluştur
  static String generateSecureToken({int length = 64}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();

    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// E-posta adresini maskele (güvenlik için)
  static String maskEmail(String email) {
    try {
      final parts = email.split('@');
      if (parts.length != 2) return email;

      final username = parts[0];
      final domain = parts[1];

      if (username.length <= 2) return email;

      final maskedUsername =
          username[0] +
          '*' * (username.length - 2) +
          username[username.length - 1];

      return '$maskedUsername@$domain';
    } catch (e) {
      debugPrint('SecurityService.maskEmail error: $e');
      return email;
    }
  }

  /// Telefon numarasını maskele
  static String maskPhone(String phone) {
    try {
      if (phone.length < 4) return phone;

      final visible = phone.substring(0, 3);
      final masked = '*' * (phone.length - 6);
      final ending = phone.substring(phone.length - 3);

      return '$visible$masked$ending';
    } catch (e) {
      debugPrint('SecurityService.maskPhone error: $e');
      return phone;
    }
  }

  /// Input sanitization (XSS koruması)
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .trim();
  }

  /// SQL Injection koruması için string escape
  static String escapeString(String input) {
    return input
        .replaceAll("'", "''")
        .replaceAll('"', '""')
        .replaceAll('\\', '\\\\');
  }
}
