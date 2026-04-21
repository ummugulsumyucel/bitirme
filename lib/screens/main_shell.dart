import 'package:flutter/material.dart';

import '../navigation/shell_tab_sync.dart';
import '../services/auth_service.dart';
import '../theme/uni_theme.dart';
import 'announcements_page.dart';
import 'calendar_page.dart';
import 'events_screen.dart';
import 'food_menu_screen.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'notes_feed_screen.dart';
import 'profile_screen.dart';
import 'register_page.dart';
import 'suggestion_complaint_screen.dart';

/// Tek scaffold: AppBar + Drawer + alt gezinme; sekmeler IndexedStack ile durumu korur.
class MainShell extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const MainShell({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  late final void Function(int) _shellTabHandler;

  @override
  void initState() {
    super.initState();
    _shellTabHandler = (int i) {
      if (mounted) setState(() => _index = i);
    };
    ShellTabSync.register(_shellTabHandler);
  }

  @override
  void dispose() {
    ShellTabSync.unregister(_shellTabHandler);
    super.dispose();
  }

  static const List<String> _titles = [
    'Ana Sayfa',
    'Takvim',
    'Profilim',
    'Etkinlikler',
    'İlanlar',
    'Notlar',
    'Öneri / Şikayet',
    'Yemek Menüsü',
  ];

  bool get _isDark => widget.themeMode == ThemeMode.dark;

  void _goToTab(int i) {
    setState(() => _index = i);
  }

  void _openDrawer() {
    void open() => _scaffoldKey.currentState?.openDrawer();
    open();
    WidgetsBinding.instance.addPostFrameCallback((_) => open());
  }

  Future<void> _closeDrawerThenPush(
    BuildContext drawerContext,
    Widget page,
  ) async {
    Navigator.pop(drawerContext);
    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (context) => page),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: true,
      appBar: AppBar(
        title: Text(_titles[_index]),
        leading: IconButton(
          tooltip: 'Menü',
          icon: const Icon(Icons.menu_rounded),
          onPressed: _openDrawer,
        ),
        actions: [
          IconButton(
            tooltip: _isDark ? 'Açık tema' : 'Koyu tema',
            icon: Icon(
              _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(
            key: const PageStorageKey<String>('tab_home'),
            embeddedInShell: true,
            onToggleDarkMode: widget.onToggleTheme,
            isDarkMode: _isDark,
          ),
          CalendarPage(
            embeddedInShell: true,
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: _isDark,
          ),
          ProfileScreen(
            embeddedInShell: true,
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: _isDark,
          ),
          EventsScreen(
            embeddedInShell: true,
            onToggleTheme: widget.onToggleTheme,
            isDarkMode: _isDark,
          ),
          AnnouncementsPage(
            embeddedInShell: true,
            onToggleDarkMode: widget.onToggleTheme,
            isDarkMode: _isDark,
          ),
          const NotesFeedScreen(embeddedInShell: true),
          const SuggestionComplaintScreen(embeddedInShell: true),
          const FoodMenuScreen(embeddedInShell: true),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: scheme.onPrimary,
                        size: 36,
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
                selected: _index == 0,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Takvim'),
                selected: _index == 1,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profilim'),
                selected: _index == 2,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(2);
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Etkinlikler'),
                selected: _index == 3,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: const Text('İlanlar'),
                selected: _index == 4,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(4);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Notlar'),
                selected: _index == 5,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(5);
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Yemek Menüsü'),
                selected: _index == 7,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(7);
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Öneri / Şikayet'),
                selected: _index == 6,
                onTap: () {
                  Navigator.pop(drawerContext);
                  _goToTab(6);
                },
              ),
              const Divider(),
              if (!isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Giriş Yap'),
                  onTap: () =>
                      _closeDrawerThenPush(drawerContext, const LoginPage()),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Kayıt Ol'),
                  onTap: () =>
                      _closeDrawerThenPush(drawerContext, const RegisterPage()),
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Çıkış Yap'),
                  onTap: () async {
                    Navigator.pop(drawerContext);
                    await authService.logout();
                    if (mounted) setState(() {});
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
                leading: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
                title: Text(_isDark ? 'Açık mod' : 'Koyu mod'),
                onTap: () {
                  widget.onToggleTheme();
                  Navigator.pop(drawerContext);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    const destinations = <({IconData icon, IconData activeIcon, String label})>[
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Ana Sayfa'),
      (
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: 'Takvim',
      ),
      (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profilim'),
    ];

    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 0,
      color: scheme.surfaceContainer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: ShellNavItem(
                      icon: destinations[i].icon,
                      activeIcon: destinations[i].activeIcon,
                      label: destinations[i].label,
                      selected: _index == i,
                      onTap: () => setState(() => _index = i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Giriş veya kayıt sonrası kullanılır; [MainShell] ile aynı yapı, yerel tema durumu tutar.
class UniConnectRootShell extends StatefulWidget {
  const UniConnectRootShell({super.key});

  @override
  State<UniConnectRootShell> createState() => _UniConnectRootShellState();
}

class _UniConnectRootShellState extends State<UniConnectRootShell> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _themeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
    return Theme(
      data: uniTheme(brightness),
      child: MainShell(themeMode: _themeMode, onToggleTheme: _toggleTheme),
    );
  }
}

class ShellNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ShellNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primaryContainer.withValues(alpha: 0.65)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                height: 1.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
