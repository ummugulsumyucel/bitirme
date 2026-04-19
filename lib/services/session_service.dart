import 'package:firebase_auth/firebase_auth.dart';
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

  static Future<void> clearUserDocId() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_kUserDocIdKey);
    } catch (e, st) {
      debugPrint('SessionService.clearUserDocId: $e\n$st');
    }
  }

  /// Oturum açmış kullanıcı için Firestore belge kimliği (Firebase Auth `uid`).
  /// Aksi halde kayıtlı tercih varsa onu döndürür.
  static Future<String?> ensureUserDocId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await setUserDocId(uid);
        return uid;
      }
      return await getUserDocId();
    } catch (e, st) {
      debugPrint('SessionService.ensureUserDocId: $e\n$st');
      return null;
    }
  }
}
