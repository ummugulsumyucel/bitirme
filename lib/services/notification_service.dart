import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Arka planda gelen FCM mesajlarını işler (top-level fonksiyon olmalı)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _notificationPermissionKey = 'notification_permission';
  static const String _lastNotificationCheckKey = 'last_notification_check';

  // FCM & local notifications
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'uniconnect_channel',
    'UniConnect Bildirimleri',
    description: 'Kampüs etkinlikleri ve notlar hakkında bildirimler',
    importance: Importance.high,
  );

  bool _isInitialized = false;
  List<AppNotification> _notifications = [];
  final List<Function(List<AppNotification>)> _listeners = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initFCM();
      await _initLocalNotifications();
      await _loadNotifications();
      _isInitialized = true;
      debugPrint('NotificationService initialized');
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  // ── FCM kurulumu ──────────────────────────────────────────────────────────

  Future<void> _initFCM() async {
    if (kIsWeb) return; // Web'de FCM farklı çalışır, şimdilik atla

    // İzin iste
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationPermissionKey, true);

      // FCM token'ı Firestore'a kaydet
      await _saveFcmToken();

      // Token yenilendiğinde güncelle
      _fcm.onTokenRefresh.listen(_updateFcmToken);
    }

    // Ön planda gelen mesajları göster
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Bildirime tıklanınca (arka plan → ön plan)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Uygulama kapalıyken gelen bildirime tıklanınca
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);
  }

  Future<void> _saveFcmToken() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('FCM token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('FCM token save error: $e');
    }
  }

  Future<void> _updateFcmToken(String token) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FCM token update error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');
    final notification = message.notification;
    if (notification == null) return;
    _showLocalPushNotification(
      title: notification.title ?? 'UniConnect',
      body: notification.body ?? '',
      payload: message.data['type'],
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FCM tapped: ${message.data}');
    // İleride deep-link navigasyonu buraya eklenebilir
  }

  // ── Local Notifications kurulumu ──────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    if (kIsWeb) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings);

    // Android kanalını oluştur
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  Future<void> _showLocalPushNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    try {
      const androidDetails = AndroidNotificationDetails(
        'uniconnect_channel',
        'UniConnect Bildirimleri',
        channelDescription:
            'Kampüs etkinlikleri ve notlar hakkında bildirimler',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Local notification show error: $e');
    }
  }

  // ── İzin yönetimi ─────────────────────────────────────────────────────────

  Future<bool> requestPermission() async {
    try {
      if (!kIsWeb) {
        final settings = await _fcm.requestPermission();
        final granted =
            settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_notificationPermissionKey, granted);
        return granted;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationPermissionKey, true);
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  Future<bool> hasPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationPermissionKey) ?? false;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return false;
    }
  }

  // ── Listener yönetimi ─────────────────────────────────────────────────────

  void addListener(Function(List<AppNotification>) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(List<AppNotification>) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener(_notifications);
      } catch (e) {
        debugPrint('Error notifying listener: $e');
      }
    }
  }

  // ── Firestore bildirim yükleme ────────────────────────────────────────────

  Future<void> _loadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();

      _notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> checkForNewNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastNotificationCheckKey) ?? 0;
      final lastCheckTime = DateTime.fromMillisecondsSinceEpoch(lastCheck);

      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastCheckTime))
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final newNotifications = snapshot.docs
            .map((doc) => AppNotification.fromFirestore(doc))
            .toList();

        _notifications.insertAll(0, newNotifications);
        _notifyListeners();

        // Ön planda local bildirim göster
        if (newNotifications.isNotEmpty) {
          final n = newNotifications.first;
          _showLocalPushNotification(
            title: n.title,
            body: n.body,
            payload: n.type,
          );
        }
      }

      await prefs.setInt(
        _lastNotificationCheckKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error checking for new notifications: $e');
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final notification in _notifications.where((n) => !n.isRead)) {
        batch.update(
          FirebaseFirestore.instance
              .collection('notifications')
              .doc(notification.id),
          {'isRead': true},
        );
      }

      await batch.commit();

      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      _notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();

      _notifications.removeWhere((n) => n.id == notificationId);
      _notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type ?? 'general',
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final userId in userIds) {
        final docRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc();
        batch.set(docRef, {
          'userId': userId,
          'title': title,
          'body': body,
          'type': type ?? 'general',
          'data': data ?? {},
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error sending bulk notification: $e');
    }
  }
}

// ── AppNotification model ─────────────────────────────────────────────────

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  IconData get icon {
    switch (type) {
      case 'event':
        return Icons.event;
      case 'note':
        return Icons.note;
      case 'announcement':
        return Icons.campaign;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color getColor(ColorScheme scheme) {
    switch (type) {
      case 'event':
        return scheme.primary;
      case 'note':
        return scheme.secondary;
      case 'announcement':
        return scheme.tertiary;
      case 'system':
        return scheme.outline;
      default:
        return scheme.onSurfaceVariant;
    }
  }
}
