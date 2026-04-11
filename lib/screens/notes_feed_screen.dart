import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'events_screen.dart';
import 'note_detail_screen.dart';

class NotesFeedScreen extends StatefulWidget {
  const NotesFeedScreen({super.key});

  @override
  State<NotesFeedScreen> createState() => _NotesFeedScreenState();
}

class _NotesFeedScreenState extends State<NotesFeedScreen> {
  String _semesterFilter = 'Tümü';
  String _categoryFilter = 'Tümü';

  static const _categoryTabs = <String>[
    'Tümü',
    'Metin',
    'Sosyal Güvenlik',
    'Matematik',
    'İktisat',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopFilters(),
                      const SizedBox(height: 16),
                      _buildCategoryTabs(),
                      const SizedBox(height: 16),
                      _buildNotesList(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
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
            children: const [
              Icon(Icons.school, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'UniConnect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.dark_mode_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
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
              color:
                  isActive ? const Color(0xFF1E3A8A) : const Color(0xFFE5E7EB),
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
              color:
                  isActive ? const Color(0xFF1E3A8A) : const Color(0xFFE5E7EB),
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
      final blob = '${semester.toLowerCase()} ${_noteSearchBlob(data)}';
      return blob.contains('sınav') ||
          blob.contains('sinav') ||
          blob.contains('vize') ||
          blob.contains('final');
    }
    return semester == _semesterFilter.trim();
  }

  bool _matchesCategoryTab(Map<String, dynamic> data) {
    if (_categoryFilter == 'Tümü') return true;
    final t = _noteSearchBlob(data);
    switch (_categoryFilter) {
      case 'Metin':
        return t.contains('metin') ||
            t.contains('özet') ||
            t.contains('ozet') ||
            t.contains('slayt') ||
            t.contains('ders notu');
      case 'Sosyal Güvenlik':
        return (t.contains('sosyal') && t.contains('güvenlik')) ||
            (t.contains('sosyal') && t.contains('guvenlik'));
      case 'Matematik':
        return t.contains('matematik');
      case 'İktisat':
        return t.contains('iktisat');
      case 'Diğer':
        if (t.contains('matematik')) return false;
        if (t.contains('iktisat')) return false;
        if (t.contains('sosyal') &&
            (t.contains('güvenlik') || t.contains('guvenlik'))) {
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Widget _buildNotesList(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('notes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Notlar yüklenirken hata: ${snapshot.error}',
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ));
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
          return _matchesSemesterFilter(data) && _matchesCategoryTab(data);
        }).toList();

        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Henüz bu filtreye uygun not yok. Yeni not paylaşabilirsin.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          );
        }

        return Column(
          children: List.generate(docs.length, (index) {
            final data = docs[index].data();
            final title = (data['title'] as String?)?.trim() ?? 'Başlıksız';
            final course = (data['course'] as String?)?.trim() ?? '';
            final semester = (data['semester'] as String?)?.trim() ?? '';
            final author = (data['uploaderName'] as String?)?.trim() ?? 'Öğrenci';
            final rating = (data['ratingAvg'] as num?)?.toDouble() ?? 0.0;
            final description = (data['description'] as String?)?.trim();
            final department = (data['department'] as String?)?.trim();
            final fileUrl = (data['fileUrl'] as String?)?.trim();
            final fileName = (data['fileName'] as String?)?.trim();

            final colorLabel = _semesterChipLabel(semester);
            final tagColor = _tagColorForSemester(semester);

            return Padding(
              padding: EdgeInsets.only(bottom: index == docs.length - 1 ? 0 : 12),
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
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
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
                        color: tagColor.withOpacity(0.12),
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
                    const Text(
                      '·',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
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

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'Ana Sayfa',
                isActive: false,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.calendar_today,
                label: 'Etkinlikler',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EventsScreen(),
                    ),
                  );
                },
              ),
              _buildNavItemWithPlus(
                label: 'Profilim',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                icon: Icons.campaign,
                label: 'İlanlar',
                isActive: false,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.menu_book_outlined,
                label: 'Notlar',
                isActive: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isActive ? 50 : 40,
              height: isActive ? 50 : 40,
              decoration: isActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5A7FCF).withOpacity(0.2),
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF1E3A8A) : const Color(0xFF666666),
                size: isActive ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color:
                    isActive ? const Color(0xFF1E3A8A) : const Color(0xFF666666),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithPlus({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5A7FCF).withOpacity(0.2),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF1E3A8A),
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
