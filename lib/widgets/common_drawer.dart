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
import '../screens/events_screen.dart';
import '../screens/food_menu_screen.dart';

class CommonDrawer extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const CommonDrawer({super.key, this.onToggleTheme, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Builder(
        builder: (drawerContext) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              // Modern gradient header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary,
                      Color.lerp(
                        scheme.primary,
                        const Color(0xFF0F1729),
                        0.35,
                      )!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/logo1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'UniConnect',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kampüs hayatı tek uygulamada',
                      style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: scheme.onPrimary.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authService.currentUserName ?? 'Kullanıcı',
                              style: TextStyle(
                                color: scheme.onPrimary.withValues(alpha: 0.95),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Text(
                  'MENÜ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),

              _tile(
                context: drawerContext,
                icon: Icons.home_outlined,
                label: 'Ana Sayfa',
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainShell(
                        themeMode: isDarkMode
                            ? ThemeMode.dark
                            : ThemeMode.light,
                        onToggleTheme: onToggleTheme ?? () {},
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
              _tile(
                context: drawerContext,
                icon: Icons.event_outlined,
                label: 'Etkinlikler',
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventsScreen(
                        embeddedInShell: false,
                        onToggleTheme: onToggleTheme,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  );
                },
              ),
              _tile(
                context: drawerContext,
                icon: Icons.calendar_month_outlined,
                label: 'Takvim',
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalendarPage(
                        embeddedInShell: false,
                        onToggleTheme: onToggleTheme,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  );
                },
              ),
              _tile(
                context: drawerContext,
                icon: Icons.person_outline,
                label: 'Profilim',
                onTap: () {
                  Navigator.pop(drawerContext);
                  if (!isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          embeddedInShell: false,
                          onToggleTheme: onToggleTheme,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    );
                  }
                },
              ),

              const Divider(height: 32),

              _tile(
                context: drawerContext,
                icon: Icons.campaign_outlined,
                label: 'İlanlar',
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnnouncementsPage(
                        onToggleDarkMode: onToggleTheme ?? () {},
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  );
                },
              ),
              _tile(
                context: drawerContext,
                icon: Icons.menu_book_outlined,
                label: 'Notlar',
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotesFeedScreen(embeddedInShell: false),
                    ),
                  );
                },
              ),
              _tile(
                context: drawerContext,
                icon: Icons.restaurant_menu,
                label: 'Yemek Menüsü',
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FoodMenuScreen(embeddedInShell: false),
                    ),
                  );
                },
              ),
              _tile(
                context: drawerContext,
                icon: Icons.feedback_outlined,
                label: 'Öneri / Şikayet',
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SuggestionComplaintScreen(
                        embeddedInShell: false,
                      ),
                    ),
                  );
                },
              ),

              const Divider(),

              if (!isLoggedIn) ...[
                _tile(
                  context: drawerContext,
                  icon: Icons.login,
                  label: 'Giriş Yap',
                  onTap: () {
                    Navigator.pop(drawerContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
                _tile(
                  context: drawerContext,
                  icon: Icons.person_add,
                  label: 'Kayıt Ol',
                  onTap: () {
                    Navigator.pop(drawerContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                ),
              ] else ...[
                _tile(
                  context: drawerContext,
                  icon: Icons.logout,
                  label: 'Çıkış Yap',
                  onTap: () async {
                    Navigator.pop(drawerContext);
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

              _tile(
                context: drawerContext,
                icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                label: isDarkMode ? 'Açık Mod' : 'Koyu Mod',
                onTap: () {
                  if (onToggleTheme != null) onToggleTheme!();
                  Navigator.pop(drawerContext);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.onSurfaceVariant),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
