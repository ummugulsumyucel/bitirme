import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/common_drawer.dart';
import 'calendar_page.dart';
import 'events_screen.dart';
import 'login_page.dart';
import 'main_shell.dart';
import 'note_detail_screen.dart';
import 'profile_screen.dart';
import 'register_page.dart';

class NotesFeedScreen extends StatefulWidget {
  final bool embeddedInShell;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const NotesFeedScreen({
    super.key,
    this.embeddedInShell = false,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<NotesFeedScreen> createState() => _NotesFeedScreenState();
}

class _NotesFeedScreenState extends State<NotesFeedScreen> {
  String _semesterFilter = 'Tümü';
  String _categoryFilter = 'Tümü';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _categoryTabs = <String>[
    'Tümü',
    'Ders Notu',
    'Soru Çözümü',
    'Özet / Slayt',
    'Diğer',
  ];

  Widget _buildSearchBar() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Not ara... (başlık, açıklama)',
          hintStyle: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search,
            color: scheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: scheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(fontSize: 13, color: scheme.onSurface),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scroll = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTopFilters(),
            const SizedBox(height: 10),
            _buildCategoryTabs(),
            const SizedBox(height: 16),
            _buildNotesList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (widget.embeddedInShell) {
      return ColoredBox(
        color: scheme.surface,
        child: SizedBox.expand(child: scroll),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      drawer: CommonDrawer(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
        selectedPage: 'notes',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: scroll),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTopFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildFilterChip('Tümü'),
            const SizedBox(width: 8),
            _buildFilterChip('Hazırlık'),
            const SizedBox(width: 8),
            _buildFilterChip('1. Sınıf'),
            const SizedBox(width: 8),
            _buildFilterChip('2. Sınıf'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildFilterChip('3. Sınıf'),
            const SizedBox(width: 8),
            _buildFilterChip('4. Sınıf'),
            const SizedBox(width: 8),
            _buildFilterChip('Sınav Notları'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = _semesterFilter == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _semesterFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? scheme.primary : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _categoryTabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _buildTabChip(_categoryTabs[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildTabChip(String label) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = _categoryFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _categoryFilter = label),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? scheme.primary : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.book_outlined,
                size: 16,
                color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2, width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _noteSearchBlob(Map<String, dynamic> data) {
    final parts = <String?>[
      data['title'] as String?,
      data['course'] as String?,
      data['description'] as String?,
      data['department'] as String?,
      data['type'] as String?,
    ];
    return parts.whereType<String>().join(' ').toLowerCase();
  }

  bool _matchesSemesterFilter(Map<String, dynamic> data) {
    final semester = ((data['semester'] as String?) ?? '').trim();
    if (_semesterFilter == 'Tümü') return true;
    if (_semesterFilter == 'Sınav Notları') {
      final blob = _noteSearchBlob(data);
      return blob.contains('sınav') ||
          blob.contains('sinav') ||
          blob.contains('vize') ||
          blob.contains('final') ||
          blob.contains('quiz');
    }
    return semester == _semesterFilter;
  }

  bool _matchesCategoryTab(Map<String, dynamic> data) {
    if (_categoryFilter == 'Tümü') return true;
    final blob = _noteSearchBlob(data);
    final course = ((data['course'] as String?) ?? '').toLowerCase();
    final department = ((data['department'] as String?) ?? '').toLowerCase();

    switch (_categoryFilter) {
      case 'Ders Notu':
        return blob.contains('metin') ||
            blob.contains('ders not') ||
            blob.contains('konu anlatım') ||
            blob.contains('yazılı') ||
            blob.contains('text');
      case 'Soru Çözümü':
        return blob.contains('soru') ||
            blob.contains('çözüm') ||
            blob.contains('cozum') ||
            blob.contains('problem') ||
            blob.contains('alıştırma') ||
            blob.contains('alistirma') ||
            blob.contains('exercise');
      case 'Özet / Slayt':
        return blob.contains('özet') ||
            blob.contains('ozet') ||
            blob.contains('slayt') ||
            blob.contains('slide') ||
            blob.contains('sunum') ||
            blob.contains('presentation') ||
            blob.contains('summary');
      case 'Diğer':
        // Diğer kategoriler için false dönenler hariç tümü
        final isDersNotu =
            blob.contains('metin') ||
            blob.contains('ders not') ||
            blob.contains('konu anlatım');
        final isSoru =
            blob.contains('soru') ||
            blob.contains('çözüm') ||
            blob.contains('cozum') ||
            blob.contains('problem');
        final isOzet =
            blob.contains('özet') ||
            blob.contains('ozet') ||
            blob.contains('slayt');
        return !isDersNotu && !isSoru && !isOzet;
      default:
        return true;
    }
  }

  bool _matchesSearchQuery(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final blob = _noteSearchBlob(data);
    return blob.contains(_searchQuery);
  }

  Widget _buildNotesList(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('notes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Notlar yüklenirken hata: ${snapshot.error}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        var docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final aTs = a.data()['createdAt'];
          final bTs = b.data()['createdAt'];
          final aMs = aTs is Timestamp ? aTs.millisecondsSinceEpoch : 0;
          final bMs = bTs is Timestamp ? bTs.millisecondsSinceEpoch : 0;
          return bMs.compareTo(aMs);
        });

        docs = docs.where((d) {
          final data = d.data();
          return _matchesSemesterFilter(data) &&
              _matchesCategoryTab(data) &&
              _matchesSearchQuery(data);
        }).toList();

        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Arama sonucu bulunamadı. Farklı kelimeler deneyin.'
                  : 'Henüz bu filtreye uygun not yok. Yeni not paylaşabilirsin.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          );
        }

        return Column(
          children: List.generate(docs.length, (index) {
            final data = docs[index].data();
            final title = (data['title'] as String?)?.trim() ?? 'Başlıksız';
            final course = (data['course'] as String?)?.trim() ?? '';
            final semester = (data['semester'] as String?)?.trim() ?? '';
            final author =
                (data['uploaderName'] as String?)?.trim() ?? 'Öğrenci';
            final rating = (data['ratingAvg'] as num?)?.toDouble() ?? 0.0;
            final description = (data['description'] as String?)?.trim();
            final department = (data['department'] as String?)?.trim();
            final fileUrl = (data['fileUrl'] as String?)?.trim();
            final fileName = (data['fileName'] as String?)?.trim();

            final colorLabel = _semesterChipLabel(semester);
            final tagColor = _tagColorForSemester(semester);

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == docs.length - 1 ? 0 : 12,
              ),
              child: _buildNoteCard(
                context: context,
                noteId: docs[index].id,
                colorLabel: colorLabel,
                title: title,
                author: author.isEmpty ? 'Öğrenci' : author,
                course: course.isEmpty ? '—' : course,
                rating: rating,
                tagColor: tagColor,
                description: description,
                department: department,
                semester: semester,
                fileUrl: fileUrl,
                fileName: fileName,
              ),
            );
          }),
        );
      },
    );
  }

  String _semesterChipLabel(String semester) {
    final s = semester.trim();
    if (s.isEmpty) return 'NOT';
    return s.toUpperCase();
  }

  Color _tagColorForSemester(String semester) {
    switch (semester) {
      case '1. Sınıf':
        return const Color(0xFF14B8A6);
      case '2. Sınıf':
        return const Color(0xFF6366F1);
      case '3. Sınıf':
        return const Color(0xFF0EA5E9);
      case '4. Sınıf':
        return const Color(0xFFF97316);
      case 'Hazırlık':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildNoteCard({
    required BuildContext context,
    required String noteId,
    required String colorLabel,
    required String title,
    required String author,
    required String course,
    required double rating,
    required Color tagColor,
    String? description,
    String? department,
    String? semester,
    String? fileUrl,
    String? fileName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNoteCardBanner(
            fileUrl: fileUrl,
            fileName: fileName,
            tagColor: tagColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        colorLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tagColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, size: 14, color: Color(0xFFFACC15)),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('·', style: TextStyle(color: Color(0xFF9CA3AF))),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.menu_book_outlined,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        course,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailScreen(
                            noteId: noteId,
                            title: title,
                            author: author,
                            course: course,
                            rating: rating,
                            colorLabel: colorLabel,
                            tagColor: tagColor,
                            description: description,
                            department: department,
                            semester: semester,
                            fileUrl: fileUrl,
                            fileName: fileName,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Detayları Gör',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortFileName(String name) {
    if (name.length <= 28) return name;
    return '${name.substring(0, 12)}…${name.substring(name.length - 8)}';
  }

  bool _isImageUrl(String? url) {
    if (url == null) return false;
    if (url.startsWith('data:image/')) return true;
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  bool _isPdfUrl(String? url) {
    if (url == null) return false;
    if (url.startsWith('data:application/pdf')) return true;
    return url.toLowerCase().endsWith('.pdf');
  }

  Widget _buildNoteCardBanner({
    String? fileUrl,
    String? fileName,
    required Color tagColor,
  }) {
    final hasFile = fileUrl != null && fileUrl.isNotEmpty;
    final isImage = _isImageUrl(fileUrl);
    final isPdf = _isPdfUrl(fileUrl);

    if (hasFile && isImage) {
      // Görsel önizleme
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SizedBox(
          height: 140,
          width: double.infinity,
          child: Image.network(
            fileUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFileBanner(
              icon: Icons.image_not_supported_outlined,
              label: fileName ?? 'Görsel',
              color: tagColor,
            ),
          ),
        ),
      );
    }

    if (hasFile && isPdf) {
      // PDF banner
      return _buildFileBanner(
        icon: Icons.picture_as_pdf_outlined,
        label: fileName != null && fileName.isNotEmpty
            ? _shortFileName(fileName)
            : 'PDF Dosyası',
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
      );
    }

    if (hasFile) {
      // Diğer dosya türleri
      return _buildFileBanner(
        icon: Icons.insert_drive_file_outlined,
        label: fileName != null && fileName.isNotEmpty
            ? _shortFileName(fileName)
            : 'Dosya',
        color: tagColor,
      );
    }

    // Dosya yok
    return _buildFileBanner(
      icon: Icons.notes_outlined,
      label: 'Dosya eklenmedi',
      color: const Color(0xFF9CA3AF),
      bgColor: const Color(0xFFF9FAFB),
    );
  }

  Widget _buildFileBanner({
    required IconData icon,
    required String label,
    required Color color,
    Color? bgColor,
  }) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
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
                  icon: Icon(Icons.menu, color: scheme.onPrimary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Icon(Icons.school, color: scheme.onPrimary, size: 28),
              const SizedBox(width: 8),
              Text(
                'UniConnect',
                style: TextStyle(
                  color: scheme.onPrimary,
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
              color: scheme.onPrimary,
            ),
            onPressed: widget.onToggleTheme ?? () {},
          ),
        ],
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
