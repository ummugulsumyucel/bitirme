import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'event_detail_screen.dart';
import 'new_event_screen.dart';

class EventsScreen extends StatefulWidget {
  final bool embeddedInShell;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const EventsScreen({
    super.key,
    this.embeddedInShell = false,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

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
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ) // Tema rengini kullan
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

  /// "15.4.2025" veya "15.04.2025" formatındaki string tarihi DateTime'a çevirir.
  /// Parse edilemezse null döner.
  DateTime? _parseEventDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    final parts = dateStr.trim().split('.');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  /// Etkinliğin tarihi bugünden önce mi?
  bool _isEventPast(Map<String, dynamic> data) {
    final dateStr = (data['date'] as String?)?.trim();
    final eventDate = _parseEventDate(dateStr);
    if (eventDate == null) return false;
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return eventDate.isBefore(todayOnly);
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
        // Etkinliğin gerçek tarihine göre filtrele
        final dateStr = (data['date'] as String?)?.trim();
        final eventDate = _parseEventDate(dateStr);
        if (eventDate == null) return false;
        final now = DateTime.now();
        final todayOnly = DateTime(now.year, now.month, now.day);
        final weekLater = todayOnly.add(const Duration(days: 7));
        if (eventDate.isBefore(todayOnly) || eventDate.isAfter(weekLater)) {
          return false;
        }
        break;
      case 'Bu ay':
        final dateStr2 = (data['date'] as String?)?.trim();
        final eventDate2 = _parseEventDate(dateStr2);
        if (eventDate2 == null) return false;
        final n = DateTime.now();
        if (eventDate2.year != n.year || eventDate2.month != n.month) {
          return false;
        }
        break;
    }

    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty && !combined.contains(q)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
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
    );

    if (widget.embeddedInShell) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface, // Tema rengini kullan
        child: SizedBox.expand(child: scroll),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface, // Tema rengini kullan
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary, // Tema rengini kullan
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: scroll,
    );
  }

  Widget _buildSearchFilters() {
    final scheme = Theme.of(context).colorScheme;
    final categoryLabel = _eventCategory == 'Tümü'
        ? 'Kategori Seç'
        : _eventCategory;
    final timeLabel = _timeFilter == 'Tümü' ? 'Zaman' : _timeFilter;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow, // Tema rengini kullan
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: scheme.surfaceContainer, // Tema rengini kullan
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: scheme.onSurfaceVariant,
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
                  color: scheme.surfaceContainer, // Tema rengini kullan
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: scheme.onSurfaceVariant,
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
                  style: TextStyle(fontSize: 12, color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Etkinlik Ara...',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ), // Tema rengini kullan
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: scheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ), // Tema rengini kullan
                    ),
                    filled: true,
                    fillColor: scheme.surfaceContainer, // Tema rengini kullan
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary, // Tema rengini kullan
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => setState(() {}),
                  child: const Text(
                    'Ara',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
    final auth = AuthService();

    // Sadece admin veya kulüp başkanı görebilir
    if (!auth.isLoggedIn || !auth.canAddEvent) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary, // Tema rengini kullan
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
            MaterialPageRoute(
              builder: (_) => NewEventScreen(
                onToggleTheme: widget.onToggleTheme,
                isDarkMode: widget.isDarkMode,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Etkinlikler yuklenirken bir hata olustu: ${snapshot.error}',
            style: TextStyle(color: scheme.error, fontSize: 13),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = [...(snapshot.data?.docs ?? [])];

        if (allDocs.isEmpty) {
          return _buildEmptyState(
            context: context,
            icon: Icons.event_outlined,
            title: 'Henüz etkinlik yok',
            subtitle: 'İlk etkinliği sen ekleyebilirsin.',
          );
        }

        final filtered = allDocs
            .where((d) => _matchesEventFilters(d.data()))
            .toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(
            context: context,
            icon: Icons.search_off_rounded,
            title: 'Sonuç bulunamadı',
            subtitle:
                'Bu filtrelere uygun etkinlik yok.\nFiltreleri veya aramayı değiştir.',
          );
        }

        // Yaklaşan ve geçmiş olarak ayır
        final upcoming = filtered
            .where((d) => !_isEventPast(d.data()))
            .toList();
        final past = filtered.where((d) => _isEventPast(d.data())).toList();

        // Yaklaşanları tarihe göre artan, geçmişleri azalan sırala
        upcoming.sort((a, b) {
          final da = _parseEventDate((a.data()['date'] as String?)?.trim());
          final db = _parseEventDate((b.data()['date'] as String?)?.trim());
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });
        past.sort((a, b) {
          final da = _parseEventDate((a.data()['date'] as String?)?.trim());
          final db = _parseEventDate((b.data()['date'] as String?)?.trim());
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da); // en yakın geçmiş önce
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Yaklaşan etkinlikler ──────────────────────────────────────
            if (upcoming.isNotEmpty) ...[
              ...List.generate(upcoming.length, (index) {
                final data = upcoming[index].data();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEventCardFromData(
                    context: context,
                    docId: upcoming[index].id,
                    data: data,
                    isPast: false,
                  ),
                );
              }),
            ],

            // ── Geçmiş etkinlikler ────────────────────────────────────────
            if (past.isNotEmpty) ...[
              if (upcoming.isNotEmpty) const SizedBox(height: 8),
              _buildSectionHeader(
                context,
                icon: Icons.history_rounded,
                label: 'Geçmiş Etkinlikler',
                count: past.length,
              ),
              const SizedBox(height: 12),
              ...List.generate(past.length, (index) {
                final data = past[index].data();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEventCardFromData(
                    context: context,
                    docId: past[index].id,
                    data: data,
                    isPast: true,
                  ),
                );
              }),
            ],

            // Sadece geçmiş varsa (yaklaşan yok) boş durum göster
            if (upcoming.isEmpty && past.isEmpty)
              _buildEmptyState(
                context: context,
                icon: Icons.event_outlined,
                title: 'Henüz etkinlik yok',
                subtitle: 'İlk etkinliği sen ekleyebilirsin.',
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventCardFromData({
    required BuildContext context,
    required String docId,
    required Map<String, dynamic> data,
    required bool isPast,
  }) {
    final title = (data['title'] as String?)?.trim();
    final place = (data['place'] as String?)?.trim();
    final date = (data['date'] as String?)?.trim();
    final time = (data['time'] as String?)?.trim();
    final label = (data['label'] as String?)?.trim() ?? '';
    final category = (data['category'] as String?)?.trim() ?? '';
    final imageUrl = (data['imageUrl'] as String?)?.trim();

    return _buildEventCard(
      context: context,
      eventId: docId,
      title: (title == null || title.isEmpty) ? 'Başlık yok' : title,
      date: (date == null || date.isEmpty) ? 'Tarih belirtilmedi' : date,
      place: (place == null || place.isEmpty) ? 'Konum belirtilmedi' : place,
      time: (time == null || time.isEmpty) ? '--:--' : time,
      label: label,
      labelColor: _labelColor(label),
      background: _backgroundForCategory(category),
      icon: _iconForCategory(category),
      imageUrl: imageUrl,
      isPast: isPast,
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
    String? imageUrl,
    bool isPast = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: isPast ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner — resim varsa göster, yoksa gradient + ikon
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Arka plan: resim veya gradient
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      _buildBannerImage(imageUrl)
                    else
                      Container(
                        decoration: BoxDecoration(gradient: background),
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(icon, size: 40, color: scheme.onSurface),
                        ),
                      ),
                    // Geçmiş etkinlik overlay
                    if (isPast)
                      Container(color: scheme.surface.withValues(alpha: 0.35)),
                    // Etiket
                    Positioned(
                      top: 12,
                      right: 12,
                      child: isPast
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.onSurface.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Geçti',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : label.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: labelColor.withValues(alpha: 0.12),
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
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: scheme.primary),
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
                              onToggleTheme: widget.onToggleTheme,
                              isDarkMode: widget.isDarkMode,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Detayları Gör',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner resmi — hem Firebase Storage URL hem base64 data URL destekler.
  Widget _buildBannerImage(String imageUrl) {
    if (imageUrl.startsWith('data:')) {
      try {
        final comma = imageUrl.indexOf(',');
        if (comma != -1) {
          final bytes = base64Decode(imageUrl.substring(comma + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFFF3F4F6)),
          );
        }
      } catch (_) {}
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) =>
            const ColoredBox(color: Color(0xFFF3F4F6)),
      );
    }
    return const ColoredBox(color: Color(0xFFF3F4F6));
  }
}
