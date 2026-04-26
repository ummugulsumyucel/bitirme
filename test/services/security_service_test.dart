import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme/services/security_service.dart';

void main() {
  group('SecurityService Tests', () {
    test('should hash password correctly', () {
      const password = 'testPassword123!';

      final hashedPassword = SecurityService.hashPassword(password);

      expect(hashedPassword, isNotEmpty);
      expect(hashedPassword.contains(':'), isTrue);
      expect(hashedPassword.split(':').length, equals(2));
    });

    test('should verify password correctly', () {
      const password = 'testPassword123!';

      final hashedPassword = SecurityService.hashPassword(password);
      final isValid = SecurityService.verifyPassword(password, hashedPassword);

      expect(isValid, isTrue);
    });

    test('should reject wrong password', () {
      const password = 'testPassword123!';
      const wrongPassword = 'wrongPassword456!';

      final hashedPassword = SecurityService.hashPassword(password);
      final isValid = SecurityService.verifyPassword(
        wrongPassword,
        hashedPassword,
      );

      expect(isValid, isFalse);
    });

    test('should generate secure token', () {
      final token1 = SecurityService.generateSecureToken();
      final token2 = SecurityService.generateSecureToken();

      expect(token1, isNotEmpty);
      expect(token2, isNotEmpty);
      expect(token1, isNot(equals(token2)));
      expect(token1.length, equals(64));
    });

    test('should mask email correctly', () {
      const email = 'test@example.com';
      final maskedEmail = SecurityService.maskEmail(email);

      expect(maskedEmail, equals('t**t@example.com'));
    });

    test('should mask phone correctly', () {
      const phone = '5551234567';
      final maskedPhone = SecurityService.maskPhone(phone);

      expect(maskedPhone, equals('555****567'));
    });

    test('should sanitize input correctly', () {
      const input = '<script>alert("xss")</script>';
      final sanitized = SecurityService.sanitizeInput(input);

      expect(
        sanitized,
        equals('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'),
      );
    });

    test('should escape string correctly', () {
      const input = "It's a 'test' string";
      final escaped = SecurityService.escapeString(input);

      expect(escaped, equals("It''s a ''test'' string"));
    });
  });
}
