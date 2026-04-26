import 'package:flutter/material.dart';

import '../services/event_reminder_service.dart';

class EventReminderDialog extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final DateTime eventDate;
  final String? eventTime;

  const EventReminderDialog({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    this.eventTime,
  });

  @override
  State<EventReminderDialog> createState() => _EventReminderDialogState();
}

class _EventReminderDialogState extends State<EventReminderDialog> {
  final _reminderService = EventReminderService();
  bool _hasReminder = false;
  List<String> _selectedTypes = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final Map<String, String> _reminderOptions = {
    '1day': '1 gün önce',
    '1hour': '1 saat önce',
    '30min': '30 dakika önce',
    '15min': '15 dakika önce',
  };

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    setState(() => _isLoading = true);

    final hasReminder = await _reminderService.hasReminder(widget.eventId);
    final types = await _reminderService.getReminderTypes(widget.eventId);

    if (mounted) {
      setState(() {
        _hasReminder = hasReminder;
        _selectedTypes = types;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir hatırlatıcı seçin')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _reminderService.scheduleEventReminder(
        eventId: widget.eventId,
        eventTitle: widget.eventTitle,
        eventDate: widget.eventDate,
        eventTime: widget.eventTime,
        reminderTypes: _selectedTypes,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatırlatıcı ayarlandı! 🔔'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _cancelReminder() async {
    setState(() => _isSaving = true);

    try {
      await _reminderService.cancelEventReminder(widget.eventId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatırlatıcı iptal edildi'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context, false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return AlertDialog(
        content: const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.notifications_active, color: scheme.primary),
          const SizedBox(width: 8),
          const Text('Etkinlik Hatırlatıcısı'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Etkinlik zamanı geldiğinde bildirim alın',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Hatırlatıcı Zamanları:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ..._reminderOptions.entries.map((entry) {
              final isSelected = _selectedTypes.contains(entry.key);
              return CheckboxListTile(
                title: Text(entry.value),
                value: isSelected,
                onChanged: _isSaving
                    ? null
                    : (value) {
                        setState(() {
                          if (value == true) {
                            _selectedTypes.add(entry.key);
                          } else {
                            _selectedTypes.remove(entry.key);
                          }
                        });
                      },
                contentPadding: EdgeInsets.zero,
                dense: true,
              );
            }),
          ],
        ),
      ),
      actions: [
        if (_hasReminder)
          TextButton.icon(
            onPressed: _isSaving ? null : _cancelReminder,
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('İptal Et'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveReminder,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check, size: 18),
          label: Text(_isSaving ? 'Kaydediliyor...' : 'Kaydet'),
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

/// Hatırlatıcı dialogunu göster
Future<bool?> showEventReminderDialog({
  required BuildContext context,
  required String eventId,
  required String eventTitle,
  required DateTime eventDate,
  String? eventTime,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => EventReminderDialog(
      eventId: eventId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      eventTime: eventTime,
    ),
  );
}
