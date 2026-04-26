import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';

/// Authentication state management provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isLoading = false;
  String? _error;
  bool _isConnected = true;

  /// Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.isLoggedIn;
  bool get isConnected => _isConnected;
  String? get currentUserEmail => _authService.currentUserEmail;
  String? get currentUserName => _authService.currentUserName;
  String get currentRole => _authService.currentRole;
  bool get canAddEvent => _authService.canAddEvent;

  /// Initialize provider
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Initialize auth service
      await _authService.initialize();

      // Initialize connectivity service
      await _connectivityService.initialize();

      // Listen to connectivity changes
      _connectivityService.connectionStream.listen((isConnected) {
        _isConnected = isConnected;
        notifyListeners();
      });

      _clearError();
    } catch (e) {
      _setError('Başlatma hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_isConnected) {
        _setError('İnternet bağlantısı yok');
        return false;
      }

      final error = await _authService.login(email, password);

      if (error != null) {
        _setError(error);
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Giriş hatası: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String department,
    required String grade,
    String role = 'student',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_isConnected) {
        _setError('İnternet bağlantısı yok');
        return false;
      }

      final error = await _authService.register(
        name,
        email,
        password,
        department: department,
        grade: grade,
        role: role,
      );

      if (error != null) {
        _setError(error);
        return false;
      }

      return true;
    } catch (e) {
      _setError('Kayıt hatası: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_isConnected) {
        _setError('İnternet bağlantısı yok');
        return false;
      }

      final error = await _authService.resendVerificationEmail(email, password);

      if (error != null) {
        _setError(error);
        return false;
      }

      return true;
    } catch (e) {
      _setError('E-posta gönderme hatası: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_isConnected) {
        _setError('İnternet bağlantısı yok');
        return false;
      }

      final error = await _authService.sendPasswordResetEmail(email);

      if (error != null) {
        _setError(error);
        return false;
      }

      return true;
    } catch (e) {
      _setError('Şifre sıfırlama hatası: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Çıkış hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Test internet connection
  Future<bool> testConnection() async {
    try {
      return await _connectivityService.testConnection();
    } catch (e) {
      debugPrint('Connection test error: $e');
      return false;
    }
  }

  /// Get connection type description
  String getConnectionTypeDescription() {
    return _connectivityService.getConnectionTypeDescription();
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
