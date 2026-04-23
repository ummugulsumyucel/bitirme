import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import '../services/auth_service.dart';
import '../utils/auth_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _loggingIn = false;
  bool _sendingReset = false;

  static const _kRememberMe = 'remember_me';
  static const _kSavedEmail = 'saved_email';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_kRememberMe) ?? false;
    if (remember) {
      final email = prefs.getString(_kSavedEmail) ?? '';
      if (mounted) {
        setState(() {
          _rememberMe = true;
          _emailController.text = email;
        });
      }
    }
  }

  Future<void> _saveCredentials(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberMe, true);
    await prefs.setString(_kSavedEmail, email);
  }

  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRememberMe);
    await prefs.remove(_kSavedEmail);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: isSmallScreen ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Container(
        color: scheme.surface,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo1.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 12),
              const SizedBox(height: 28),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 16),
              _buildRememberAndForgot(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 16),
              _buildRegisterLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Sol taraf - Form
        Expanded(
          flex: 3,
          child: Container(
            color: scheme.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo1.png',
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 12),
                        const SizedBox(height: 36),
                        _buildEmailField(),
                        const SizedBox(height: 20),
                        _buildPasswordField(),
                        const SizedBox(height: 20),
                        _buildRememberAndForgot(),
                        const SizedBox(height: 30),
                        _buildLoginButton(),
                        const SizedBox(height: 20),
                        _buildRegisterLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Sağ taraf - Tanıtım
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.5),
                  scheme.secondaryContainer.withValues(alpha: 0.45),
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'BAĞLAN, PAYLAŞ, KEŞFET!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Image.asset(
                      'assets/images/logo1.png',
                      width: 200,
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          hintText: 'E-mail Adresinizi Girin',
          prefixIcon: Icon(Icons.person, color: scheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen e-posta adresinizi girin';
          }
          if (!value.contains('@')) {
            return 'Geçerli bir e-posta adresi girin';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          hintText: 'Şifrenizi Giriniz',
          prefixIcon: Icon(Icons.lock, color: scheme.primary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        obscureText: _obscurePassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Lütfen şifrenizi girin';
          }
          if (value.length < 8) {
            return 'Şifre en az 8 karakter olmalıdır';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
            const Text('Beni Hatırla'),
          ],
        ),
        TextButton(
          onPressed: (_loggingIn || _sendingReset) ? null : _onForgotPassword,
          child: Text(
            _sendingReset ? 'Gönderiliyor…' : 'Şifremi Unuttum?',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loggingIn
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _loggingIn = true);
                  final email = _emailController.text.trim();
                  final err = await AuthService().login(
                    email,
                    _passwordController.text,
                  );
                  if (!mounted) return;
                  setState(() => _loggingIn = false);
                  if (err == null) {
                    if (_rememberMe) {
                      await _saveCredentials(email);
                    } else {
                      await _clearCredentials();
                    }
                    finishLoginOrRegisterFlow(context);
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(err)));
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _loggingIn
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _onForgotPassword() async {
    // Önce e-posta alanındaki değeri al
    String email = _emailController.text.trim();

    // E-posta boşsa dialog aç
    if (email.isEmpty || !email.contains('@')) {
      final controller = TextEditingController(text: email);
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Şifre Sıfırlama'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kayıtlı e-posta adresinizi girin. Şifre sıfırlama bağlantısı gönderilecek.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  hintText: 'ornek@universite.edu.tr',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Gönder'),
            ),
          ],
        ),
      );
      if (result == null || result.isEmpty || !result.contains('@')) return;
      email = result;
    }

    if (!mounted) return;
    setState(() => _sendingReset = true);
    final err = await AuthService().sendPasswordResetEmail(email);
    if (!mounted) return;
    setState(() => _sendingReset = false);
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre sıfırlama bağlantısı e-postanıza gönderildi. Spam klasörünü de kontrol edin.',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Hesabınız Yok Mu? '),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: Text(
            'Hesap Oluşturun',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
