import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Email Validation', () {
      test('should accept valid email', () {
        const email = 'test@example.com';
        final result = Validators.validateEmail(email);
        expect(result, isNull);
      });

      test('should reject empty email', () {
        final result = Validators.validateEmail('');
        expect(result, isNotNull);
      });

      test('should reject invalid email format', () {
        final result = Validators.validateEmail('invalid-email');
        expect(result, isNotNull);
      });

      test('should require KLU domain when specified', () {
        const email = 'test@example.com';
        final result = Validators.validateEmail(email, requireKluDomain: true);
        expect(result, isNotNull);
      });

      test('should accept KLU domain when required', () {
        const email = 'test@klu.edu.tr';
        final result = Validators.validateEmail(email, requireKluDomain: true);
        expect(result, isNull);
      });
    });

    group('Password Validation', () {
      test('should accept strong password', () {
        const password = 'StrongPass123!';
        final result = Validators.validatePassword(password);
        expect(result, isNull);
      });

      test('should reject empty password', () {
        final result = Validators.validatePassword('');
        expect(result, isNotNull);
      });

      test('should reject short password', () {
        final result = Validators.validatePassword('Short1!');
        expect(result, isNotNull);
      });

      test('should reject password without uppercase', () {
        final result = Validators.validatePassword('lowercase123!');
        expect(result, isNotNull);
      });

      test('should reject password without lowercase', () {
        final result = Validators.validatePassword('UPPERCASE123!');
        expect(result, isNotNull);
      });

      test('should reject password without numbers', () {
        final result = Validators.validatePassword('NoNumbers!');
        expect(result, isNotNull);
      });

      test('should reject password without special characters', () {
        final result = Validators.validatePassword('NoSpecial123');
        expect(result, isNotNull);
      });
    });

    group('Password Match Validation', () {
      test('should accept matching passwords', () {
        const password = 'StrongPass123!';
        final result = Validators.validatePasswordMatch(password, password);
        expect(result, isNull);
      });

      test('should reject non-matching passwords', () {
        const password1 = 'StrongPass123!';
        const password2 = 'DifferentPass456!';
        final result = Validators.validatePasswordMatch(password2, password1);
        expect(result, isNotNull);
      });

      test('should reject empty confirmation', () {
        const password = 'StrongPass123!';
        final result = Validators.validatePasswordMatch('', password);
        expect(result, isNotNull);
      });
    });

    group('Phone Validation', () {
      test('should accept valid Turkish mobile number', () {
        const phone = '5551234567';
        final result = Validators.validatePhone(phone);
        expect(result, isNull);
      });

      test('should reject empty phone', () {
        final result = Validators.validatePhone('');
        expect(result, isNotNull);
      });

      test('should reject short phone number', () {
        final result = Validators.validatePhone('555123');
        expect(result, isNotNull);
      });

      test('should reject phone not starting with 5', () {
        final result = Validators.validatePhone('4551234567');
        expect(result, isNotNull);
      });

      test('should accept formatted phone number', () {
        const phone = '555 123 45 67';
        final result = Validators.validatePhone(phone);
        expect(result, isNull);
      });
    });

    group('Name Validation', () {
      test('should accept valid full name', () {
        const name = 'Ahmet Yılmaz';
        final result = Validators.validateName(name);
        expect(result, isNull);
      });

      test('should reject empty name', () {
        final result = Validators.validateName('');
        expect(result, isNotNull);
      });

      test('should reject single name', () {
        final result = Validators.validateName('Ahmet');
        expect(result, isNotNull);
      });

      test('should reject short name', () {
        final result = Validators.validateName('A B');
        expect(result, isNotNull);
      });

      test('should accept Turkish characters', () {
        const name = 'Ömer Çağlar Şahin';
        final result = Validators.validateName(name);
        expect(result, isNull);
      });
    });

    group('Password Strength Calculation', () {
      test('should return 0 for empty password', () {
        final strength = Validators.calculatePasswordStrength('');
        expect(strength, equals(0.0));
      });

      test('should return low strength for weak password', () {
        final strength = Validators.calculatePasswordStrength('weak');
        expect(strength, lessThan(0.5));
      });

      test('should return high strength for strong password', () {
        final strength = Validators.calculatePasswordStrength('StrongPass123!');
        expect(strength, greaterThan(0.8));
      });

      test('should return maximum strength for very strong password', () {
        final strength = Validators.calculatePasswordStrength(
          'VeryStrongPassword123!@#',
        );
        expect(strength, equals(1.0));
      });
    });

    group('Password Strength Text', () {
      test('should return correct text for different strengths', () {
        expect(Validators.getPasswordStrengthText(0.1), equals('Çok Zayıf'));
        expect(Validators.getPasswordStrengthText(0.4), equals('Zayıf'));
        expect(Validators.getPasswordStrengthText(0.6), equals('Orta'));
        expect(Validators.getPasswordStrengthText(0.8), equals('İyi'));
        expect(Validators.getPasswordStrengthText(1.0), equals('Çok Güçlü'));
      });
    });
  });
}
