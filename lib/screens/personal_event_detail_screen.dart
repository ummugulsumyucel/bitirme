import 'package:flutter/material.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';
import 'main_shell.dart';

class PersonalEventDetailScreen extends StatelessWidget {
  final String eventId;
  final String title;
  final String date;
  final String time;
  final String place;
  final String? description;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const PersonalEventDetailScreen({
    super.key,
    required this.eventId,
    required this.title,
    required this.date,
    required this.time,
    required this.place,
    this.description,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CommonAppBar(
        title: 'Etkinlik Detayı',
        onToggleTheme: onToggleTheme,
        isDarkMode: isDarkMode,
      ),
      drawer: CommonDrawer(
        onToggleTheme: onToggleTheme,
        isDarkMode: isDarkMode,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.event, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Detaylar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    label: 'Tarih',
                    value: date,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Konum',
                    value: place,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.access_time,
                    label: 'Saat',
                    value: time,
                  ),
                  if (description != null && description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Etkinlik Hakkında',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF333333),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
                      selected: false,
                      onTap: () {
                        if (i == 0) {
                          Navigator.pop(context);
                        } else if (i == 1) {
                          Navigator.pop(context);
                        } else if (i == 2) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
