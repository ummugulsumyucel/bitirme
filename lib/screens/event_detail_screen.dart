import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../navigation/shell_tab_sync.dart';
import '../services/session_service.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';
import 'main_shell.dart' show ShellNavItem;
import 'new_event_screen.dart' show NewEventScreen;

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final String title;
  final String date;
  final String place;
  final String time;
  final String? label;
  final Color? labelColor;
  final LinearGradient? background;
  final IconData? icon;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

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
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
  }

  /// Etkinliği sil (sadece sahibi yapabilir)
  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Etkinliği Sil'),
        content: const Text(
          'Bu etkinliği silmek istediğinizden emin misiniz? Tüm katılım kayıtları da silinecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etkinlik silindi.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CommonAppBar(
        title: 'Etkinlik Detayı',
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      drawer: CommonDrawer(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .snapshots(),
        builder: (context, snap) {
          final data = snap.data?.data() ?? {};
          final description = (data['description'] as String?)?.trim();
          final liveTitle = (data['title'] as String?)?.trim() ?? widget.title;
          final liveDate = (data['date'] as String?)?.trim() ?? widget.date;
          final livePlace = (data['place'] as String?)?.trim() ?? widget.place;
          final liveTime = (data['time'] as String?)?.trim() ?? widget.time;
          final liveLabel = (data['label'] as String?)?.trim() ?? widget.label ?? '';
          final createdBy = (data['createdBy'] as String?)?.trim() ?? '';

          // Mevcut kullanıcı bu etkinliğin sahibi mi?
          final isOwner = _currentUid != null &&
              createdBy.isNotEmpty &&
              _currentUid == createdBy;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero banner
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: widget.background ??
                        const LinearGradient(
                          colors: [Color(0xFFE0ECFF), Color(0xFFD0E4FF)],
                        ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          widget.icon ?? Icons.event,
                          size: 80,
                          color: const Color(0xFF111827).withValues(alpha: 0.25),
                        ),
                      ),
                      if (liveLabel.isNotEmpty)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (widget.labelColor ?? Colors.green)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              liveLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: widget.labelColor ?? Colors.green,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        liveTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(context, Icons.event, 'Tarih', liveDate),
                      const SizedBox(height: 10),
                      _buildInfoCard(context, Icons.place_outlined, 'Konum', livePlace),
                      const SizedBox(height: 10),
                      _buildInfoCard(context, Icons.access_time, 'Saat', liveTime),

                      const SizedBox(height: 24),

                      Text(
                        'Etkinlik Hakkında',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (description != null && description.isNotEmpty)
                            ? description
                            : 'Bu etkinlik kampüsümüzde düzenlenen özel bir organizasyondur. '
                                'Tüm öğrencilerimiz davetlidir.',
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildAttendeesCard(context),
                      const SizedBox(height: 24),

                      // ── Sahip: Düzenle + Sil ──────────────────────────────
                      if (isOwner) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Düzenle'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: scheme.primary,
                                  side: BorderSide(color: scheme.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NewEventScreen(
                                        onToggleTheme: widget.onToggleTheme,
                                        isDarkMode: widget.isDarkMode,
                                        editEventId: widget.eventId,
                                        initialData: data,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Sil'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _deleteEvent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Katılım butonu (herkes için) ──────────────────────
                      _JoinButton(
                        eventId: widget.eventId,
                        title: liveTitle,
                        place: livePlace,
                        time: liveTime,
                        date: liveDate,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData iconData,
    String label,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('event_attendees')
          .where('eventId', isEqualTo: widget.eventId)
          .snapshots(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.people_outline, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Katılımcılar',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snap.connectionState == ConnectionState.waiting
                          ? 'Yükleniyor...'
                          : '$count kişi katılıyor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
                          ShellTabSync.select(0);
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        } else if (i == 1) {
                          ShellTabSync.select(1);
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        } else if (i == 2) {
                          ShellTabSync.select(2);
                          Navigator.of(context).popUntil((r) => r.isFirst);
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
}

class _JoinButton extends StatefulWidget {
  final String eventId;
  final String title;
  final String place;
  final String time;
  final String date;

  const _JoinButton({
    required this.eventId,
    required this.title,
    required this.place,
    required this.time,
    required this.date,
  });

  @override
  State<_JoinButton> createState() => _JoinButtonState();
}

class _JoinButtonState extends State<_JoinButton> {
  bool _loading = false;
  bool _joined = false;

  @override
  void initState() {
    super.initState();
    _checkJoined();
  }

  Future<void> _checkJoined() async {
    final uid = await SessionService.ensureUserDocId();
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('event_attendees')
        .doc('${uid}_${widget.eventId}')
        .get();
    if (mounted) setState(() => _joined = doc.exists);
  }

  Future<void> _onTap() async {
    final uid = await SessionService.ensureUserDocId();
    if (!mounted) return;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Katılmak için giriş yapmalısınız.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final attendeeRef = FirebaseFirestore.instance
          .collection('event_attendees')
          .doc('${uid}_${widget.eventId}');

      // Kişisel takvim kaydı için sabit bir doc ID kullan
      final personalRef = FirebaseFirestore.instance
          .collection('personal_events')
          .doc('event_join_${uid}_${widget.eventId}');

      if (_joined) {
        // Katılımı iptal et — attendees + personal_events'ten sil
        await Future.wait([
          attendeeRef.delete(),
          personalRef.delete(),
        ]);
        if (mounted) setState(() => _joined = false);
      } else {
        // Katıl — attendees'e kaydet
        await attendeeRef.set({
          'userDocId': uid,
          'eventId': widget.eventId,
          'title': widget.title,
          'subtitle': '${widget.place} · ${widget.time}',
          'dateDisplay': widget.date,
          'joinedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Aynı zamanda kişisel takvime ekle
        // Kullanıcının e-postasını al (personal_events userId = email)
        final userEmail = FirebaseAuth.instance.currentUser?.email ?? uid;

        await personalRef.set({
          'userId': userEmail,
          'title': widget.title,
          'place': widget.place,
          'time': widget.time,
          'date': widget.date,
          'description': 'Kampüs etkinliği — katılım kaydedildi.',
          'eventId': widget.eventId, // kaynak etkinlik referansı
          'fromCampusEvent': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) setState(() => _joined = true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _joined
                  ? 'Etkinliğe katılım kaydedildi ve takviminize eklendi.'
                  : 'Katılım iptal edildi ve takvimden kaldırıldı.',
            ),
            backgroundColor: const Color(0xFF5A7FCF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _joined
              ? Colors.grey.shade400
              : const Color(0xFF5A7FCF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _loading ? null : _onTap,
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _joined ? 'Katılımı İptal Et' : 'Etkinliğe Katıl',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}
