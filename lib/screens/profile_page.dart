import 'package:flutter/material.dart';

import 'profile_screen.dart';

/// Tüm uygulama tek profil ekranı kullanır ([ProfileScreen]).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}

/// [AddNotePage] form çıktısı için basit model.
class Note {
  final String id;
  final String title;
  final String content;

  Note({required this.id, required this.title, required this.content});
}
