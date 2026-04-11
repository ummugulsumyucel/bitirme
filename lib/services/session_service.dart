import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kUserDocIdKey = 'current_user_doc_id';

class SessionService {
  SessionService._();

  static Future<String?> getUserDocId() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getString(_kUserDocIdKey);
    } catch (e, st) {
      debugPrint('SessionService.getUserDocId: $e\n$st');
      return null;
    }
  }

  static Future<void> setUserDocId(String docId) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kUserDocIdKey, docId);
    } catch (e, st) {
      debugPrint('SessionService.setUserDocId: $e\n$st');
    }
  }

  /// Kayıtlı oturum yoksa Firestore'daki kullanıcılardan birini bağlar.
  /// orderBy + index sorunları olmaması için sorgu [limit] ile çekilip
  /// [updatedAt] istemci tarafında sıralanır.
  static Future<String?> ensureUserDocId() async {
    try {
      String? id = await getUserDocId();
      if (id != null && id.isNotEmpty) return id;

      final snap =
          await FirebaseFirestore.instance.collection('users').limit(50).get();
      if (snap.docs.isEmpty) return null;

      final sorted = [...snap.docs];
      sorted.sort((a, b) {
        final ta = a.data()['updatedAt'];
        final tb = b.data()['updatedAt'];
        final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
        final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
        return mb.compareTo(ma);
      });

      id = sorted.first.id;
      await setUserDocId(id);
      return id;
    } catch (e, st) {
      debugPrint('SessionService.ensureUserDocId: $e\n$st');
      return null;
    }
  }
}
