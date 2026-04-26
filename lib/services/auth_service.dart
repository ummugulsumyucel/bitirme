import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _cachedDisplayName;
  String? _cachedRole; // 'student' | 'admin' | 'club_leader'

  bool get isLoggedIn => _auth.currentUser != null;

  /// Kullanıcının etkinlik ekleme yetkisi var mı (admin veya kulüp başkanı)
  bool get canAddEvent =>
      _cachedRole == 'admin' || _cachedRole == 'club_leader';

  /// Kullanıcının rolü
  String get currentRole => _cachedRole ?? 'student';

  String? get currentUserEmail => _auth.currentUser?.email;

  String? get currentUserName {
    final u = _auth.currentUser;
    final fromAuth = u?.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
    final c = _cachedDisplayName?.trim();
    if (c != null && c.isNotEmpty) return c;
    return null;
  }

  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      await SessionService.setUserDocId(user.uid);
      // Rol dahil profili senkronize et
      await _syncUserProfileFromFirestore(user).catchError((e) {
        debugPrint('AuthService.initialize sync (non-fatal): $e');
      });
    } else {
      _cachedDisplayName = null;
      _cachedRole = null;
      await SessionService.clearUserDocId();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userEmail');
      await prefs.remove('userName');
    }
  }

  Future<void> _persistLocalCache(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      await prefs.setString('userEmail', email);
    }
    final name = currentUserName;
    if (name != null && name.isNotEmpty) {
      await prefs.setString('userName', name);
    }
  }

  /// Firestore ve (gerekirse) Auth displayName ile önbelleği günceller.
  Future<void> _syncUserProfileFromFirestore(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      final fullName = (data?['fullName'] as String?)?.trim();
      if (fullName != null && fullName.isNotEmpty) {
        _cachedDisplayName = fullName;
        final dn = user.displayName?.trim();
        if (dn == null || dn.isEmpty) {
          await user.updateDisplayName(fullName);
          await user.reload();
        }
      } else {
        _cachedDisplayName = user.displayName?.trim();
      }
      // Rolü cache'le
      _cachedRole = (data?['role'] as String?)?.trim() ?? 'student';
    } catch (e, st) {
      debugPrint('AuthService._syncUserProfileFromFirestore: $e\n$st');
      _cachedDisplayName = user.displayName?.trim();
      _cachedRole = 'student';
    }
    final u2 = _auth.currentUser;
    if (u2 != null) await _persistLocalCache(u2);
  }

  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Profil verisi Firestore\'a yazılamadı (izin reddedildi). '
            'Firebase Console → Firestore → Kurallar bölümünde giriş yapmış '
            'kullanıcının kendi users/{uid} belgesine yazmasına izin verin.';
      case 'unavailable':
        return 'Firestore şu an kullanılamıyor. Bağlantınızı deneyip tekrar deneyin.';
      default:
        return 'Profil verisi kaydedilemedi: ${e.message ?? e.code}';
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'email-already-in-use':
        return 'Bu e-posta ile zaten bir hesap var.';
      case 'weak-password':
        return 'Şifre çok zayıf. En az 8 karakter kullanın.';
      case 'network-request-failed':
        return 'Ağ hatası. Bağlantınızı kontrol edin.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen bir süre sonra tekrar deneyin.';
      default:
        final m = e.message?.trim();
        if (m != null && m.isNotEmpty) return m;
        return 'Bir hata oluştu (${e.code}).';
    }
  }

  /// Başarılıysa `null`, aksi halde kullanıcıya gösterilecek mesaj.
  Future<String?> login(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = cred.user;
      if (user == null) return 'Giriş tamamlanamadı.';

      // E-posta doğrulaması kontrolü
      if (!user.emailVerified) {
        await _auth.signOut();
        return 'E-posta adresiniz henüz doğrulanmamış. '
            'Lütfen gelen kutunuzu kontrol edin ve doğrulama bağlantısına tıklayın.';
      }

      await SessionService.setUserDocId(user.uid);
      // Firestore sync'i arka planda yap, girişi bloklamasın
      _syncUserProfileFromFirestore(user).catchError((e) {
        debugPrint('AuthService.login sync (non-fatal): $e');
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } catch (e, st) {
      debugPrint('AuthService.login: $e\n$st');
      return 'Giriş sırasında beklenmeyen bir hata oluştu.';
    }
  }

  /// Doğrulama e-postasını yeniden gönderir. Başarılıysa `null`.
  Future<String?> resendVerificationEmail(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = cred.user;
      if (user == null) return 'Kullanıcı bulunamadı.';
      if (user.emailVerified) {
        await _auth.signOut();
        return 'E-posta zaten doğrulanmış.';
      }
      await user.sendEmailVerification();
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } catch (e, st) {
      debugPrint('AuthService.resendVerificationEmail: $e\n$st');
      return 'Doğrulama e-postası gönderilemedi.';
    }
  }

  /// Firebase Auth şifre sıfırlama e-postası. Başarılıysa `null`.
  Future<String?> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      return 'E-posta adresi gerekli.';
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } catch (e, st) {
      debugPrint('AuthService.sendPasswordResetEmail: $e\n$st');
      return 'Şifre sıfırlama e-postası gönderilemedi.';
    }
  }

  /// Başarılıysa `null`, aksi halde kullanıcıya gösterilecek mesaj.
  Future<String?> register(
    String name,
    String email,
    String password, {
    required String department,
    required String grade,
    String role = 'student',
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();
    // Güvenlik: sadece izin verilen roller kabul edilir
    final safeRole = ['student', 'club_leader', 'admin'].contains(role)
        ? role
        : 'student';
    User? created;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      created = cred.user;
      if (created == null) return 'Kayıt tamamlanamadı.';

      final uid = created.uid;

      // Önce Firestore (displayName güncellemesi bazen hata verebiliyor; veri kaybı olmasın).
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': trimmedName,
          'email': trimmedEmail,
          'department': department,
          'grade': grade,
          'role': safeRole,
          'isActive': true,
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } on FirebaseException catch (e, st) {
        debugPrint('AuthService.register Firestore: $e\n$st');
        try {
          await created.delete();
        } catch (delErr, delSt) {
          debugPrint('AuthService.register rollback delete: $delErr\n$delSt');
        }
        await _auth.signOut();
        return _mapFirestoreError(e);
      }

      try {
        await created.updateDisplayName(trimmedName);
        await created.reload();
      } catch (e, st) {
        debugPrint('AuthService.register displayName (non-fatal): $e\n$st');
      }

      // E-posta doğrulama maili gönder
      try {
        await created.sendEmailVerification();
        debugPrint(
          'AuthService.register: verification email sent to $trimmedEmail',
        );
      } catch (e, st) {
        debugPrint(
          'AuthService.register sendEmailVerification (non-fatal): $e\n$st',
        );
      }

      // Kayıt sonrası oturumu kapat; kullanıcı önce e-postasını doğrulamalı
      await _auth.signOut();
      _cachedDisplayName = null;
      _cachedRole = null;
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseAuthError(e);
    } catch (e, st) {
      debugPrint('AuthService.register: $e\n$st');
      return 'Kayıt sırasında beklenmeyen bir hata oluştu.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _cachedDisplayName = null;
    _cachedRole = null;
    await SessionService.clearUserDocId();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userName');
  }
}
