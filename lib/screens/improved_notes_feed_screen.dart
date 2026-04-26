import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/pagination_helper.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/search_widget.dart';
import '../widgets/common_drawer.dart';
import 'calendar_page.dart';
import 'events_screen.dart';
import 'login_page.dart';
import 'main_shell.dart';
import 'new_note_screen.dart';
import 'note_detail_screen.dart';
import 'profile_screen.dart';
import 'register_page.dart';

class Note {
  final String id;
  final String title;
  final String course;
  final String description;
  final String department;
  final String semester;
  final String type;
  final String uploaderName;
  final String? uploaderUserDocId;
  final String? fileUrl;
  final String? fileName;
  final String? fileMimeType;
  final double ratingAvg;
  final int ratingCount;
  final int downloadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.course,
    required this.description,
    required this.department,
    required this.semester,
    required this.type,
    required this.uploaderName,
    this.uploaderUserDocId,
    this.fileUrl,
    this.fileName,
    this.fileMimeType,
    required this.ratingAvg,
    required this.ratingCount,
    required this.downloadCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromFirestore(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      title: (data['title'] as String?)?.trim() ?? '',
      course: (data['course'] as String?)?.trim() ?? '',
      description: (data['description'] as String?)?.trim() ?? '',
      department: (data['department'] as String?)?.trim() ?? '',
      semester: (data['semester'] as String?)?.trim() ?? '',
      type: (data['type'] as String?)?.trim() ?? '',
      uploaderName: (data['uploaderName'] as String?)?.trim() ?? 'Öğrenci',
      uploaderUserDocId: data['uploaderUserDocId'] as String?,
      fileUrl: data['fileUrl'] as String?,
      fileName: data['fileName'] as String?,
      fileMimeType: data['fileMimeType'] as String?,
      ratingAvg: (data['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      downloadCount: (data['downloadCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  String get searchableText {
    return [
      title,
      course,
      description,
      department,
      type,
      uploaderName,
    ].join(' ').toLowerCase();
  }
}

class ImprovedNotesFeedScreen extends StatefulWidget {
  final bool embeddedInShell;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const ImprovedNotesFeedScreen({
    super.key,
    this.embeddedInShell = false,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<ImprovedNotesFeedScreen> createState() =>
      _ImprovedNotesFeedScreenState();
}

class _ImprovedNotesFeedScreenState extends State<ImprovedNotesFeedScreen> {
  late PaginationHelper<Note> _paginationHelper;
  String _searchQuery = '';
  String _semesterFilter = 'Tümü';
  String _typeFilter = 'Tümü';
  String _sortBy = 'Tarih (Yeni)';
  bool _isInitialized = false;

  static const List<String> _semesterOptions = [
    'Tümü',
    'Hazırlık',
    '1. Sınıf',
    '2. Sınıf',
    '3. Sınıf',
    '4. Sınıf',
  ];

  static const List<String> _typeOptions = [
    'Tümü',
    'Ders Notu',
    'Soru Çözümü',
    'Özet / Slayt',
  ];

  static const List<String> _sortOptions = [
    'Tarih (Yeni)',
    'Tarih (Eski)',
    'Puan (Yüksek)',
    'Puan (Düşük)',
    'İndirme (Çok)',
    'İndirme (Az)',
  ];

  @override
  void initState() {
    super.initState();
    _initializePagination();
  }

  void _initializePagination() {
    _paginationHelper = PaginationHelper<Note>(
      collection: 'notes',
      orderByField: 'createdAt',
      descending: true,
      pageSize: 10,
      fromMap: Note.fromFirestore,
      customQuery: _buildQuery,
    );
    _isInitialized = true;
  }

  Query<Map<String, dynamic>>? _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection(
      'notes',
    );

    // Semester filter
    if (_semesterFilter != 'Tümü') {
      query = query.where('semester', isEqualTo: _semesterFilter);
    }

    // Type filter
    if (_typeFilter != 'Tümü') {
      query = query.where('type', isEqualTo: _typeFilter);
    }

    // Sorting
    switch (_sortBy) {
      case 'Tarih (Yeni)':
        query = query.orderBy('createdAt', descending: true);
        break;
      case 'Tarih (Eski)':
        query = query.orderBy('createdAt', descending: false);
        break;
      case 'Puan (Yüksek)':
        query = query.orderBy('ratingAvg', descending: true);
        break;
      case 'Puan (Düşük)':
        query = query.orderBy('ratingAvg', descending: false);
        break;
      case 'İndirme (Çok)':
        query = query.orderBy('downloadCount', descending: true);
        break;
      case 'İndirme (Az)':
        query = query.orderBy('downloadCount', descending: false);
        break;
    }

    return query;
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_searchQuery.isEmpty) return notes;

    return notes.where((note) {
      return note.searchableText.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _refreshNotes() async {
    await _paginationHelper.refresh();
    if (mounted) setState(() {});
  }

  void _onFilterChanged() {
    _paginationHelper.clear();
    _initializePagination();
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final content = Column(
      children: [
        _buildFiltersSection(),
        Expanded(
          child: _isInitialized ? _buildNotesList() : const LoadingWidget(),
        ),
      ],
    );

    if (widget.embeddedInShell) {
      return ColoredBox(color: scheme.surface, child: content);
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      drawer: CommonDrawer(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
        selectedPage: 'notes',
      ),
      appBar: AppBar(
        title: const Text('Notlar'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: content,
      floatingActionButton: _buildAddNoteFab(),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          SearchWidget(
            hintText: 'Not ara... (başlık, ders, açıklama)',
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          const SizedBox(height: 16),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterDropdown(
                  'Dönem',
                  _semesterFilter,
                  _semesterOptions,
                  (value) {
                    setState(() {
                      _semesterFilter = value;
                    });
                    _onFilterChanged();
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterDropdown('Tür', _typeFilter, _typeOptions, (value) {
                  setState(() {
                    _typeFilter = value;
                  });
                  _onFilterChanged();
                }),
                const SizedBox(width: 8),
                _buildFilterDropdown('Sırala', _sortBy, _sortOptions, (value) {
                  setState(() {
                    _sortBy = value;
                  });
                  _onFilterChanged();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text('$label: $option'),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    return PaginatedListView<Note>(
      paginationHelper: _paginationHelper,
      onRefresh: _refreshNotes,
      itemBuilder: (context, note, index) {
        final filteredNotes = _filterNotes(_paginationHelper.items);
        if (!filteredNotes.contains(note)) {
          return const SizedBox.shrink();
        }
        return _buildNoteCard(note);
      },
      loadingWidget: const LoadingWidget(message: 'Notlar yükleniyor...'),
      errorWidget: ErrorDisplayWidget(
        message: 'Notlar yüklenirken hata oluştu',
        onRetry: _refreshNotes,
      ),
      emptyWidget: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64),
            SizedBox(height: 16),
            Text('Henüz not paylaşılmamış', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('İlk notu sen paylaş!', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final scheme = Theme.of(context).colorScheme;
    final tagColor = _getTagColor(note.semester);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openNoteDetail(note),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File preview section
            if (note.fileUrl != null) _buildFilePreview(note),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note.semester.isEmpty ? 'NOT' : note.semester,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: tagColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          note.type,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            note.ratingAvg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${note.ratingCount})',
                            style: TextStyle(
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Course and author
                  Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          note.course,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        note.uploaderName,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (note.description.isNotEmpty)
                    Text(
                      note.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${note.downloadCount} indirme',
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      if (note.createdAt != null)
                        Text(
                          _formatDate(note.createdAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(Note note) {
    final scheme = Theme.of(context).colorScheme;

    if (note.fileMimeType?.startsWith('image/') == true) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Image.network(
            note.fileUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return ShimmerLoading(
                isLoading: true,
                child: Container(color: scheme.surfaceVariant),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: scheme.errorContainer,
                child: Icon(
                  Icons.broken_image,
                  color: scheme.onErrorContainer,
                  size: 32,
                ),
              );
            },
          ),
        ),
      );
    }

    // For non-image files, show file info
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            note.fileMimeType == 'application/pdf'
                ? Icons.picture_as_pdf
                : Icons.insert_drive_file,
            color: scheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              note.fileName ?? 'Dosya',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Color _getTagColor(String semester) {
    switch (semester) {
      case 'Hazırlık':
        return Colors.purple;
      case '1. Sınıf':
        return Colors.green;
      case '2. Sınıf':
        return Colors.blue;
      case '3. Sınıf':
        return Colors.orange;
      case '4. Sınıf':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _openNoteDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          noteId: note.id,
          title: note.title,
          author: note.uploaderName,
          course: note.course,
          rating: note.ratingAvg,
          colorLabel: note.semester,
          tagColor: _getTagColor(note.semester),
          description: note.description,
          department: note.department,
          semester: note.semester,
          fileUrl: note.fileUrl,
          fileName: note.fileName,
        ),
      ),
    );
  }

  Widget _buildAddNoteFab() {
    final authService = AuthService();

    return FloatingActionButton.extended(
      onPressed: () {
        if (!authService.isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not paylaşmak için giriş yapmalısınız'),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewNoteScreen(
              onToggleTheme: widget.onToggleTheme,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Not Paylaş'),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.school, color: scheme.onPrimary, size: 48),
                const SizedBox(height: 8),
                Text(
                  'UniConnect',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUserName ?? 'Kullanıcı',
                    style: TextStyle(
                      color: scheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                    ),
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
            leading: const Icon(Icons.note),
            title: const Text('Notlar'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          // Add other menu items...
        ],
      ),
    );
  }
}
