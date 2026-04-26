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

  // ── Mobile ────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Container(
        color: scheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLogo(scheme, size: 80),
              const SizedBox(height: 32),
              _buildHeading(scheme),
              const SizedBox(height: 32),
              _buildField(
                controller: _emailController,
                hint: 'E-posta adresi',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Lütfen e-posta adresinizi girin';
                  }
                  if (!v.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildPasswordField(),
              const SizedBox(height: 4),
              _buildRememberAndForgot(scheme),
              const SizedBox(height: 24),
              _buildLoginButton(scheme),
              const SizedBox(height: 20),
              _buildRegisterLink(scheme),
            ],
          ),
        ),
      ),
    );
  }

  // ── Desktop ───────────────────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Sol — form
        Expanded(
          flex: 3,
          child: Container(
            color: scheme.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLogo(scheme, size: 72),
                        const SizedBox(height: 28),
                        _buildHeading(scheme),
                        const SizedBox(height: 36),
                        _buildField(
                          controller: _emailController,
                          hint: 'E-posta adresi',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Lütfen e-posta adresinizi girin';
                            }
                            if (!v.contains('@')) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildPasswordField(),
                        const SizedBox(height: 4),
                        _buildRememberAndForgot(scheme),
                        const SizedBox(height: 28),
                        _buildLoginButton(scheme),
                        const SizedBox(height: 20),
                        _buildRegisterLink(scheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Sağ — tanıtım paneli
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary,
                  Color.lerp(scheme.primary, const Color(0xFF0F1729), 0.45)!,
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'KLU UniConnect',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bağlan · Paylaş · Keşfet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildFeatureRow(
                      Icons.event_rounded,
                      'Kampüs etkinliklerini takip et',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.menu_book_rounded,
                      'Ders notlarını paylaş',
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureRow(
                      Icons.campaign_rounded,
                      'Duyuruları kaçırma',
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

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  // ── Ortak widget'lar ──────────────────────────────────────────────────────

  Widget _buildLogo(ColorScheme scheme, {required double size}) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildHeading(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoş Geldiniz',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hesabınıza giriş yapın',
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Tek border'lı, temiz input alanı
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15, color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
        prefixIcon: Icon(icon, color: scheme.primary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    final scheme = Theme.of(context).colorScheme;
    return _buildField(
      controller: _passwordController,
      hint: 'Şifre',
      icon: Icons.lock_outline_rounded,
      obscure: _obscurePassword,
      suffix: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: scheme.onSurfaceVariant,
          size: 20,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Lütfen şifrenizi girin';
        if (v.length < 8) return 'Şifre en az 8 karakter olmalıdır';
        return null;
      },
    );
  }

  Widget _buildRememberAndForgot(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                activeColor: scheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Beni hatırla',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        TextButton(
          onPressed: (_loggingIn || _sendingReset) ? null : _onForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            _sendingReset ? 'Gönderiliyor…' : 'Şifremi unuttum',
            style: TextStyle(
              fontSize: 13,
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(ColorScheme scheme) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _loggingIn ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loggingIn
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
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

  Widget _buildRegisterLink(ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu?',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text(
            'Kayıt Ol',
            style: TextStyle(
              fontSize: 13,
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ── İş mantığı ────────────────────────────────────────────────────────────

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loggingIn = true);
    final email = _emailController.text.trim();
    final err = await AuthService().login(email, _passwordController.text);
    if (!mounted) return;
    setState(() => _loggingIn = false);
    if (err == null) {
      if (_rememberMe) {
        await _saveCredentials(email);
      } else {
        await _clearCredentials();
      }
      if (!mounted) return;
      finishLoginOrRegisterFlow(context);
    } else if (err.contains('doğrulanmamış')) {
      _showVerificationDialog(email, _passwordController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  void _showVerificationDialog(String email, String password) {
    bool sending = false;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.email_outlined, color: Color(0xFF1E3A8A)),
              SizedBox(width: 10),
              Expanded(child: Text('E-posta Doğrulanmamış')),
            ],
          ),
          content: const Text(
            'Hesabınıza giriş yapabilmek için e-posta adresinizi doğrulamanız gerekiyor.\n\n'
            'Gelen kutunuzu kontrol edin. Doğrulama maili gelmemişse tekrar gönderebilirsiniz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kapat'),
            ),
            FilledButton.icon(
              onPressed: sending
                  ? null
                  : () async {
                      setDialog(() => sending = true);
                      final err = await AuthService().resendVerificationEmail(
                        email,
                        password,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            err ??
                                'Doğrulama maili gönderildi. Gelen kutunuzu kontrol edin.',
                          ),
                          backgroundColor: err == null
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                    },
              icon: sending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
              label: const Text('Tekrar Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre sıfırlama için önce geçerli e-posta adresinizi yazın.',
          ),
        ),
      );
      return;
    }
    setState(() => _sendingReset = true);
    final err = await AuthService().sendPasswordResetEmail(email);
    if (!mounted) return;
    setState(() => _sendingReset = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          err ?? 'Şifre sıfırlama bağlantısı e-postanıza gönderildi.',
        ),
        backgroundColor: err == null ? Colors.green : null,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
