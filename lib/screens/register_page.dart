import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../utils/error_handler.dart';
import '../widgets/profile_photo_picker.dart';
import '../widgets/password_strength_indicator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with LoadingStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  String? _selectedClass;
  String? _selectedDepartment;
  String _selectedRole = 'student';
  bool _submitting = false;
  bool _acceptedTerms = false;
  File? _profileImage;
  Uint8List? _profileImageBytes; // Web için

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Şartlar ve koşullar kontrolü
    if (!_acceptedTerms) {
      ErrorHandler.showErrorSnackBar(
        context,
        'Lütfen kullanım şartlarını kabul edin',
      );
      return;
    }

    // Profil fotoğrafı boyut kontrolü
    if (kIsWeb && _profileImageBytes != null) {
      final isValidSize = _validateImageBytesSize(_profileImageBytes!);
      if (!isValidSize) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            'Profil fotoğrafı 5MB\'dan küçük olmalıdır',
          );
        }
        return;
      }
    } else if (!kIsWeb && _profileImage != null) {
      final isValidSize = await _validateImageSize(_profileImage!);
      if (!isValidSize) {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            'Profil fotoğrafı 5MB\'dan küçük olmalıdır',
          );
        }
        return;
      }
    }

    setState(() => _submitting = true);

    try {
      final err = await AuthService().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        department: _selectedDepartment ?? '',
        grade: _selectedClass!,
        role: _selectedRole,
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (err == null) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.mark_email_read_outlined, color: Colors.green),
                SizedBox(width: 10),
                Text('Hesap Oluşturuldu'),
              ],
            ),
            content: const Text(
              'Hesabiniz basariyla olusturuldu!\n\n'
              'E-posta adresinize bir dogrulama baglantisi gonderdik. '
              'Lutfen gelen kutunuzu kontrol edin.\n\n'
              'Dogrulama sonrasi giris yapabilirsiniz.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tamam, Giris Yap'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ErrorHandler.showErrorSnackBar(context, err);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  /// Resim boyutunu kontrol et (File için)
  Future<bool> _validateImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final sizeInMB = bytes.length / (1024 * 1024);
      return sizeInMB <= 5; // 5MB limit
    } catch (e) {
      return false;
    }
  }

  /// Resim boyutunu kontrol et (Bytes için)
  bool _validateImageBytesSize(Uint8List bytes) {
    final sizeInMB = bytes.length / (1024 * 1024);
    return sizeInMB <= 5; // 5MB limit
  }

  InputDecoration _dec({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(14);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
      prefixIcon: Icon(icon, color: scheme.primary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    );
  }

  Widget _nameField() => TextFormField(
    controller: _nameController,
    style: TextStyle(
      fontSize: 15,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    decoration: _dec(hint: 'Ad Soyad', icon: Icons.person_outline_rounded),
    validator: Validators.validateName,
  );

  Widget _emailField() => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    style: TextStyle(
      fontSize: 15,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    decoration: _dec(hint: 'E-posta adresi', icon: Icons.email_outlined),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Lütfen e-posta adresinizi girin';
      return Validators.validateEmail(v, requireKluDomain: false);
    },
  );

  Widget _phoneField() => TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    style: TextStyle(
      fontSize: 15,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    decoration: _dec(
      hint: 'Telefon Numarası (isteğe bağlı)',
      icon: Icons.phone_outlined,
    ),
    validator: (v) =>
        v != null && v.isNotEmpty ? Validators.validatePhone(v) : null,
  );

  Widget _passwordField() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(fontSize: 15, color: scheme.onSurface),
          onChanged: (v) => setState(() {}),
          decoration: _dec(
            hint: 'Şifre (güçlü şifre seçin)',
            icon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 8),
        PasswordStrengthIndicator(password: _passwordController.text),
      ],
    );
  }

  Widget _passwordConfirmField() {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: _passwordConfirmController,
      obscureText: _obscurePasswordConfirm,
      style: TextStyle(fontSize: 15, color: scheme.onSurface),
      decoration: _dec(
        hint: 'Şifre Tekrar',
        icon: Icons.lock_outline_rounded,
        suffix: IconButton(
          icon: Icon(
            _obscurePasswordConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: scheme.onSurfaceVariant,
            size: 20,
          ),
          onPressed: () => setState(
            () => _obscurePasswordConfirm = !_obscurePasswordConfirm,
          ),
        ),
      ),
      validator: (v) =>
          Validators.validatePasswordMatch(v, _passwordController.text),
    );
  }

  Widget _termsCheckbox() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            activeColor: scheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                children: [
                  const TextSpan(text: 'Okudum, '),
                  TextSpan(
                    text: 'Kullanıcı Sözleşmesi',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' ve '),
                  TextSpan(
                    text: 'Gizlilik Politikası',
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '\'nı kabul ediyorum'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static const List<String> _depts = [
    'Elektrik-Elektronik Muhendisligi',
    'Endustri Muhendisligi',
    'Gida Muhendisligi',
    'Insaat Muhendisligi',
    'Makine Muhendisligi',
    'Yazilim Muhendisligi',
    'Enerji Sistemleri Muhendisligi',
    'Mekatronik Muhendisligi',
    'Mimarlik',
    'Peyzaj Mimarlik',
    'Sehir ve Bolge Planlama',
    'Calisma Ekonomisi ve Endustri Iliskileri',
    'Iktisat',
    'Isletme',
    'Kamu Yonetimi',
    'Uluslararasi Iliskiler',
    'Biyoloji',
    'Felsefe',
    'Fizik',
    'Kimya',
    'Matematik',
    'Psikoloji',
    'Sosyoloji',
    'Tarih',
    'Turk Dili ve Edebiyati',
    'Beslenme ve Diyetetik',
    'Cocuk Gelisimi',
    'Ebelik',
    'Fizyoterapi ve Rehabilitasyon',
    'Hemsirelik',
    'Saglik Yonetimi',
    'Sosyal Hizmet',
    'Rekreasyon Yonetimi',
    'Turizm Isletmeciligi',
    'Turizm Rehberligi',
    'Finans ve Bankacilik',
    'Muhasebe ve Finans Yonetimi',
    'Uluslararasi Ticaret ve Lojistik',
    'Hukuk',
    'Ilahiyat',
    'Tip',
  ];

  Widget _deptField() {
    final scheme = Theme.of(context).colorScheme;
    return FormField<String>(
      initialValue: _selectedDepartment,
      validator: (v) => v == null ? 'Lutfen bolum secin' : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              final r = await showModalBottomSheet<String>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => _DeptSheet(
                  depts: _depts,
                  selected: _selectedDepartment,
                  scheme: scheme,
                ),
              );
              if (r != null) {
                setState(() => _selectedDepartment = r);
                state.didChange(r);
              }
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: state.hasError ? scheme.error : scheme.outlineVariant,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.school_outlined, color: scheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDepartment ?? 'Bolum seciniz',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDepartment != null
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 6),
              child: Text(
                state.errorText!,
                style: TextStyle(color: scheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _classField() {
    final scheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: _selectedClass,
      dropdownColor: scheme.surfaceContainerLow,
      style: TextStyle(color: scheme.onSurface, fontSize: 15),
      decoration: _dec(hint: 'Sinif seciniz', icon: Icons.class_outlined),
      items: const [
        DropdownMenuItem(value: 'Hazirlik', child: Text('Hazirlik')),
        DropdownMenuItem(value: '1. Sinif', child: Text('1. Sinif')),
        DropdownMenuItem(value: '2. Sinif', child: Text('2. Sinif')),
        DropdownMenuItem(value: '3. Sinif', child: Text('3. Sinif')),
        DropdownMenuItem(value: '4. Sinif', child: Text('4. Sinif')),
      ],
      onChanged: (v) => setState(() => _selectedClass = v),
      validator: (v) => v == null ? 'Lutfen sinif secin' : null,
    );
  }

  Widget _roleSelector() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesap Turu',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _roleCard(
                'student',
                'Ogrenci',
                Icons.school_outlined,
                'Not paylas, etkinliklere katil',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _roleCard(
                'club_leader',
                'Kulup Baskani',
                Icons.groups_outlined,
                'Etkinlik olustur ve yonet',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleCard(String value, String label, IconData icon, String desc) {
    final scheme = Theme.of(context).colorScheme;
    final sel = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sel
              ? scheme.primary.withValues(alpha: 0.08)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? scheme.primary : scheme.outlineVariant,
            width: sel ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: sel ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const Spacer(),
                if (sel)
                  Icon(Icons.check_circle, size: 18, color: scheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: sel ? scheme.primary : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitBtn(ColorScheme scheme) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: _submitting ? null : _submitRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _submitting
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Text(
              'Hesap Olustur',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    ),
  );

  Widget _loginLink(ColorScheme scheme) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Zaten hesabiniz var mi?',
        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
      ),
      TextButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        child: Text(
          'Giris Yap',
          style: TextStyle(
            fontSize: 13,
            color: scheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(body: w < 800 ? _mobile() : _desktop());
  }

  Widget _mobile() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Container(
        color: scheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hesap Oluştur',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kampüs hayatına katılmak için hesabınızı oluşturun',
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),

              // Profil fotoğrafı
              Center(
                child: ProfilePhotoPicker(
                  onImageSelected: (file) =>
                      setState(() => _profileImage = file),
                  onImageBytesSelected: (bytes, name) => setState(() {
                    _profileImageBytes = bytes;
                  }),
                  size: 100,
                ),
              ),
              const SizedBox(height: 24),

              _nameField(),
              const SizedBox(height: 14),
              _emailField(),
              const SizedBox(height: 14),
              _phoneField(),
              const SizedBox(height: 14),
              _deptField(),
              const SizedBox(height: 14),
              _classField(),
              const SizedBox(height: 14),
              _passwordField(),
              const SizedBox(height: 14),
              _passwordConfirmField(),
              const SizedBox(height: 20),
              _roleSelector(),
              const SizedBox(height: 20),
              _termsCheckbox(),
              const SizedBox(height: 28),
              _submitBtn(scheme),
              const SizedBox(height: 16),
              _loginLink(scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktop() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
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
                      'Baglan - Paylas - Kesfet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: scheme.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hesap Olustur',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kampus hayatina katilmak icin hesabinizi olusturun',
                        style: TextStyle(
                          fontSize: 15,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _nameField(),
                                const SizedBox(height: 14),
                                _deptField(),
                                const SizedBox(height: 14),
                                _passwordField(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _emailField(),
                                const SizedBox(height: 14),
                                _classField(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _roleSelector(),
                      const SizedBox(height: 32),
                      _submitBtn(scheme),
                      const SizedBox(height: 16),
                      _loginLink(scheme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _DeptSheet extends StatefulWidget {
  final List<String> depts;
  final String? selected;
  final ColorScheme scheme;
  const _DeptSheet({
    required this.depts,
    required this.selected,
    required this.scheme,
  });
  @override
  State<_DeptSheet> createState() => _DeptSheetState();
}

class _DeptSheetState extends State<_DeptSheet> {
  final _ctrl = TextEditingController();
  List<String> _filtered = [];
  @override
  void initState() {
    super.initState();
    _filtered = widget.depts;
    _ctrl.addListener(_search);
  }

  void _search() {
    final q = _ctrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.depts
          : widget.depts.where((d) => d.toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.88,
      expand: false,
      builder: (_, sc) => Container(
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: s.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 8, 4),
              child: Row(
                children: [
                  Text(
                    'Bolum Sec',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: s.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: s.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: TextStyle(fontSize: 14, color: s.onSurface),
                decoration: InputDecoration(
                  hintText: 'Bolum ara...',
                  hintStyle: TextStyle(fontSize: 13, color: s.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: s.primary,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: s.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: s.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: s.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: s.primary, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: sc,
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final d = _filtered[i];
                  final sel = d == widget.selected;
                  return ListTile(
                    title: Text(
                      d,
                      style: TextStyle(
                        fontSize: 14,
                        color: sel ? s.primary : s.onSurface,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: sel
                        ? Icon(Icons.check_rounded, color: s.primary, size: 18)
                        : null,
                    onTap: () => Navigator.pop(context, d),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
