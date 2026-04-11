import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';
import 'notes_feed_screen.dart';
import 'event_detail_screen.dart';
import 'new_event_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _eventCategory = 'Tümü';
  String _timeFilter = 'Tümü';
  final TextEditingController _searchController = TextEditingController();

  static const _eventCategories = <String>[
    'Tümü',
    'Seminer',
    'Atölye',
    'Konser',
    'Spor',
    'Sosyal',
    'Eğitim',
    'Diğer',
  ];

  static const _timeOptions = <String>[
    'Tümü',
    'Yakında',
    'Ücretsiz',
    'Bu hafta',
    'Bu ay',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFilterSheet({
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onPick,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ...options.map(
                (e) => ListTile(
                  title: Text(e),
                  trailing: e == current
                      ? const Icon(Icons.check, color: Color(0xFF1E3A8A))
                      : null,
                  onTap: () => Navigator.pop(ctx, e),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onPick(picked);
  }

  bool _matchesEventFilters(Map<String, dynamic> data) {
    final category = ((data['category'] as String?) ?? '').trim();
    if (_eventCategory != 'Tümü' && category != _eventCategory) {
      return false;
    }

    final label = ((data['label'] as String?) ?? '').toLowerCase();
    final title = ((data['title'] as String?) ?? '').toLowerCase();
    final place = ((data['place'] as String?) ?? '').toLowerCase();
    final desc = ((data['description'] as String?) ?? '').toLowerCase();
    final combined = '$title $place $desc $label';

    switch (_timeFilter) {
      case 'Yakında':
        if (!label.contains('yakın') && !label.contains('yakinda')) {
          return false;
        }
        break;
      case 'Ücretsiz':
        if (!label.contains('ücretsiz') && !label.contains('ucretsiz')) {
          return false;
        }
        break;
      case 'Bu hafta':
        final ts = data['createdAt'];
        if (ts is! Timestamp) return false;
        if (DateTime.now().difference(ts.toDate()).inDays > 7) return false;
        break;
      case 'Bu ay':
        final ts2 = data['createdAt'];
        if (ts2 is! Timestamp) return false;
        final d = ts2.toDate();
        final n = DateTime.now();
        if (d.year != n.year || d.month != n.month) return false;
        break;
    }

    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty && !combined.contains(q)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchFilters(),
                      const SizedBox(height: 16),
                      _buildAddEventButton(context),
                      const SizedBox(height: 16),
                      _buildEventsList(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader() {
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
                icon: const Icon(Icons.dark_mode_outlined, color: Colors.white),
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

  Widget _buildSearchFilters() {
    final categoryLabel =
        _eventCategory == 'Tümü' ? 'Kategori Seç' : _eventCategory;
    final timeLabel = _timeFilter == 'Tümü' ? 'Zaman' : _timeFilter;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _showFilterSheet(
                      title: 'Kategori',
                      options: _eventCategories,
                      current: _eventCategory,
                      onPick: (v) => setState(() => _eventCategory = v),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                categoryLabel,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Material(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _showFilterSheet(
                      title: 'Zaman / etiket',
                      options: _timeOptions,
                      current: _timeFilter,
                      onPick: (v) => setState(() => _timeFilter = v),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                timeLabel,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: Color(0xFF6B7280),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Etkinlik Ara...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A7FCF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => setState(() {}),
                  child: const Text(
                    'Ara',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddEventButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5A7FCF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.add_circle_outline, size: 20),
        label: const Text(
          'Yeni Etkinlik Ekle',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewEventScreen()),
          );
        },
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Etkinlikler yuklenirken bir hata olustu: ${snapshot.error}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = [...(snapshot.data?.docs ?? [])];
        allDocs.sort((a, b) {
          final aTs = a.data()['createdAt'];
          final bTs = b.data()['createdAt'];
          final aMs = aTs is Timestamp ? aTs.millisecondsSinceEpoch : 0;
          final bMs = bTs is Timestamp ? bTs.millisecondsSinceEpoch : 0;
          return bMs.compareTo(aMs);
        });

        if (allDocs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Henuz etkinlik yok. Ilk etkinligi sen ekleyebilirsin.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          );
        }

        final docs = allDocs
            .where((d) => _matchesEventFilters(d.data()))
            .toList();

        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Bu filtrelere uygun etkinlik yok. Filtreleri veya aramayı değiştir.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          );
        }

        return Column(
          children: List.generate(docs.length, (index) {
            final data = docs[index].data();
            final title = (data['title'] as String?)?.trim();
            final place = (data['place'] as String?)?.trim();
            final date = (data['date'] as String?)?.trim();
            final time = (data['time'] as String?)?.trim();
            final label = (data['label'] as String?)?.trim() ?? '';
            final category = (data['category'] as String?)?.trim() ?? '';

            return Padding(
              padding: EdgeInsets.only(bottom: index == docs.length - 1 ? 0 : 12),
              child: _buildEventCard(
                context: context,
                eventId: docs[index].id,
                title: (title == null || title.isEmpty) ? 'Baslik yok' : title,
                date: (date == null || date.isEmpty) ? 'Tarih belirtilmedi' : date,
                place: (place == null || place.isEmpty) ? 'Konum belirtilmedi' : place,
                time: (time == null || time.isEmpty) ? '--:--' : time,
                label: label,
                labelColor: _labelColor(label),
                background: _backgroundForCategory(category),
                icon: _iconForCategory(category),
              ),
            );
          }),
        );
      },
    );
  }

  Color _labelColor(String label) {
    switch (label) {
      case 'Ucretsiz':
      case 'Ücretsiz':
        return const Color(0xFF10B981);
      case 'Devam Ediyor':
        return const Color(0xFFF97316);
      case 'Yakinda':
      case 'Yakında':
        return const Color(0xFF0EA5E9);
      case 'Ucretli':
      case 'Ücretli':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Seminer':
        return Icons.mic_none_rounded;
      case 'Atolye':
      case 'Atölye':
        return Icons.science_outlined;
      case 'Konser':
        return Icons.music_note_outlined;
      case 'Spor':
        return Icons.sports_soccer_outlined;
      case 'Egitim':
      case 'Eğitim':
        return Icons.school_outlined;
      case 'Sosyal':
        return Icons.people_alt_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  LinearGradient _backgroundForCategory(String category) {
    switch (category) {
      case 'Seminer':
        return const LinearGradient(
          colors: [Color(0xFFE0ECFF), Color(0xFFE0ECFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Atolye':
      case 'Atölye':
        return const LinearGradient(
          colors: [Color(0xFFDCFCE7), Color(0xFFCCFBF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Konser':
        return const LinearGradient(
          colors: [Color(0xFFE9D5FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Spor':
        return const LinearGradient(
          colors: [Color(0xFFFFEDD5), Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildEventCard({
    required BuildContext context,
    required String eventId,
    required String title,
    required String date,
    required String place,
    required String time,
    required String label,
    required Color labelColor,
    required LinearGradient background,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 40, color: const Color(0xFF111827)),
                if (label.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: labelColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(
                            eventId: eventId,
                            title: title,
                            date: date,
                            place: place,
                            time: time,
                            label: label.isNotEmpty ? label : null,
                            labelColor: labelColor,
                            background: background,
                            icon: icon,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Detayları Gör',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
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
                onTap: () {},
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
                color: isActive
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFF666666),
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
              child: const Icon(
                Icons.person,
                color: Color(0xFF1E3A8A),
                size: 26,
              ),
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
