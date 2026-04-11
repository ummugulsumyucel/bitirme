import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _currentUserName;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  // Test kullanıcısı bilgileri
  static const String testEmail = 'test@university.edu';
  static const String testPassword = 'test123';
  static const String testName = 'Test Kullanıcı';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _currentUserEmail = prefs.getString('userEmail');
    _currentUserName = prefs.getString('userName');
  }

  Future<bool> login(String email, String password) async {
    // Test kullanıcısı kontrolü
    if (email == testEmail && password == testPassword) {
      _isLoggedIn = true;
      _currentUserEmail = email;
      _currentUserName = testName;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', testName);
      return true;
    }

    // Diğer kullanıcılar için (kayıt olanlar)
    // Şimdilik herhangi bir email/şifre ile giriş yapılabilir
    _isLoggedIn = true;
    _currentUserEmail = email;
    _currentUserName = email.split('@')[0]; // Email'den isim çıkar
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', _currentUserName ?? 'Kullanıcı');
    
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    // Kayıt işlemi - şimdilik her zaman başarılı
    _isLoggedIn = true;
    _currentUserEmail = email;
    _currentUserName = name;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserEmail = null;
    _currentUserName = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
  }
}





