import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/announcements_page.dart';
import '../screens/calendar_page.dart';
import '../screens/login_page.dart';
import '../screens/main_shell.dart';
import '../screens/notes_feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_page.dart';
import '../screens/suggestion_complaint_screen.dart';

class CommonDrawer extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const CommonDrawer({super.key, this.onToggleTheme, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'UniConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUserName ?? 'Kullanıcı',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainShell(
                    themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    onToggleTheme: onToggleTheme ?? () {},
                  ),
                ),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Etkinlikler'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainShell(
                    themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    onToggleTheme: onToggleTheme ?? () {},
                  ),
                ),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Takvim'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarPage(
                    embeddedInShell: false,
                    onToggleTheme: onToggleTheme,
                    isDarkMode: isDarkMode,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profilim'),
            onTap: () {
              Navigator.pop(context);
              if (!isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      embeddedInShell: false,
                      onToggleTheme: onToggleTheme,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('İlanlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementsPage(
                    onToggleDarkMode: onToggleTheme ?? () {},
                    isDarkMode: isDarkMode,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const NotesFeedScreen(embeddedInShell: false),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Şikayet / Öneri'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SuggestionComplaintScreen(),
                ),
              );
            },
          ),
          const Divider(),
          if (!isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Giriş Yap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Kayıt Ol'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                Navigator.pop(context);
                await authService.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Başarıyla çıkış yapıldı'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
            onTap: () {
              if (onToggleTheme != null) {
                onToggleTheme!();
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
