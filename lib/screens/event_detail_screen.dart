import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'notes_feed_screen.dart';
import 'events_screen.dart';

import '../services/session_service.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  final String title;
  final String date;
  final String place;
  final String time;
  final String? label;
  final Color? labelColor;
  final LinearGradient? background;
  final IconData? icon;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.title,
    required this.date,
    required this.place,
    required this.time,
    this.label,
    this.labelColor,
    this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image Section
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: background ??
                            const LinearGradient(
                              colors: [Color(0xFFE0ECFF), Color(0xFFE0ECFF)],
                            ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              icon ?? Icons.event,
                              size: 80,
                              color: const Color(0xFF111827).withOpacity(0.3),
                            ),
                          ),
                          if (label != null && label!.isNotEmpty)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (labelColor ?? Colors.green)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  label!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: labelColor ?? Colors.green,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Content Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Event Info Cards
                          _buildInfoCard(
                            icon: Icons.event,
                            label: 'Tarih',
                            value: date,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.place_outlined,
                            label: 'Konum',
                            value: place,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: Icons.access_time,
                            label: 'Saat',
                            value: time,
                          ),
                          const SizedBox(height: 24),
                          // Description Section
                          const Text(
                            'Etkinlik Hakkında',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Bu etkinlik kampüsümüzde düzenlenen özel bir organizasyondur. '
                            'Tüm öğrencilerimiz davetlidir. Etkinlik sırasında interaktif '
                            'oturumlar, sunumlar ve networking fırsatları sunulacaktır.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Participants Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF5A7FCF).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.people_outline,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Katılımcılar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '125 kişi katılıyor',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Join Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5A7FCF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                final uid =
                                    await SessionService.ensureUserDocId();
                                if (!context.mounted) return;
                                if (uid == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Önce Profilimden bilgilerini kaydet.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('event_attendees')
                                      .doc('${uid}_$eventId')
                                      .set(
                                    {
                                      'userDocId': uid,
                                      'eventId': eventId,
                                      'title': title,
                                      'subtitle': '$place · $time',
                                      'dateDisplay': date,
                                      'joinedAt': FieldValue.serverTimestamp(),
                                    },
                                    SetOptions(merge: true),
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Etkinliğe katılım kaydedildi.',
                                      ),
                                      backgroundColor: Color(0xFF5A7FCF),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Hata: $e')),
                                  );
                                }
                              },
                              child: const Text(
                                'Etkinliğe Katıl',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.school, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'UniConnect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.dark_mode_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5A7FCF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Ana Sayfa',
                isActive: false,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.calendar_today,
                label: 'Etkinlikler',
                isActive: true,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const EventsScreen()),
                  );
                },
              ),
              _buildNavItemWithPlus(
                label: 'Profilim',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.campaign,
                label: 'İlanlar',
                isActive: false,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.menu_book_outlined,
                label: 'Notlar',
                isActive: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotesFeedScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isActive ? 50 : 40,
              height: isActive ? 50 : 40,
              decoration: isActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5A7FCF).withOpacity(0.2),
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF1E3A8A) : const Color(0xFF666666),
                size: isActive ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFF666666),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithPlus({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5A7FCF).withOpacity(0.2),
              ),
              child: const Icon(Icons.person, color: Color(0xFF1E3A8A), size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

