import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/note_upload.dart';
import '../services/session_service.dart';
import '../services/notification_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
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

  String _selectedSemester = '1. Sınıf';
  String _selectedType = 'Ders Notu';
  bool _isSubmitting = false;
  String? _submitStatus;
  PlatformFile? _pickedFile;
  bool _isPickingFile = false;

  // Bölüm listesi için
  List<String> _departments = [];
  bool _isLoadingDepartments = true;
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    // Varsayılan bölüm listesini hemen yükle
    setState(() {
      _departments = _getDefaultDepartments();
      _isLoadingDepartments = false;
    });

    // Arka planda Firebase'den güncellemeyi dene
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('departments')
          .orderBy('name')
          .get()
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      final loadedDepts = snapshot.docs
          .map((doc) => doc.data()['name'] as String?)
          .where((name) => name != null && name.isNotEmpty)
          .cast<String>()
          .toList();

      if (loadedDepts.isNotEmpty) {
        setState(() {
          _departments = loadedDepts;
        });
      }
    } catch (e) {
      debugPrint('Error loading departments from Firebase: $e');
      // Varsayılan liste zaten yüklü, hata göstermeye gerek yok
    }
  }

  List<String> _getDefaultDepartments() {
    return [
      'Elektrik-Elektronik Mühendisliği',
      'Endüstri Mühendisliği',
      'Gıda Mühendisliği',
      'İnşaat Mühendisliği',
      'Makine Mühendisliği',
      'Yazılım Mühendisliği',
      'Bilgisayar Mühendisliği',
      'Enerji Sistemleri Mühendisliği',
      'Mekatronik Mühendisliği',
      'Mimarlık',
      'Peyzaj Mimarlık',
      'Şehir ve Bölge Planlama',
      'Çalışma Ekonomisi ve Endüstri İlişkileri',
      'İktisat',
      'İşletme',
      'Kamu Yönetimi',
      'Uluslararası İlişkiler',
      'Biyoloji',
      'Felsefe',
      'Fizik',
      'Kimya',
      'Matematik',
      'Psikoloji',
      'Sosyoloji',
      'Tarih',
      'Türk Dili ve Edebiyatı',
      'Beslenme ve Diyetetik',
      'Çocuk Gelişimi',
      'Ebelik',
      'Fizyoterapi ve Rehabilitasyon',
      'Hemşirelik',
      'Sağlık Yönetimi',
      'Sosyal Hizmet',
      'Rekreasyon Yönetimi',
      'Turizm İşletmeciliği',
      'Turizm Rehberliği',
      'Finans ve Bankacılık',
      'Muhasebe ve Finans Yönetimi',
      'Uluslararası Ticaret ve Lojistik',
      'Hukuk',
      'İlahiyat',
      'Tıp',
    ];
  }

  @override
  void dispose() {
    _courseController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isSubmitting,
      loadingMessage: _submitStatus,
      child: Scaffold(
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
                          child: _buildDepartmentDropdown(),
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
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Notu Paylaş',
                                    style: TextStyle(
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip('Ders Notu'),
        _buildChip('Soru Çözümü'),
        _buildChip('Özet / Slayt'),
      ],
    );
  }

  Widget _buildChip(String value) {
    final bool isSelected = _selectedType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E3A8A)
                : const Color(0xFFE0E0E0),
          ),
        ),
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

  Widget _buildDepartmentDropdown() {
    if (_isLoadingDepartments) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Bölümler yükleniyor...',
              style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => _DepartmentSheet(
            departments: _departments,
            selected: _selectedDepartment,
          ),
        );
        if (result != null) {
          setState(() => _selectedDepartment = result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.school_outlined,
              color: Color(0xFF1E3A8A),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDepartment ?? 'Bölüm seçiniz',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedDepartment != null
                      ? const Color(0xFF333333)
                      : const Color(0xFF999999),
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF666666),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerPlaceholder() {
    final name = _pickedFile?.name;
    final size = _pickedFile?.size;
    final sizeText = size != null && size > 0
        ? size > 1024 * 1024
              ? '${(size / (1024 * 1024)).toStringAsFixed(1)} MB'
              : '${(size / 1024).toStringAsFixed(0)} KB'
        : null;

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
                    child: Column(
                      children: [
                        Text(
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
                        if (sizeText != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: size! > 10 * 1024 * 1024
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  size > 10 * 1024 * 1024
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline,
                                  size: 12,
                                  color: size > 10 * 1024 * 1024
                                      ? Colors.orange.shade700
                                      : Colors.green.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sizeText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: size > 10 * 1024 * 1024
                                        ? Colors.orange.shade700
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
      // Web'de bytes gerekli, mobilde path kullanacağız
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: kIsWeb, // Web'de bytes yükle, mobilde path kullan
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

      // Web'de path olmaz, bytes olmalı
      if (kIsWeb && (file.bytes == null || file.bytes!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya okunamadı. Lütfen dosyayı tekrar seçin.'),
          ),
        );
        return;
      }

      // Mobil/Desktop'ta path olmalı
      if (!kIsWeb && (file.path == null || file.path!.isEmpty)) {
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

      // Büyük dosya uyarısı göster
      if (size > 5 * 1024 * 1024) {
        // 5 MB'dan büyükse
        final sizeMB = (size / (1024 * 1024)).toStringAsFixed(1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Büyük Dosya Seçildi ($sizeMB MB)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Yükleme işlemi biraz zaman alabilir. Lütfen bekleyin ve sayfayı kapatmayın.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            backgroundColor: const Color(0xFF1E3A8A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
    final department = _selectedDepartment;

    if (course.isEmpty ||
        title.isEmpty ||
        description.isEmpty ||
        department == null ||
        department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      final sizeMB = _pickedFile != null
          ? ((_pickedFile!.size / (1024 * 1024)).toStringAsFixed(1))
          : '0';
      _submitStatus = _pickedFile != null
          ? 'Dosya yükleniyor... ($sizeMB MB)\nLütfen bekleyin, bu işlem biraz sürebilir.'
          : 'Not kaydediliyor...';
    });

    try {
      await _submitNoteCore(
        course: course,
        title: title,
        description: description,
        department: department,
      ).timeout(
        const Duration(seconds: 120),
      ); // Büyük dosyalar için süre artırıldı

      if (!mounted) return;

      // Send notification to all users about new note
      await _sendNewNoteNotification(title, course);

      SuccessSnackBar.show(context, 'Not başarıyla paylaşıldı!');
      Navigator.pop(context);
    } on TimeoutException {
      if (!mounted) return;
      ErrorSnackBar.show(
        context,
        'Yükleme zaman aşımına uğradı. İnternet bağlantını kontrol edip tekrar dene.',
      );
    } catch (e) {
      debugPrint('_submitNote error: $e');
      if (!mounted) return;
      ErrorSnackBar.show(
        context,
        'Not paylaşılırken hata oluştu: ${e.toString()}',
        actionLabel: 'Tekrar Dene',
        onAction: _submitNote,
      );
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
      try {
        fileUrl = await uploadNoteFile(_pickedFile!).timeout(
          const Duration(seconds: 60),
        ); // Büyük dosyalar için süre artırıldı
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

  Future<void> _sendNewNoteNotification(String title, String course) async {
    try {
      // Get all users to send notification
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isActive', isEqualTo: true)
          .get();

      final userIds = usersSnapshot.docs
          .map((doc) => doc.id)
          .where((id) => id != FirebaseAuth.instance.currentUser?.uid)
          .toList();

      if (userIds.isNotEmpty) {
        await NotificationService().sendBulkNotification(
          userIds: userIds,
          title: 'Yeni Not Paylaşıldı',
          body: '$course dersi için "$title" notu paylaşıldı',
          type: 'note',
          data: {'course': course, 'noteTitle': title},
        );
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      // Don't throw error, notification is not critical
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
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/logo1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.school_rounded,
                            color: scheme.primary,
                            size: 36,
                          );
                        },
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
                  if (!isLoggedIn) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
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
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
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
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Notlar'),
                selected: true, // Bu sayfa notlar ile ilgili olduğu için seçili
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pop(context); // Notlar sayfasına geri dön
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
}

class _DepartmentSheet extends StatefulWidget {
  final List<String> departments;
  final String? selected;

  const _DepartmentSheet({required this.departments, required this.selected});

  @override
  State<_DepartmentSheet> createState() => _DepartmentSheetState();
}

class _DepartmentSheetState extends State<_DepartmentSheet> {
  final _searchController = TextEditingController();
  List<String> _filteredDepartments = [];

  @override
  void initState() {
    super.initState();
    _filteredDepartments = widget.departments;
    _searchController.addListener(_filterDepartments);
  }

  void _filterDepartments() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDepartments = query.isEmpty
          ? widget.departments
          : widget.departments
                .where((dept) => dept.toLowerCase().contains(query))
                .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 8, 4),
              child: Row(
                children: [
                  const Text(
                    'Bölüm Seç',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24),
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
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Bölüm ara...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E3A8A),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            // Department list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredDepartments.length,
                itemBuilder: (context, index) {
                  final department = _filteredDepartments[index];
                  final isSelected = department == widget.selected;
                  return ListTile(
                    title: Text(
                      department,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF333333),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF1E3A8A),
                            size: 20,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, department),
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
