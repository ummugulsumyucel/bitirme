import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _notificationPermissionKey = 'notification_permission';
  static const String _lastNotificationCheckKey = 'last_notification_check';

  bool _isInitialized = false;
  List<AppNotification> _notifications = [];
  final List<Function(List<AppNotification>)> _listeners = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadNotifications();
      _isInitialized = true;
      debugPrint('NotificationService initialized');
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
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

        // Show local notification for the most recent one
        if (newNotifications.isNotEmpty) {
          _showLocalNotification(newNotifications.first);
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

  void _showLocalNotification(AppNotification notification) {
    // Bu gerçek bir push notification servisi ile değiştirilmeli
    // Şimdilik sadece debug print
    debugPrint('New notification: ${notification.title}');
  }

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
