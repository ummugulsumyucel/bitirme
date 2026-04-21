import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/auth_service.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.month;

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
    return _events[normalizedDay] ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _showAddEventDialog(DateTime selectedDate) {
    final authService = AuthService();

    if (!authService.isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Giriş Gerekli',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          content: const Text(
            'Etkinlik eklemek için lütfen giriş yapın.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Etkinlik Ekle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Etkinlik Adı',
                      hintText: 'Örn: Proje Sunumu',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _placeController,
                    decoration: const InputDecoration(
                      labelText: 'Yer',
                      hintText: 'Örn: Amfi A',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _timeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Saat',
                      hintText: '--:--',
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          _timeController.text =
                              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _saveEvent(selectedDate),
                          child: const Text('Ekle'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
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
    final body = Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          startingDayOfWeek: StartingDayOfWeek.monday,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          locale: 'tr_TR',
          eventLoader: _getEventsForDay,
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              final eventData = events.first as Map<String, dynamic>;
              final title = eventData['title'] as String? ?? '';
              if (title.isEmpty) return null;

              return Positioned(
                bottom: 1,
                child: Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    title.length > 8 ? '${title.substring(0, 8)}...' : title,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          onFormatChanged: (format) {
            setState(() => _calendarFormat = format);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showAddEventDialog(selectedDay);
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xFF1E3A8A),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFF3B82F6),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: AuthService().isLoggedIn
                ? FirebaseFirestore.instance
                      .collection('personal_events')
                      .where(
                        'userId',
                        isEqualTo: AuthService().currentUserEmail,
                      )
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
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
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

              if (docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Henüz etkinlik yok. Etkinlikler sekmesinden ekleyebilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i].data();
                  final title = (d['title'] as String?)?.trim() ?? 'Etkinlik';
                  final date = (d['date'] as String?)?.trim() ?? '—';
                  final time = (d['time'] as String?)?.trim() ?? '—';
                  final place = (d['place'] as String?)?.trim() ?? '—';
                  final description = (d['description'] as String?)?.trim();
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.event,
                        color: Color(0xFF1E3A8A),
                      ),
                      title: Text(title),
                      subtitle: Text('$date · $time\n$place'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
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
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    if (widget.embeddedInShell) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
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
