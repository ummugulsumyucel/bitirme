import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

import '../services/auth_service.dart';
import '../widgets/common_drawer.dart';
import '../services/note_upload.dart';
import 'calendar_page.dart';
import 'login_page.dart';
import 'profile_screen.dart';
import 'register_page.dart';

class NewEventScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;
  final String? editEventId;           // Düzenleme modunda etkinlik ID'si
  final Map<String, dynamic>? initialData; // Düzenleme modunda mevcut veriler

  const NewEventScreen({
    super.key,
    this.onToggleTheme,
    this.isDarkMode = false,
    this.editEventId,
    this.initialData,
  });

  @override
  State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _selectedCategory = 'Seminer';
  String _selectedLabel = 'Ücretsiz';
  bool _isSubmitting = false;
  PlatformFile? _pickedFile;
  bool _isPickingFile = false;

  bool get _isEditMode => widget.editEventId != null;

  @override
  void initState() {
    super.initState();
    // Düzenleme modunda mevcut verileri doldur
    if (_isEditMode && widget.initialData != null) {
      final d = widget.initialData!;
      _titleController.text = (d['title'] as String?)?.trim() ?? '';
      _placeController.text = (d['place'] as String?)?.trim() ?? '';
      _descriptionController.text = (d['description'] as String?)?.trim() ?? '';
      _dateController.text = (d['date'] as String?)?.trim() ?? '';
      _timeController.text = (d['time'] as String?)?.trim() ?? '';
      _selectedCategory = (d['category'] as String?)?.trim() ?? 'Seminer';
      _selectedLabel = (d['label'] as String?)?.trim() ?? 'Ücretsiz';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      drawer: _buildDrawer(context),
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
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditMode ? 'Etkinliği Düzenle' : 'Yeni Etkinlik Oluştur',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEditMode
                            ? 'Etkinlik bilgilerini güncelleyin.'
                            : 'Kampüste düzenlenecek etkinlikleri paylaşarak diğer öğrencilerin katılımını sağla.',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLabeledField(
                        label: 'Etkinlik Başlığı',
                        child: TextField(
                          controller: _titleController,
                          decoration: _inputDecoration(
                            hintText: 'Örn: Yapay Zeka Semineri',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Kategori',
                        child: _buildCategoryDropdown(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildLabeledField(
                              label: 'Tarih',
                              child: TextField(
                                controller: _dateController,
                                readOnly: true,
                                decoration: _inputDecoration(
                                  hintText: 'Tarih seç',
                                  prefixIcon: Icons.calendar_today,
                                ),
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _dateController.text =
                                          '${picked.day}.${picked.month}.${picked.year}';
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildLabeledField(
                              label: 'Saat',
                              child: TextField(
                                controller: _timeController,
                                readOnly: true,
                                decoration: _inputDecoration(
                                  hintText: 'Saat seç',
                                  prefixIcon: Icons.access_time,
                                ),
                                onTap: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                  if (picked != null) {
                                    setState(() {
                                      _timeController.text =
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Konum',
                        child: TextField(
                          controller: _placeController,
                          decoration: _inputDecoration(
                            hintText: 'Örn: Mühendislik Amfisi',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Etiket',
                        child: _buildLabelDropdown(),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Etkinlik Resmi Ekle (Opsiyonel)',
                        child: _buildImagePickerPlaceholder(),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Etkinlik Açıklaması',
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: _inputDecoration(
                            hintText:
                                'Etkinlik hakkında detaylı bilgi ver. Katılımcıların bilmesi gereken önemli noktaları belirt.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isSubmitting ? null : _submitEvent,
                          child: Text(
                            _isSubmitting
                                ? (_isEditMode ? 'Güncelleniyor...' : 'Yayınlanıyor...')
                                : (_isEditMode ? 'Güncelle' : 'Etkinliği Yayınla'),
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 60,
      color: scheme.primary,
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

  Widget _buildCategoryDropdown() {
    final scheme = Theme.of(context).colorScheme;
    final categories = <String>[
      'Seminer',
      'Atölye',
      'Konser',
      'Spor',
      'Sosyal',
      'Eğitim',
      'Diğer',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          dropdownColor: scheme.surfaceContainerLow,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurface),
          items: categories
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurface,
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

  Widget _buildLabelDropdown() {
    final scheme = Theme.of(context).colorScheme;
    final labels = <String>[
      'Ücretsiz',
      'Ücretli',
      'Devam Ediyor',
      'Yakında',
      'Son Başvuru',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLabel,
          isExpanded: true,
          dropdownColor: scheme.surfaceContainerLow,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.onSurface),
          items: labels
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedLabel = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImagePickerPlaceholder() {
    final scheme = Theme.of(context).colorScheme;
    final name = _pickedFile?.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isPickingFile || _isSubmitting ? null : _pickImageFile,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPickingFile
                      ? Icons.hourglass_top
                      : Icons.add_a_photo_outlined,
                  color: scheme.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _isPickingFile
                      ? 'Fotoğraf seçiliyor...'
                      : 'Cihazından bir fotoğraf seç',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (!_isPickingFile && name == null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'veya',
                    style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamera ile çek',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
                if (name != null && name.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
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
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
      filled: true,
      fillColor: scheme.surfaceContainer,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: scheme.onSurfaceVariant)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 2),
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

  Future<void> _submitEvent() async {
    // Yetki kontrolü
    final auth = AuthService();
    if (!auth.isLoggedIn || !auth.canAddEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Etkinlik eklemek için yetkiniz yok. Sadece admin ve kulüp başkanları etkinlik ekleyebilir.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final place = _placeController.text.trim();
    final description = _descriptionController.text.trim();
    final date = _dateController.text.trim();
    final time = _timeController.text.trim();

    if (title.isEmpty || place.isEmpty || description.isEmpty || date.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      String? imageName;

      if (_pickedFile != null) {
        imageUrl = await uploadNoteFile(_pickedFile!);
        if (imageUrl == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fotoğraf yüklenemedi. Daha küçük bir fotoğraf deneyin.')),
          );
          return;
        }
        imageName = _pickedFile!.name;
      }

      if (_isEditMode) {
        // Güncelleme modu
        final updateData = <String, dynamic>{
          'title': title,
          'place': place,
          'description': description,
          'date': date,
          'time': time,
          'category': _selectedCategory,
          'label': _selectedLabel,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (imageUrl != null) {
          updateData['imageUrl'] = imageUrl;
          updateData['imageName'] = imageName;
        }
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.editEventId)
            .update(updateData);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Etkinlik başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        // Yeni ekleme modu
        await FirebaseFirestore.instance.collection('events').add({
          'title': title,
          'place': place,
          'description': description,
          'date': date,
          'time': time,
          'category': _selectedCategory,
          'label': _selectedLabel,
          'imageUrl': imageUrl,
          'imageName': imageName,
          'createdBy': FirebaseAuth.instance.currentUser?.uid ?? '',
          'createdByEmail': FirebaseAuth.instance.currentUser?.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Etkinlik başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                selected: true,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: const Text('İlanlar'),
                selected: false,
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
                  Navigator.pop(context);
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
                  widget.onToggleTheme?.call();
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
