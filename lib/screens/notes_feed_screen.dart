import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  static const _categoryTabs = <String>[
    'Tümü',
    'Metin',
    'Sosyal Güvenlik',
    'Matematik',
    'İktisat',
    'Diğer',
  ];

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFF6B7280),
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
        style: const TextStyle(fontSize: 13),
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
    final scroll = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTopFilters(),
            const SizedBox(height: 16),
            _buildNotesList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (widget.embeddedInShell) {
      return ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: SizedBox.expand(child: scroll),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: _buildDrawer(context),
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
    final isActive = _semesterFilter == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _semesterFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E3A8A) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF374151),
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
    final isActive = _categoryFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _categoryFilter = label),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E3A8A) : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.book_outlined,
                size: 16,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 2, width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF374151),
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
      case 'Metin':
        return blob.contains('metin') ||
            blob.contains('özet') ||
            blob.contains('ozet') ||
            blob.contains('slayt') ||
            blob.contains('ders not') ||
            blob.contains('konu anlatım');
      case 'Sosyal Güvenlik':
        return (blob.contains('sosyal') && blob.contains('güvenlik')) ||
            (blob.contains('sosyal') && blob.contains('guvenlik')) ||
            course.contains('sosyal güvenlik') ||
            course.contains('sosyal guvenlik') ||
            department.contains('sosyal güvenlik') ||
            department.contains('sosyal guvenlik');
      case 'Matematik':
        return blob.contains('matematik') ||
            blob.contains('mat') ||
            course.contains('matematik') ||
            course.contains('mat');
      case 'İktisat':
        return blob.contains('iktisat') ||
            blob.contains('ekonomi') ||
            course.contains('iktisat') ||
            course.contains('ekonomi');
      case 'Diğer':
        // Diğer kategoriler için false dönenler hariç tümü
        final isMath =
            blob.contains('matematik') || course.contains('matematik');
        final isEcon =
            blob.contains('iktisat') ||
            blob.contains('ekonomi') ||
            course.contains('iktisat') ||
            course.contains('ekonomi');
        final isSocial =
            (blob.contains('sosyal') &&
                (blob.contains('güvenlik') || blob.contains('guvenlik'))) ||
            course.contains('sosyal güvenlik') ||
            course.contains('sosyal guvenlik');
        return !isMath && !isEcon && !isSocial;
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
          return _matchesSemesterFilter(data) && _matchesSearchQuery(data);
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
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fileName != null && fileName.isNotEmpty
                            ? _shortFileName(fileName)
                            : 'Dosya eklenmedi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
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
                    child: const Text(
                      'Detayları Gör',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
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
                selected: false,
                onTap: () {
                  Navigator.pop(drawerContext);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Notlar'),
                selected: true,
                onTap: () {
                  Navigator.pop(drawerContext);
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
