import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/common_drawer.dart';
import '../services/note_upload.dart';
import '../services/session_service.dart';
import 'calendar_page.dart';
import 'events_screen.dart';
import 'login_page.dart';
import 'notes_feed_screen.dart';
import 'profile_screen.dart';
import 'register_page.dart';

class NewListingScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const NewListingScreen({
    super.key,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<NewListingScreen> createState() => _NewListingScreenState();
}

class _NewListingScreenState extends State<NewListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedType = 'Kayıp Eşya';
  String _selectedCategory = 'Genel';
  bool _isSubmitting = false;
  PlatformFile? _pickedFile;
  bool _isPickingFile = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: CommonDrawer(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
        selectedPage: 'announcements',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yeni İlan Oluştur',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kampüste kaybettiğin veya bulduğun eşyalar için hızlıca ilan oluştur. '
                        'Diğer öğrencilerle daha kolay iletişim kur.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTypeSelector(),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'İlan Başlığı',
                        child: TextField(
                          controller: _titleController,
                          decoration: _inputDecoration(
                            hintText: 'Örn: Kütüphanede Kayıp Cüzdan Bulundu',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Kategori Seç',
                        child: _buildCategoryDropdown(),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Konum',
                        child: TextField(
                          controller: _locationController,
                          decoration: _inputDecoration(
                            hintText: 'Örn: Kütüphane - 2. Kat',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Açıklama',
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: _inputDecoration(
                            hintText:
                                'Eşyanın rengi, markası, bulunma/ kaybolma zamanı gibi detayları yaz.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Fotoğraf Ekle (Opsiyonel)',
                        child: _buildImagePickerPlaceholder(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A7FCF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isSubmitting ? null : _submitListing,
                          child: Text(
                            _isSubmitting ? 'Yayinlaniyor...' : 'Ilani Yayinla',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const Icon(Icons.school, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              const Text(
                'UniConnect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: Colors.white,
            ),
            onPressed: widget.onToggleTheme ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildChip('Kayıp Eşya'),
        const SizedBox(width: 8),
        _buildChip('Bulunan Eşya'),
      ],
    );
  }

  Widget _buildChip(String value) {
    final bool isSelected = _selectedType == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1E3A8A)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFFE0E0E0),
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = <String>[
      'Genel',
      'Elektronik',
      'Kimlik / Kart',
      'Kitap / Defter',
      'Anahtar',
      'Diğer',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: categories
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImagePickerPlaceholder() {
    final name = _pickedFile?.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isPickingFile || _isSubmitting ? null : _pickImageFile,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPickingFile
                      ? Icons.hourglass_top
                      : Icons.add_a_photo_outlined,
                  color: const Color(0xFF1E3A8A),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  _isPickingFile
                      ? 'Fotoğraf seçiliyor...'
                      : 'Cihazından bir fotoğraf seç',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
                if (name != null && name.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (name != null && name.isNotEmpty)
          TextButton.icon(
            onPressed: _isSubmitting
                ? null
                : () => setState(() => _pickedFile = null),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Fotoğrafı kaldır'),
          ),
      ],
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF9CA3AF))
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  static const _allowedImageExt = {'png', 'jpg', 'jpeg', 'webp'};

  Future<void> _pickImageFile() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final ext = (file.extension ?? '').toLowerCase();
      if (!_allowedImageExt.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sadece görsel dosyaları (PNG, JPG, WEBP) seçebilirsin.',
            ),
          ),
        );
        return;
      }

      if (!kIsWeb &&
          (file.path == null || file.path!.isEmpty) &&
          (file.bytes == null || file.bytes!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya okunamadı. Başka bir fotoğraf dene.'),
          ),
        );
        return;
      }

      final size = file.size;
      if (size > 0 && size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf 10 MB\'dan küçük olmalıdır.')),
        );
        return;
      }

      setState(() => _pickedFile = file);
    } catch (e, st) {
      debugPrint('FilePicker: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilemedi: $e'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  Future<void> _submitListing() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || location.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
      );
      return;
    }

    // Oturum kontrolü
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan yayınlamak için giriş yapman gerekiyor.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imageUrl;
      String? imageName;

      if (_pickedFile != null) {
        // Web'de bytes kontrolü
        if (kIsWeb &&
            (_pickedFile!.bytes == null || _pickedFile!.bytes!.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dosya okunamadı. Lütfen tekrar seçin.'),
            ),
          );
          setState(() => _isSubmitting = false);
          return;
        }

        debugPrint('submitListing: uploading image ${_pickedFile!.name}');
        imageUrl = await uploadNoteFile(_pickedFile!);
        debugPrint('submitListing: imageUrl=$imageUrl');

        if (imageUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Fotoğraf yüklenemedi. Daha küçük bir fotoğraf deneyin veya fotoğrafsız devam edin.',
              ),
              duration: Duration(seconds: 4),
            ),
          );
          setState(() => _isSubmitting = false);
          return;
        }
        imageName = _pickedFile!.name;
      }

      final ownerId = await SessionService.ensureUserDocId();
      await FirebaseFirestore.instance.collection('listings').add({
        'title': title,
        'location': location,
        'description': description,
        'type': _selectedType,
        'category': _selectedCategory,
        'status': 'active',
        'ownerUserDocId': ownerId,
        'imageUrl': imageUrl,
        'imageName': imageName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan başarıyla yayınlandı!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('submitListing error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;

    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Builder(
        builder: (drawerContext) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary,
                      Color.lerp(
                        scheme.primary,
                        const Color(0xFF0F1729),
                        0.35,
                      )!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: scheme.onPrimary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'UniConnect',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kampüs hayatı tek uygulamada',
                      style: TextStyle(
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 18,
                            color: scheme.onPrimary.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authService.currentUserName ?? 'Kullanıcı',
                              style: TextStyle(
                                color: scheme.onPrimary.withValues(alpha: 0.95),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Text(
                  'MENÜ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Ana Sayfa'),
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Takvim'),
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profilim'),
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        embeddedInShell: false,
                        onToggleTheme: widget.onToggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('Etkinlikler'),
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventsScreen(
                        embeddedInShell: false,
                        onToggleTheme: widget.onToggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: const Text('İlanlar'),
                selected: true,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Notlar'),
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const NotesFeedScreen(embeddedInShell: false),
                    ),
                  );
                },
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.restaurant_menu),
                title: const Text('Yemek Menüsü'),
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Öneri / Şikayet'),
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              if (!isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Giriş Yap'),
                  onTap: () {
                    Navigator.pop(drawerContext);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Kayıt Ol'),
                  onTap: () {
                    Navigator.pop(drawerContext);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Çıkış Yap'),
                  onTap: () async {
                    Navigator.pop(drawerContext);
                    await authService.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Başarıyla çıkış yapıldı'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                title: Text(widget.isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
                onTap: () {
                  if (widget.onToggleTheme != null) {
                    widget.onToggleTheme!();
                  }
                  Navigator.pop(drawerContext);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    const destinations = <({IconData icon, IconData activeIcon, String label})>[
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Ana Sayfa'),
      (
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: 'Takvim',
      ),
      (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profilim'),
    ];

    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 0,
      color: scheme.surfaceContainer,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: ShellNavItem(
                      icon: destinations[i].icon,
                      activeIcon: destinations[i].activeIcon,
                      label: destinations[i].label,
                      selected: false,
                      onTap: () {
                        if (i == 0) {
                          Navigator.pop(context);
                        } else if (i == 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CalendarPage(),
                            ),
                          );
                        } else if (i == 2) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                embeddedInShell: false,
                                onToggleTheme: widget.onToggleTheme,
                                isDarkMode: widget.isDarkMode,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShellNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ShellNavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primaryContainer.withValues(alpha: 0.65)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                selected ? activeIcon : icon,
                size: 22,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                height: 1.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
