import 'package:flutter/material.dart';

/// Form validasyon yardımcı sınıfı
class Validators {
  /// E-posta validasyonu - KLU domain kontrolü ile
  static String? validateEmail(String? value, {bool requireKluDomain = false}) {
    if (value == null || value.isEmpty) {
      return 'Lütfen e-posta adresinizi girin';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }

    if (requireKluDomain && !value.toLowerCase().endsWith('@klu.edu.tr')) {
      return 'Lütfen KLU e-posta adresinizi kullanın (@klu.edu.tr)';
    }

    return null;
  }

  /// Şifre validasyonu - güçlü şifre kontrolü
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi girin';
    }

    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'En az 1 büyük harf içermelidir';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'En az 1 küçük harf içermelidir';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'En az 1 rakam içermelidir';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'En az 1 özel karakter içermelidir';
    }

    return null;
  }

  /// Şifre eşleşme kontrolü
  static String? validatePasswordMatch(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi tekrar girin';
    }

    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }

    return null;
  }

  /// Telefon numarası validasyonu (Türkiye) - isteğe bağlı
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // İsteğe bağlı alan
    }

    // Sadece rakamları al
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.length != 10) {
      return 'Telefon numarası 10 haneli olmalıdır';
    }

    if (!cleaned.startsWith('5')) {
      return 'Cep telefonu numarası 5 ile başlamalıdır';
    }

    return null;
  }

  /// Ad soyad validasyonu
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen adınızı ve soyadınızı girin';
    }

    if (value.trim().split(' ').length < 2) {
      return 'Lütfen ad ve soyadınızı girin';
    }

    if (value.length < 3) {
      return 'Ad soyad en az 3 karakter olmalıdır';
    }

    if (!RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$').hasMatch(value)) {
      return 'Ad soyad sadece harf içermelidir';
    }

    return null;
  }

  /// Şifre gücü hesaplama (0.0 - 1.0)
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Uzunluk kontrolü
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (password.length >= 16) strength += 0.1;

    // Karakter çeşitliliği
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }

  /// Şifre gücü metni
  static String getPasswordStrengthText(double strength) {
    if (strength < 0.3) return 'Çok Zayıf';
    if (strength < 0.5) return 'Zayıf';
    if (strength < 0.7) return 'Orta';
    if (strength < 0.9) return 'İyi';
    return 'Çok Güçlü';
  }

  /// Şifre gücü rengi
  static Color getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return const Color(0xFFEF4444); // Red
    if (strength < 0.5) return const Color(0xFFF97316); // Orange
    if (strength < 0.7) return const Color(0xFFFBBF24); // Yellow
    if (strength < 0.9) return const Color(0xFF10B981); // Green
    return const Color(0xFF059669); // Dark Green
  }
}
