import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class EventReminderService {
  static final EventReminderService _instance =
      EventReminderService._internal();
  factory EventReminderService() => _instance;
  EventReminderService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      _isInitialized = true;
      debugPrint('EventReminderService initialized');
    } catch (e) {
      debugPrint('EventReminderService initialization error: $e');
    }
  }

  /// Etkinlik için hatırlatıcı ayarla
  /// [eventId] - Etkinlik ID
  /// [eventTitle] - Etkinlik başlığı
  /// [eventDate] - Etkinlik tarihi
  /// [eventTime] - Etkinlik saati (opsiyonel)
  /// [reminderTypes] - Hatırlatıcı tipleri: ['1day', '1hour', '30min']
  Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
    String? eventTime,
    List<String> reminderTypes = const ['1day', '1hour'],
  }) async {
    if (kIsWeb) {
      debugPrint('Event reminders not supported on web');
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Etkinlik tarih ve saatini birleştir
      DateTime eventDateTime = eventDate;
      if (eventTime != null && eventTime.isNotEmpty) {
        final timeParts = eventTime.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          eventDateTime = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            hour,
            minute,
          );
        }
      }

      // Geçmiş tarihse hatırlatıcı ayarlama
      if (eventDateTime.isBefore(DateTime.now())) {
        debugPrint('Event is in the past, skipping reminder');
        return;
      }

      // Hatırlatıcıları ayarla
      for (final type in reminderTypes) {
        await _scheduleReminder(
          eventId: eventId,
          eventTitle: eventTitle,
          eventDateTime: eventDateTime,
          reminderType: type,
        );
      }

      // Firestore'a kaydet
      await _saveReminderToFirestore(
        eventId: eventId,
        userId: user.uid,
        reminderTypes: reminderTypes,
      );

      debugPrint('Event reminders scheduled for: $eventTitle');
    } catch (e) {
      debugPrint('Error scheduling event reminder: $e');
    }
  }

  Future<void> _scheduleReminder({
    required String eventId,
    required String eventTitle,
    required DateTime eventDateTime,
    required String reminderType,
  }) async {
    DateTime reminderTime;
    String reminderMessage;

    switch (reminderType) {
      case '1day':
        reminderTime = eventDateTime.subtract(const Duration(days: 1));
        reminderMessage = 'Yarın: $eventTitle';
        break;
      case '1hour':
        reminderTime = eventDateTime.subtract(const Duration(hours: 1));
        reminderMessage = '1 saat sonra: $eventTitle';
        break;
      case '30min':
        reminderTime = eventDateTime.subtract(const Duration(minutes: 30));
        reminderMessage = '30 dakika sonra: $eventTitle';
        break;
      case '15min':
        reminderTime = eventDateTime.subtract(const Duration(minutes: 15));
        reminderMessage = '15 dakika sonra: $eventTitle';
        break;
      default:
        return;
    }

    // Geçmiş zamansa ayarlama
    if (reminderTime.isBefore(DateTime.now())) {
      debugPrint('Reminder time is in the past, skipping: $reminderType');
      return;
    }

    // Bildirim ID'si oluştur (eventId + reminderType)
    final notificationId = _generateNotificationId(eventId, reminderType);

    // Zamanlanmış bildirim ayarla
    await _localNotifications.zonedSchedule(
      notificationId,
      '🎉 Etkinlik Hatırlatıcısı',
      reminderMessage,
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Etkinlik Hatırlatıcıları',
          channelDescription: 'Yaklaşan etkinlikler için hatırlatıcılar',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'event:$eventId',
    );

    debugPrint(
      'Scheduled $reminderType reminder for $eventTitle at $reminderTime',
    );
  }

  Future<void> _saveReminderToFirestore({
    required String eventId,
    required String userId,
    required List<String> reminderTypes,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('event_reminders')
          .doc('${userId}_$eventId')
          .set({
            'userId': userId,
            'eventId': eventId,
            'reminderTypes': reminderTypes,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error saving reminder to Firestore: $e');
    }
  }

  /// Etkinlik hatırlatıcısını iptal et
  Future<void> cancelEventReminder(String eventId) async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Tüm hatırlatıcı tiplerini iptal et
      final reminderTypes = ['1day', '1hour', '30min', '15min'];
      for (final type in reminderTypes) {
        final notificationId = _generateNotificationId(eventId, type);
        await _localNotifications.cancel(notificationId);
      }

      // Firestore'dan sil
      await FirebaseFirestore.instance
          .collection('event_reminders')
          .doc('${user.uid}_$eventId')
          .delete();

      debugPrint('Event reminders cancelled for: $eventId');
    } catch (e) {
      debugPrint('Error cancelling event reminder: $e');
    }
  }

  /// Kullanıcının tüm hatırlatıcılarını iptal et
  Future<void> cancelAllReminders() async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _localNotifications.cancelAll();

      // Firestore'dan sil
      final reminders = await FirebaseFirestore.instance
          .collection('event_reminders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in reminders.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('All event reminders cancelled');
    } catch (e) {
      debugPrint('Error cancelling all reminders: $e');
    }
  }

  /// Etkinlik için hatırlatıcı var mı kontrol et
  Future<bool> hasReminder(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('event_reminders')
          .doc('${user.uid}_$eventId')
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking reminder: $e');
      return false;
    }
  }

  /// Etkinlik hatırlatıcı tiplerini getir
  Future<List<String>> getReminderTypes(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final doc = await FirebaseFirestore.instance
          .collection('event_reminders')
          .doc('${user.uid}_$eventId')
          .get();

      if (!doc.exists) return [];

      final data = doc.data();
      return List<String>.from(data?['reminderTypes'] ?? []);
    } catch (e) {
      debugPrint('Error getting reminder types: $e');
      return [];
    }
  }

  /// Bildirim ID'si oluştur (eventId + reminderType kombinasyonu)
  int _generateNotificationId(String eventId, String reminderType) {
    final combined = '$eventId-$reminderType';
    return combined.hashCode.abs() % 2147483647; // Max int32 value
  }

  /// Geçmiş etkinliklerin hatırlatıcılarını temizle
  Future<void> cleanupPastReminders() async {
    if (kIsWeb) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final reminders = await FirebaseFirestore.instance
          .collection('event_reminders')
          .where('userId', isEqualTo: user.uid)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      final now = DateTime.now();

      for (final reminderDoc in reminders.docs) {
        final eventId = reminderDoc.data()['eventId'] as String?;
        if (eventId == null) continue;

        // Etkinlik bilgisini al
        final eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();

        if (!eventDoc.exists) {
          // Etkinlik silinmişse hatırlatıcıyı da sil
          batch.delete(reminderDoc.reference);
          continue;
        }

        // Etkinlik geçmişse hatırlatıcıyı sil
        final eventData = eventDoc.data();
        final eventDateStr = eventData?['date'] as String?;
        if (eventDateStr != null) {
          try {
            final eventDate = DateTime.parse(eventDateStr);
            if (eventDate.isBefore(now)) {
              batch.delete(reminderDoc.reference);
            }
          } catch (e) {
            debugPrint('Error parsing event date: $e');
          }
        }
      }

      await batch.commit();
      debugPrint('Past reminders cleaned up');
    } catch (e) {
      debugPrint('Error cleaning up past reminders: $e');
    }
  }
}
