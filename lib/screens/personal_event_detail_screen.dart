import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';
import 'main_shell.dart';

class PersonalEventDetailScreen extends StatefulWidget {
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
  State<PersonalEventDetailScreen> createState() =>
      _PersonalEventDetailScreenState();
}

class _PersonalEventDetailScreenState
    extends State<PersonalEventDetailScreen> {
  late String _title;
  late String _date;
  late String _time;
  late String _place;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _date = widget.date;
    _time = widget.time;
    _place = widget.place;
    _description = widget.description ?? '';
  }

  // ── Silme ──────────────────────────────────────────────────────────────────
  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Etkinliği Sil'),
        content: const Text(
          'Bu etkinliği silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
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
      final db = FirebaseFirestore.instance;

      // Kişisel takvim kaydını al — kampüs etkinliğinden mi geldi?
      final personalDoc =
          await db.collection('personal_events').doc(widget.eventId).get();
      final data = personalDoc.data();
      final fromCampusEvent = data?['fromCampusEvent'] == true;
      final sourceEventId = data?['eventId'] as String?;

      // Her durumda personal_events'ten sil
      await db.collection('personal_events').doc(widget.eventId).delete();

      // Kampüs etkinliğinden geldiyse event_attendees'ten de sil
      if (fromCampusEvent && sourceEventId != null) {
        // uid bulmak için Auth'u kullan
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await db
              .collection('event_attendees')
              .doc('${uid}_$sourceEventId')
              .delete();
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fromCampusEvent
                ? 'Etkinlik takvimden ve katıldığım etkinliklerden silindi.'
                : 'Etkinlik silindi.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  // ── Düzenleme ──────────────────────────────────────────────────────────────
  Future<void> _editEvent() async {
    final titleCtrl = TextEditingController(text: _title);
    final placeCtrl = TextEditingController(text: _place);
    final timeCtrl = TextEditingController(text: _time);
    final descCtrl = TextEditingController(text: _description);
    final scheme = Theme.of(context).colorScheme;

    // Tarih parse
    DateTime? pickedDate;
    try {
      final parts = _date.split('.');
      if (parts.length == 3) {
        pickedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    pickedDate ??= DateTime.now();

    String displayDate = _date;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık satırı
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Etkinliği Düzenle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Etkinlik Adı
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Etkinlik Adı',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Yer
                TextField(
                  controller: placeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Yer',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tarih seçici
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: pickedDate!,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      pickedDate = picked;
                      setSheet(() {
                        displayDate =
                            '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tarih',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      displayDate,
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Saat seçici
                TextField(
                  controller: timeCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Saat',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onTap: () async {
                    final parts = timeCtrl.text.split(':');
                    final initial = parts.length == 2
                        ? TimeOfDay(
                            hour: int.tryParse(parts[0]) ?? 0,
                            minute: int.tryParse(parts[1]) ?? 0,
                          )
                        : TimeOfDay.now();
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: initial,
                    );
                    if (picked != null) {
                      setSheet(() {
                        timeCtrl.text =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Açıklama
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (opsiyonel)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final newTitle = titleCtrl.text.trim();
                          final newPlace = placeCtrl.text.trim();
                          final newTime = timeCtrl.text.trim();
                          final newDesc = descCtrl.text.trim();

                          if (newTitle.isEmpty ||
                              newPlace.isEmpty ||
                              newTime.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lütfen zorunlu alanları doldurun.',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection('personal_events')
                                .doc(widget.eventId)
                                .update({
                              'title': newTitle,
                              'place': newPlace,
                              'date': displayDate,
                              'time': newTime,
                              'description': newDesc,
                              'updatedAt': FieldValue.serverTimestamp(),
                            });

                            if (!mounted) return;
                            setState(() {
                              _title = newTitle;
                              _place = newPlace;
                              _date = displayDate;
                              _time = newTime;
                              _description = newDesc;
                            });

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Etkinlik güncellendi.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Hata: $e')),
                            );
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    titleCtrl.dispose();
    placeCtrl.dispose();
    timeCtrl.dispose();
    descCtrl.dispose();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: CommonAppBar(
        title: 'Etkinlik Detayı',
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
        actions: [
          // AppBar ikonları: kampüs etkinliğinde sadece sil, kişiselde düzenle+sil
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('personal_events')
                .doc(widget.eventId)
                .get(),
            builder: (context, snap) {
              final fromCampus = snap.data?.data()?['fromCampusEvent'] == true;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!fromCampus)
                    IconButton(
                      tooltip: 'Düzenle',
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: _editEvent,
                    ),
                  IconButton(
                    tooltip: fromCampus ? 'Katılımı İptal Et' : 'Sil',
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _deleteEvent,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: CommonDrawer(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
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
                    _title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

                  // Detay kartları
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('personal_events')
                          .doc(widget.eventId)
                          .snapshots(),
                      builder: (context, snap) {
                        final fromCampusEvent =
                            snap.data?.data()?['fromCampusEvent'] == true;

                        return Column(
                          children: [
                            _buildInfoCard(
                              icon: Icons.calendar_today,
                              label: 'Tarih',
                              value: _date,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              label: 'Konum',
                              value: _place,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              icon: Icons.access_time,
                              label: 'Saat',
                              value: _time,
                            ),
                            if (_description.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.shadow.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Etkinlik Hakkında',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: scheme.onSurface,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Alt butonlar
                            if (fromCampusEvent)
                              // Kampüs etkinliği → sadece Sil (katılımı iptal et)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.cancel_outlined),
                                  label: const Text('Katılımı İptal Et ve Sil'),
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
                              )
                            else
                              // Kişisel etkinlik → Düzenle + Sil
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
                                      onPressed: _editEvent,
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
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                      selected: false,
                      onTap: () => Navigator.pop(context),
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
