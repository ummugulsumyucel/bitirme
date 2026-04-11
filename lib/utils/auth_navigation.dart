import 'package:flutter/material.dart';

import '../screens/main_shell.dart';

/// Giriş/kayıt sonrası: üstte rota varsa geri dön, yoksa ana kabuğu tek kök olarak aç.
void finishLoginOrRegisterFlow(BuildContext context) {
  if (!context.mounted) return;
  if (Navigator.canPop(context)) {
    Navigator.pop(context, true);
  } else {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const UniConnectRootShell()),
      (_) => false,
    );
  }
}
