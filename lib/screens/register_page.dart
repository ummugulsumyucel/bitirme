import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../utils/auth_navigation.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedClass;
  String _selectedRole = 'student';
  bool _submitting = false;

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final err = await AuthService().register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      department: _departmentController.text.trim(),
      grade: _selectedClass!,
      role: _selectedRole,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Hesabınız başarıyla oluşturuldu!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      finishLoginOrRegisterFlow(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Hesap Oluştur',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kampüs hayatına katılmak için hesabınızı oluşturun',
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Hesabınız Firebase Authentication ile oluşturulur; ad, bölüm ve '
                'sınıf bilgileriniz Firestore\'da profilinize kaydedilir.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildDepartmentField(),
              const SizedBox(height: 16),
              _buildClassField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Hesap Oluştur',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLoginLink(),
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
        // Sol taraf - Mavi arka plan
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(color: scheme.primary),
            child: const Center(
              child: Icon(Icons.school, size: 150, color: Colors.white),
            ),
          ),
        ),
        // Sağ taraf - Form
        Expanded(
          flex: 3,
          child: Container(
            color: scheme.surface, // Tema arka planı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kampüs hayatına katılmak için hesabınızı oluşturun',
                        style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kampüs hayatına katılmak için hesabınızı oluşturun',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 500) {
                            return Column(
                              children: [
                                _buildNameField(),
                                const SizedBox(height: 20),
                                _buildEmailField(),
                                const SizedBox(height: 20),
                                _buildDepartmentField(),
                                const SizedBox(height: 20),
                                _buildClassField(),
                                const SizedBox(height: 20),
                                _buildPasswordField(),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildNameField(),
                                    const SizedBox(height: 20),
                                    _buildDepartmentField(),
                                    const SizedBox(height: 20),
                                    _buildPasswordField(),
                                    const SizedBox(height: 20),
                                    _buildRoleSelector(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildEmailField(),
                                    const SizedBox(height: 20),
                                    _buildClassField(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submitRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Hesap Oluştur',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLoginLink(),
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

  Widget _buildNameField() {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: _nameController,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Ad Soyad',
        hintText: 'Adınız ve soyadınızı giriniz',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.person, color: scheme.primary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Lütfen adınızı ve soyadınızı girin';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: _emailController,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: 'E-posta',
        hintText: 'ornek@universite.edu.tr',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.email, color: scheme.primary),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Lütfen e-posta adresinizi girin';
        if (!value.contains('@')) return 'Geçerli bir e-posta adresi girin';
        return null;
      },
    );
  }

  Widget _buildDepartmentField() {
    final scheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: _selectedDepartment,
      dropdownColor: scheme.surfaceContainerLow,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Bölüm',
        hintText: 'Örn: Bilgisayar Mühendisliği',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.school, color: scheme.primary),
      ),
      items: const [
        DropdownMenuItem(value: 'Bilgisayar Mühendisliği', child: Text('Bilgisayar Mühendisliği')),
        DropdownMenuItem(value: 'Elektrik Mühendisliği', child: Text('Elektrik Mühendisliği')),
        DropdownMenuItem(value: 'Endüstri Mühendisliği', child: Text('Endüstri Mühendisliği')),
        DropdownMenuItem(value: 'Makine Mühendisliği', child: Text('Makine Mühendisliği')),
      ],
      onChanged: (value) => setState(() => _selectedDepartment = value),
      validator: (value) => value == null ? 'Lütfen bölüm seçin' : null,
    );
  }

  Widget _buildClassField() {
    final scheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: _selectedClass,
      dropdownColor: scheme.surfaceContainerLow,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Sınıf',
        hintText: 'Sınıfınızı seçiniz',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.class_, color: scheme.primary),
      ),
      items: const [
        DropdownMenuItem(value: 'Hazırlık', child: Text('Hazırlık')),
        DropdownMenuItem(value: '1. Sınıf', child: Text('1. Sınıf')),
        DropdownMenuItem(value: '2. Sınıf', child: Text('2. Sınıf')),
        DropdownMenuItem(value: '3. Sınıf', child: Text('3. Sınıf')),
        DropdownMenuItem(value: '4. Sınıf', child: Text('4. Sınıf')),
      ],
      onChanged: (value) => setState(() => _selectedClass = value),
      validator: (value) => value == null ? 'Lütfen sınıf seçin' : null,
    );
  }

  Widget _buildRoleSelector() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hesap Türü',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                value: 'student',
                label: 'Öğrenci',
                icon: Icons.school_outlined,
                description: 'Not paylaş, etkinliklere katıl',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                value: 'club_leader',
                label: 'Kulüp Başkanı',
                icon: Icons.groups_outlined,
                description: 'Etkinlik oluştur ve yönet',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String value,
    required String label,
    required IconData icon,
    required String description,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.08)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 2 : 1,
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
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, size: 18, color: scheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? scheme.primary : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
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

  Widget _buildPasswordField() {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: _passwordController,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Şifre',
        hintText: 'En az 8 karakter',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(Icons.lock, color: scheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: scheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Lütfen şifrenizi girin';
        if (value.length < 8) return 'Şifre en az 8 karakter olmalıdır';
        return null;
      },
    );
  }

  Widget _buildLoginLink() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Zaten hesabınız var mı? ', style: TextStyle(color: scheme.onSurfaceVariant)),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: Text(
            'Giriş Yap',
            style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold),
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
    _departmentController.dispose();
    super.dispose();
  }
}
