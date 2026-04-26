import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitirme/widgets/password_strength_indicator.dart';

void main() {
  group('PasswordStrengthIndicator Widget Tests', () {
    testWidgets('should display progress indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'TestPass123!'),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display strength text when enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(
              password: 'TestPass123!',
              showText: true,
            ),
          ),
        ),
      );

      expect(find.text('Çok Güçlü'), findsOneWidget);
    });

    testWidgets('should not display strength text when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(
              password: 'TestPass123!',
              showText: false,
            ),
          ),
        ),
      );

      expect(find.text('Çok Güçlü'), findsNothing);
    });

    testWidgets('should display requirements for non-empty password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'TestPass123!'),
          ),
        ),
      );

      expect(find.text('En az 8 karakter'), findsOneWidget);
      expect(find.text('Büyük harf (A-Z)'), findsOneWidget);
      expect(find.text('Küçük harf (a-z)'), findsOneWidget);
      expect(find.text('Rakam (0-9)'), findsOneWidget);
      expect(find.text('Özel karakter (!@#\$...)'), findsOneWidget);
    });

    testWidgets('should not display requirements for empty password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PasswordStrengthIndicator(password: '')),
        ),
      );

      expect(find.text('En az 8 karakter'), findsNothing);
    });

    testWidgets('should show check icons for met requirements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordStrengthIndicator(password: 'TestPass123!'),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('should show unchecked icons for unmet requirements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PasswordStrengthIndicator(password: 'weak')),
        ),
      );

      expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);
    });
  });
}
