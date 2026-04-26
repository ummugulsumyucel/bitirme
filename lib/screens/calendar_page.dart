import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/auth_service.dart';
import '../services/klu_academic_calendar_service.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_drawer.dart';
import 'login_page.dart';
import 'personal_event_detail_screen.dart';

class CalendarPage extends StatefulWidget {
  final bool embeddedInShell;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const CalendarPage({
    super.key,
    this.embeddedInShell = false,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final authService = AuthService();
    if (!authService.isLoggedIn) return;

    final userId = authService.currentUserEmail;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('personal_events')
        .where('userId', isEqualTo: userId)
        .get();
    final Map<DateTime, List<Map<String, dynamic>>> events = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = data['date'] as String?;
      if (dateStr != null && dateStr.isNotEmpty) {
        try {
          final parts = dateStr.split('.');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final date = DateTime(year, month, day);
            final normalizedDate = DateTime(date.year, date.month, date.day);

            if (events[normalizedDate] == null) {
              events[normalizedDate] = [];
            }
            events[normalizedDate]!.add({
              'id': doc.id,
              'title': data['title'] ?? '',
              ...data,
            });
          }
        } catch (e) {
          // Tarih parse hatası
        }
      }
    }

    if (mounted) {
      setState(() {
        _events = events;
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final personal = _events[normalizedDay] ?? [];
    // Akademik etkinlikleri de marker olarak ekle
    final academic = KluAcademicCalendarService.eventsForDay(day);
    final academicMapped = academic
        .map((e) => {'title': e.title, 'isAcademic': true, 'type': e.type})
        .toList();
    return [...personal, ...academicMapped];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // ── Akademik takvim yardımcı metodları ─────────────────────────────────────

  Widget _buildAcademicLegend(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: scheme.surfaceContainerLow,
      child: Row(
        children: [
          _legendDot(const Color(0xFF1E3A8A), 'Kişisel'),
          const SizedBox(width: 12),
          _legendDot(const Color(0xFFEF4444), 'Sınav'),
          const SizedBox(width: 12),
          _legendDot(const Color(0xFF10B981), 'Tatil'),
          const SizedBox(width: 12),
          _legendDot(const Color(0xFF6366F1), 'Kayıt'),
          const SizedBox(width: 12),
          _legendDot(const Color(0xFFF97316), 'Dönem'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildAcademicEventsForDay(BuildContext context, DateTime day) {
    final events = KluAcademicCalendarService.eventsForDay(day);
    if (events.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Akademik Takvim — Bugün',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          ...events.map((e) {
            final color = KluAcademicCalendarService.colorForType(e.type);
            final label = KluAcademicCalendarService.labelForType(e.type);
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.title,
                      style: TextStyle(fontSize: 12, color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPersonalEventsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AuthService().isLoggedIn
          ? FirebaseFirestore.instance
                .collection('personal_events')
                .where('userId', isEqualTo: AuthService().currentUserEmail)
                .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Etkinlikler yüklenemedi: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
          final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });

        if (!AuthService().isLoggedIn) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Kişisel etkinliklerinizi görmek için giriş yapın.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
          );
        }

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Henüz etkinlik yok.\nTakvimde bir güne tıklayarak ekleyebilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final title = (d['title'] as String?)?.trim() ?? 'Etkinlik';
            final date = (d['date'] as String?)?.trim() ?? '—';
            final time = (d['time'] as String?)?.trim() ?? '—';
            final place = (d['place'] as String?)?.trim() ?? '—';
            final description = (d['description'] as String?)?.trim();
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.event, color: Color(0xFF1E3A8A)),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '$date · $time\n$place',
                  style: const TextStyle(fontSize: 12),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  final deleted = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute<bool>(
                      builder: (_) => PersonalEventDetailScreen(
                        eventId: docs[i].id,
                        title: title,
                        date: date,
                        place: place,
                        time: time,
                        description: description,
                        onToggleTheme: widget.onToggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                  if (deleted == true) _loadEvents();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFullAcademicCalendar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final events = KluAcademicCalendarService.events2025_2026;
    return Column(
      children: [
        // ── Resmi PDF butonu ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
          child: OutlinedButton.icon(
            icon: Icon(Icons.open_in_new, size: 16, color: scheme.primary),
            label: Text(
              'Resmi Akademik Takvimi Aç (PDF)',
              style: TextStyle(fontSize: 12, color: scheme.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: scheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => KluAcademicCalendarService.openOfficialCalendar(),
          ),
        ),
        const Divider(height: 1),
        // ── Etkinlik listesi ─────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = events[i];
              final color = KluAcademicCalendarService.colorForType(e.type);
              final label = KluAcademicCalendarService.labelForType(e.type);
              final dateStr = e.end == null
                  ? '${e.start.day}.${e.start.month}.${e.start.year}'
                  : '${e.start.day}.${e.start.month} – ${e.end!.day}.${e.end!.month}.${e.end!.year}';
              // Geçmiş etkinlikleri soluk göster
              final isPast = (e.end ?? e.start).isBefore(DateTime.now());
              return ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isPast ? 0.07 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: isPast ? 0.5 : 1.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                title: Text(
                  e.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurface.withValues(
                      alpha: isPast ? 0.45 : 1.0,
                    ),
                  ),
                ),
                subtitle: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant.withValues(
                      alpha: isPast ? 0.45 : 1.0,
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEventDialog(DateTime selectedDate) {
    final authService = AuthService();

    if (!authService.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Giriş Gerekli',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: const Text('Etkinlik eklemek için lütfen giriş yapın.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Giriş Yap'),
            ),
          ],
        ),
      );
      return;
    }

    _titleController.clear();
    _placeController.clear();
    _descriptionController.clear();
    _timeController.clear();

    // Seçili tarihi başlangıç değeri olarak ayarla
    String displayDate =
        '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}';
    DateTime pickedDate = selectedDate;

    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                      'Etkinlik Ekle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Etkinlik Adı
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Etkinlik Adı',
                    hintText: 'Örn: Proje Sunumu',
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
                  controller: _placeController,
                  decoration: const InputDecoration(
                    labelText: 'Yer',
                    hintText: 'Örn: Amfi A',
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
                      context: context,
                      initialDate: pickedDate,
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
                  controller: _timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Saat',
                    hintText: '--:--',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setSheet(() {
                        _timeController.text =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Açıklama
                TextField(
                  controller: _descriptionController,
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
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _saveEvent(pickedDate),
                        child: const Text(
                          'Ekle',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
  }

  Future<void> _saveEvent(DateTime selectedDate) async {
    final title = _titleController.text.trim();
    final place = _placeController.text.trim();
    final description = _descriptionController.text.trim();
    final time = _timeController.text.trim();

    if (title.isEmpty || place.isEmpty || time.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen zorunlu alanları doldurun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authService = AuthService();
    final userId = authService.currentUserEmail;
    if (userId == null) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseFirestore.instance.collection('personal_events').add({
        'userId': userId,
        'title': title,
        'place': place,
        'description': description,
        'date':
            '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
        'time': time,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Etkinlik başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadEvents(); // Etkinlikleri yeniden yükle
    } catch (e) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = Column(
      children: [
        // ── Kompakt takvim (haftalık başlar, aya geçilebilir) ───────────────
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          startingDayOfWeek: StartingDayOfWeek.monday,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Hafta',
            CalendarFormat.twoWeeks: 'Ay',
            CalendarFormat.week: '2 Hafta',
          },
          locale: 'tr_TR',
          eventLoader: _getEventsForDay,
          daysOfWeekHeight: 20,
          rowHeight: 38,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              final hasAcademic = events.any(
                (e) => (e as Map<String, dynamic>)['isAcademic'] == true,
              );
              final hasPersonal = events.any(
                (e) => (e as Map<String, dynamic>)['isAcademic'] != true,
              );
              return Positioned(
                bottom: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasPersonal)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E3A8A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (hasAcademic)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showAddEventDialog(selectedDay);
          },
          onPageChanged: (focusedDay) =>
              setState(() => _focusedDay = focusedDay),
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(2),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF1E3A8A),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(fontSize: 13, color: scheme.onSurface),
            weekendTextStyle: TextStyle(
              fontSize: 13,
              color: scheme.error.withValues(alpha: 0.7),
            ),
            outsideTextStyle: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            headerPadding: const EdgeInsets.symmetric(vertical: 4),
            titleTextStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            formatButtonTextStyle: TextStyle(
              fontSize: 11,
              color: scheme.primary,
            ),
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: scheme.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: scheme.onSurface,
              size: 20,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: scheme.onSurface,
              size: 20,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
            weekendStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.error.withValues(alpha: 0.7),
            ),
          ),
        ),
        // ── Renk göstergesi ─────────────────────────────────────────────────
        _buildAcademicLegend(context),
        // ── Seçili gün akademik etkinlikleri ────────────────────────────────
        _buildAcademicEventsForDay(context, _selectedDay),
        // ── Tab bar + içerik ────────────────────────────────────────────────
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  tabs: const [
                    Tab(text: 'Etkinliklerim'),
                    Tab(text: 'Akademik Takvim'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPersonalEventsList(context),
                      _buildFullAcademicCalendar(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.embeddedInShell) {
      return ColoredBox(
        color: scheme.surface,
        child: SizedBox.expand(child: body),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Takvim',
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      drawer: CommonDrawer(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      body: body,
    );
  }
}
