import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/announcements_page.dart';
import '../screens/calendar_page.dart';
import '../screens/events_screen.dart';
import '../screens/login_page.dart';
import '../screens/profile_screen.dart';
import '../screens/register_page.dart';

class CommonDrawer extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;
  final String? selectedPage; // Hangi sayfa seçili olacak

  const CommonDrawer({
    super.key,
    this.onToggleTheme,
    this.isDarkMode = false,
    this.selectedPage,
  });

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
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.school_rounded,
                            color: scheme.primary,
                            size: 36,
                          );
                        },
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
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Ana Sayfa'),
                selected: selectedPage == 'home',
                onTap: () => _navigateToHome(drawerContext),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Takvim'),
                selected: selectedPage == 'calendar',
                onTap: () => _navigateToCalendar(drawerContext),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profilim'),
                selected: selectedPage == 'profile',
                onTap: () => _navigateToProfile(drawerContext, isLoggedIn),
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Etkinlikler'),
                selected: selectedPage == 'events',
                onTap: () => _navigateToEvents(drawerContext),
              ),
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: const Text('İlanlar'),
                selected: selectedPage == 'announcements',
                onTap: () => _navigateToAnnouncements(drawerContext),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Notlar'),
                selected: selectedPage == 'notes',
                onTap: () => _navigateToNotes(drawerContext),
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Yemek Menüsü'),
                selected: selectedPage == 'food',
                onTap: () => _navigateToHome(drawerContext),
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Öneri / Şikayet'),
                selected: selectedPage == 'feedback',
                onTap: () => _navigateToHome(drawerContext),
              ),
              const Divider(),
              if (!isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Giriş Yap'),
                  onTap: () => _navigateToLogin(drawerContext),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Kayıt Ol'),
                  onTap: () => _navigateToRegister(drawerContext),
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Çıkış Yap'),
                  onTap: () => _logout(drawerContext, authService),
                ),
              ],
              const Divider(),
              ListTile(
                leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                title: Text(isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
                onTap: () {
                  onToggleTheme?.call();
                  Navigator.pop(drawerContext);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToHome(BuildContext drawerContext) {
    Navigator.pop(drawerContext);
    // Ana sayfaya git - context'e göre farklı navigation yapılabilir
    Navigator.popUntil(drawerContext, (route) => route.isFirst);
  }

  void _navigateToCalendar(BuildContext drawerContext) {
    Navigator.pop(drawerContext);
    Navigator.pushReplacement(
      drawerContext,
      MaterialPageRoute(builder: (context) => const CalendarPage()),
    );
  }

  void _navigateToProfile(BuildContext drawerContext, bool isLoggedIn) {
    Navigator.pop(drawerContext);
    if (!isLoggedIn) {
      Navigator.pushReplacement(
        drawerContext,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      Navigator.pushReplacement(
        drawerContext,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            embeddedInShell: false,
            onToggleTheme: onToggleTheme,
            isDarkMode: isDarkMode,
          ),
        ),
      );
    }
  }

  void _navigateToEvents(BuildContext drawerContext) {
    Navigator.pop(drawerContext);
    Navigator.pushReplacement(
      drawerContext,
      MaterialPageRoute(
        builder: (context) => EventsScreen(
          embeddedInShell: false,
          onToggleTheme: onToggleTheme,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _navigateToAnnouncements(BuildContext drawerContext) {
    Navigator.pop(drawerContext);
    Navigator.pushReplacement(
      drawerContext,
      MaterialPageRoute(
        builder: (context) => AnnouncementsPage(
          onToggleDarkMode: onToggleTheme ?? () {},
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  void _navigateToNotes(BuildContext drawerContext) {
    Navigator.pop(drawerContext);
    // Notlar sayfasına git - genellikle ana sayfaya dönüp notlar sekmesine geçer
    Navigator.popUntil(drawerContext, (route) => route.isFirst);
  }

  void _navigateToLogin(BuildContext drawerContext) {
    Navigator.pop(drawerContext);
    Navigator.pushReplacement(
      drawerContext,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToRegister(BuildContext drawerContext) {
    Navigator.pop(drawerContext);
    Navigator.pushReplacement(
      drawerContext,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> _logout(
    BuildContext drawerContext,
    AuthService authService,
  ) async {
    Navigator.pop(drawerContext);
    await authService.logout();
    if (drawerContext.mounted) {
      ScaffoldMessenger.of(drawerContext).showSnackBar(
        const SnackBar(
          content: Text('Başarıyla çıkış yapıldı'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
