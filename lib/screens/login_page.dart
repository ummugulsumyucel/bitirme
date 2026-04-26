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
        color: scheme.surface, // Tema arka planı
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
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.lightBlue,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'KLU UNICONNECT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '2025 - 2026',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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
            color: scheme.surface, // Tema arka planı
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
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            color: Colors.lightBlue,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'KLU UNICONNECT',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '2025 - 2026',
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
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
                  scheme.primaryContainer,
                  scheme.secondaryContainer,
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
                      'BACK TO',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    Text(
                      'KAMPÜS',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'BAĞLAN, PAYLAŞ, KEŞFET!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'KLU UNICONNECT',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 60),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.white,
                      ),
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

  Widget _firebaseAuthCaption() {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      'Giriş Firebase Authentication ile yapılır; yalnızca kayıt olduğunuz '
      'e-posta ve şifre kabul edilir.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        height: 1.4,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildEmailField() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: TextFormField(
        controller: _emailController,
        style: TextStyle(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: 'E-mail Adresinizi Girin',
          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.person, color: scheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Lütfen e-posta adresinizi girin';
          if (!value.contains('@')) return 'Geçerli bir e-posta adresi girin';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: TextFormField(
        controller: _passwordController,
        style: TextStyle(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Şifrenizi Giriniz',
          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
          prefixIcon: const Icon(Icons.lock, color: Colors.orange),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: scheme.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        obscureText: _obscurePassword,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Lütfen şifrenizi girin';
          if (value.length < 8) return 'Şifre en az 8 karakter olmalıdır';
          return null;
        },
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              activeColor: scheme.primary,
              onChanged: (value) => setState(() => _rememberMe = value ?? false),
            ),
            Text('Beni Hatırla', style: TextStyle(color: scheme.onSurface)),
          ],
        ),
        TextButton(
          onPressed: (_loggingIn || _sendingReset) ? null : _onForgotPassword,
          child: Text(
            _sendingReset ? 'Gönderiliyor…' : 'Şifremi Unuttum?',
            style: TextStyle(color: scheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final scheme = Theme.of(context).colorScheme;
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
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _loggingIn
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre sıfırlama için önce geçerli e-posta adresinizi yazın.'),
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
          content: Text('Şifre sıfırlama bağlantısı e-postanıza gönderildi.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Widget _buildRegisterLink() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Hesabınız Yok Mu? ', style: TextStyle(color: scheme.onSurfaceVariant)),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: Text(
            'Hesap Oluşturun',
            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
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
