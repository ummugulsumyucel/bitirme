import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/note_upload.dart';
import '../services/session_service.dart';
import 'announcements_page.dart';
import 'calendar_page.dart';
import 'events_screen.dart';
import 'login_page.dart';
import 'profile_screen.dart';
import 'register_page.dart';

class NewNoteScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const NewNoteScreen({super.key, this.onToggleTheme, this.isDarkMode = false});

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  String _selectedSemester = '1. Sınıf';
  String _selectedType = 'Ders Notu';
  bool _isSubmitting = false;
  String? _submitStatus;
  PlatformFile? _pickedFile;
  bool _isPickingFile = false;

  @override
  void dispose() {
    _courseController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yeni Not Paylaş',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ders notlarını diğer öğrencilerle paylaşarak topluluk içinde bilgi akışına katkı sağla.',
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
                        label: 'Ders Adı',
                        child: TextField(
                          controller: _courseController,
                          decoration: _inputDecoration(
                            hintText: 'Örn: Matematik I',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Not Başlığı',
                        child: TextField(
                          controller: _titleController,
                          decoration: _inputDecoration(
                            hintText: 'Örn: Vize Konu Özeti',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Bölüm',
                        child: TextField(
                          controller: _departmentController,
                          decoration: _inputDecoration(
                            hintText: 'Örn: Bilgisayar Mühendisliği',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Dönem / Sınıf',
                        child: _buildSemesterDropdown(),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Kısa Açıklama',
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: _inputDecoration(
                            hintText:
                                'Bu notta hangi konular var, hangi sınav için hazırlandı gibi bilgileri yaz.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Dosya Ekle (PDF / Görsel)',
                        child: _buildFilePickerPlaceholder(),
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
                          onPressed: _isSubmitting ? null : _submitNote,
                          child: Text(
                            _isSubmitting ? 'Paylasiliyor...' : 'Notu Paylas',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      if (_isSubmitting && _submitStatus != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _submitStatus!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        _buildChip('Ders Notu'),
        const SizedBox(width: 8),
        _buildChip('Soru Çözümü'),
        const SizedBox(width: 8),
        _buildChip('Özet / Slayt'),
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    final semesters = <String>[
      '1. Sınıf',
      '2. Sınıf',
      '3. Sınıf',
      '4. Sınıf',
      'Hazırlık',
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
          value: _selectedSemester,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: semesters
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
              _selectedSemester = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildFilePickerPlaceholder() {
    final name = _pickedFile?.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isPickingFile || _isSubmitting ? null : _pickNoteFile,
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
                      : Icons.note_add_outlined,
                  color: const Color(0xFF1E3A8A),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  _isPickingFile
                      ? 'Dosya seçiliyor...'
                      : 'PDF veya görsel seçmek için dokun',
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
            label: const Text('Dosyayı kaldır'),
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

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
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

  static const _allowedExt = {'pdf', 'png', 'jpg', 'jpeg', 'webp'};

  Future<void> _pickNoteFile() async {
    setState(() => _isPickingFile = true);
    try {
      // FileType.custom bazı cihazlarda çöküyor; any + uzantı kontrolü daha güvenli.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final ext = (file.extension ?? '').toLowerCase();
      if (!_allowedExt.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sadece PDF veya görsel (PNG, JPG, WEBP) seçebilirsin.',
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
            content: Text(
              'Dosya okunamadı. Başka bir dosya dene veya galeri yerine Dosyalar uygulamasından seç.',
            ),
          ),
        );
        return;
      }

      final size = file.size;
      if (size > 0 && size > 25 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya 25 MB\'dan küçük olmalıdır.')),
        );
        return;
      }

      setState(() => _pickedFile = file);
    } catch (e, st) {
      debugPrint('FilePicker: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dosya seçilemedi: $e'),
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

  Future<({String name, String? userDocId})> _resolveUploader() async {
    final docId = await SessionService.ensureUserDocId();
    if (docId == null) {
      return (name: 'Öğrenci', userDocId: null);
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .get();
      final n = doc.data()?['fullName'] as String?;
      final name = (n != null && n.trim().isNotEmpty) ? n.trim() : 'Öğrenci';
      return (name: name, userDocId: docId);
    } catch (_) {
      return (name: 'Öğrenci', userDocId: docId);
    }
  }

  Future<void> _submitNote() async {
    if (_isSubmitting) return;

    // Oturum kontrolü
    final authService = AuthService();
    if (!authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not paylaşmak için giriş yapman gerekiyor.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final course = _courseController.text.trim();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final department = _departmentController.text.trim();

    if (course.isEmpty ||
        title.isEmpty ||
        description.isEmpty ||
        department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitStatus = _pickedFile != null
          ? 'Dosya yukleniyor...'
          : 'Not kaydediliyor...';
    });

    try {
      await _submitNoteCore(
        course: course,
        title: title,
        description: description,
        department: department,
      ).timeout(const Duration(seconds: 70));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not başarıyla paylaşıldı.')),
      );
      Navigator.pop(context);
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yükleme zaman aşımına uğradı. İnternet bağlantını kontrol edip tekrar dene.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('_submitNote error: $e');
      // Hata mesajı zaten _submitNoteCore içinde gösterildi
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitStatus = null;
        });
      }
    }
  }

  Future<void> _submitNoteCore({
    required String course,
    required String title,
    required String description,
    required String department,
  }) async {
    String? fileUrl;
    String? fileName;
    String? fileMime;

    if (_pickedFile != null) {
      // Web'de bytes null ise hata ver
      if (kIsWeb &&
          (_pickedFile!.bytes == null || _pickedFile!.bytes!.isEmpty)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya okunamadı. Lütfen dosyayı tekrar seçin.'),
          ),
        );
        throw Exception('File bytes are null');
      }

      try {
        fileUrl = await uploadNoteFile(
          _pickedFile!,
        ).timeout(const Duration(seconds: 45));
      } catch (e) {
        debugPrint('uploadNoteFile error: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dosya yuklenemedi: $e'),
            duration: const Duration(seconds: 6),
          ),
        );
        rethrow;
      }

      if (fileUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Dosya yuklenemedi. Internetini kontrol edip yeniden dene.',
            ),
          ),
        );
        throw Exception('File upload returned null URL');
      }
      fileName = _pickedFile!.name;
      final ext = _pickedFile!.extension?.toLowerCase();
      fileMime = switch (ext) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'webp' => 'image/webp',
        _ => null,
      };
    }

    if (mounted) {
      setState(() => _submitStatus = 'Not veritabanına kaydediliyor...');
    }
    final uploader = await _resolveUploader().timeout(
      const Duration(seconds: 12),
      onTimeout: () => (name: 'Öğrenci', userDocId: null),
    );

    await FirebaseFirestore.instance
        .collection('notes')
        .add({
          'course': course,
          'title': title,
          'description': description,
          'department': department,
          'semester': _selectedSemester,
          'type': _selectedType,
          'uploaderName': uploader.name,
          'uploaderUserDocId': uploader.userDocId,
          'fileUrl': fileUrl,
          'fileName': fileName,
          'fileMimeType': fileMime,
          'ratingAvg': 0.0,
          'ratingCount': 0,
          'downloadCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .timeout(const Duration(seconds: 20));
  }

  Widget _buildDrawer(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'UniConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUserName ?? 'Kullanıcı',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Etkinlikler'),
            onTap: () {
              Navigator.pop(context);
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
            leading: const Icon(Icons.calendar_month),
            title: const Text('Takvim'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profilim'),
            onTap: () {
              Navigator.pop(context);
              if (!isLoggedIn) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
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
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('İlanlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementsPage(
                    onToggleDarkMode: widget.onToggleTheme ?? () {},
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          if (!isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Giriş Yap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Kayıt Ol'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                Navigator.pop(context);
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
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
