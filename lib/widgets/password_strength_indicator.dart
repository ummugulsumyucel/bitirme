import 'package:flutter/material.dart';
import '../utils/validators.dart';

/// Şifre gücü göstergesi widget'ı
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showText;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strength = Validators.calculatePasswordStrength(password);
    final strengthText = Validators.getPasswordStrengthText(strength);
    final strengthColor = Validators.getPasswordStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: scheme.surfaceContainerLow,
                  valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  minHeight: 6,
                ),
              ),
            ),
            if (showText) ...[
              const SizedBox(width: 12),
              Text(
                strengthText,
                style: TextStyle(
                  fontSize: 12,
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),

        if (password.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildRequirements(scheme),
        ],
      ],
    );
  }

  Widget _buildRequirements(ColorScheme scheme) {
    final requirements = [
      RequirementItem('En az 8 karakter', password.length >= 8),
      RequirementItem('Büyük harf (A-Z)', RegExp(r'[A-Z]').hasMatch(password)),
      RequirementItem('Küçük harf (a-z)', RegExp(r'[a-z]').hasMatch(password)),
      RequirementItem('Rakam (0-9)', RegExp(r'[0-9]').hasMatch(password)),
      RequirementItem(
        'Özel karakter (!@#\$...)',
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: requirements.map((req) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              req.isValid ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 14,
              color: req.isValid ? Colors.green : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              req.text,
              style: TextStyle(
                fontSize: 11,
                color: req.isValid ? Colors.green : scheme.onSurfaceVariant,
                fontWeight: req.isValid ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Helper class for password requirements
class RequirementItem {
  final String text;
  final bool isValid;

  RequirementItem(this.text, this.isValid);
}
