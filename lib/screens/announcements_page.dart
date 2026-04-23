import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import 'login_page.dart';
import 'new_listing_screen.dart';

class AnnouncementsPage extends StatefulWidget {
  final VoidCallback onToggleDarkMode;
  final bool isDarkMode;
  final bool embeddedInShell;

  const AnnouncementsPage({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    this.embeddedInShell = false,
  });

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedTime;

  void _filterAnnouncements() {
    setState(() {});
  }

  Announcement _announcementFromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> d,
  ) {
    final data = d.data();
    final ts = data['createdAt'];
    DateTime date = DateTime.now();
    if (ts is Timestamp) date = ts.toDate();

    // listings koleksiyonu için uyarlanmış veri çekme
    final title = (data['title'] as String?)?.trim() ?? 'Başlıksız';
    final location = (data['location'] as String?)?.trim() ?? '';
    final type = (data['type'] as String?)?.trim() ?? '';
    final category = (data['category'] as String?)?.trim() ?? '';

    // İkon ve renk belirleme (type'a göre)
    IconData icon;
    Color iconColor;

    if (type == 'Kayıp Eşya') {
      icon = Icons.search;
      iconColor = const Color(0xFFE53935);
    } else if (type == 'Bulunan Eşya') {
      icon = Icons.check_circle;
      iconColor = const Color(0xFF43A047);
    } else {
      icon = Icons.campaign;
      iconColor = const Color(0xFF5A7FCF);
    }

    return Announcement(
      id: d.id,
      title: title,
      author: type,
      location: location,
      date: date,
      category: category,
      icon: icon,
      iconColor: iconColor,
      imageUrl: (data['imageUrl'] as String?)?.trim(),
      description: (data['description'] as String?)?.trim(),
    );
  }

  bool _announcementMatchesFilter(Announcement announcement) {
    final matchesSearch =
        _searchController.text.isEmpty ||
        announcement.title.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        ) ||
        announcement.author.toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );
    final matchesCategory =
        _selectedCategory == null || announcement.category == _selectedCategory;
    final matchesTime =
        _selectedTime == null ||
        (announcement.date.year == _selectedTime!.year &&
            announcement.date.month == _selectedTime!.month &&
            announcement.date.day == _selectedTime!.day);
    return matchesSearch && matchesCategory && matchesTime;
  }

  Widget _buildAnnouncementsList(ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('listings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'İlanlar yüklenemedi: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs =
            snapshot.data?.docs ??
            <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        final sorted =
            List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(docs)
              ..sort((a, b) {
                final ta = a.data()['createdAt'];
                final tb = b.data()['createdAt'];
                final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
                final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
                return mb.compareTo(ma);
              });
        final items = sorted
            .map(_announcementFromDoc)
            .where(_announcementMatchesFilter)
            .toList();

        if (items.isEmpty) {
          return Center(
            child: Text(
              'İlan bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildAnnouncementCard(items[index]);
          },
        );
      },
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kategori Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryOption('Tümü', null),
            _buildCategoryOption('Genel', 'Genel'),
            _buildCategoryOption('Elektronik', 'Elektronik'),
            _buildCategoryOption('Kimlik / Kart', 'Kimlik / Kart'),
            _buildCategoryOption('Kitap / Defter', 'Kitap / Defter'),
            _buildCategoryOption('Anahtar', 'Anahtar'),
            _buildCategoryOption('Diğer', 'Diğer'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(String label, String? value) {
    return ListTile(
      title: Text(label),
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
        Navigator.pop(context);
        _filterAnnouncements();
      },
      trailing: _selectedCategory == value ? const Icon(Icons.check) : null,
    );
  }

  Future<void> _selectTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026, 12, 31),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _filterAnnouncements();
    }
  }

  void _navigateToAddAnnouncement() async {
    if (!AuthService().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => NewListingScreen(
          onToggleTheme: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final list = _buildAnnouncementsList(Theme.of(context));

    if (widget.embeddedInShell) {
      return ColoredBox(
        color: scheme.surface,
        child: Column(
          children: [
            _buildSearchAndFilterSection(context),
            Expanded(child: list),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilterSection(context),
            Expanded(child: list),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'UniConnect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: widget.onToggleDarkMode,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fieldFill = scheme.surfaceContainerLow;
    final borderColor = scheme.outlineVariant;

    return Container(
      width: double.infinity,
      color: scheme.primaryContainer.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showCategoryDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: fieldFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Kategori Seç',
                          style: TextStyle(color: scheme.onSurface),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_drop_down,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: fieldFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _selectedTime == null
                                ? 'Zaman'
                                : DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedTime!),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'İlan ara…',
                    filled: true,
                    fillColor: fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    _filterAnnouncements();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _filterAnnouncements();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A7FCF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Ara'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (AuthService().isLoggedIn)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddAnnouncement,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'İlan Ekle',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A7FCF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'İlan Ekle',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A7FCF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');
    final hasImage =
        announcement.imageUrl != null && announcement.imageUrl!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim alanı
          if (hasImage)
            _buildImageBanner(announcement.imageUrl!)
          else
            _buildNoImageBanner(announcement.iconColor),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      announcement.icon,
                      color: announcement.iconColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      announcement.author,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: announcement.iconColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: announcement.iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        announcement.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: announcement.iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (announcement.description != null &&
                    announcement.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    announcement.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        announcement.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(announcement.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showDetails(announcement),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF5A7FCF)),
                      foregroundColor: const Color(0xFF5A7FCF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Detayları Gör'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBanner(String imageUrl) {
    // base64 data URL
    if (imageUrl.startsWith('data:image/')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        if (commaIndex != -1) {
          final base64Data = imageUrl.substring(commaIndex + 1);
          final bytes = base64Decode(base64Data);
          return SizedBox(
            height: 180,
            width: double.infinity,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _buildNoImageBanner(const Color(0xFF5A7FCF)),
            ),
          );
        }
      } catch (_) {}
    }
    // https URL
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _buildNoImageBanner(const Color(0xFF5A7FCF)),
      ),
    );
  }

  Widget _buildNoImageBanner(Color color) {
    return Container(
      height: 80,
      width: double.infinity,
      color: color.withValues(alpha: 0.08),
      child: Icon(
        Icons.campaign_outlined,
        size: 36,
        color: color.withValues(alpha: 0.4),
      ),
    );
  }

  void _showDetails(Announcement announcement) {
    final hasImage =
        announcement.imageUrl != null && announcement.imageUrl!.isNotEmpty;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: _buildImageBanner(announcement.imageUrl!),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          announcement.icon,
                          size: 20,
                          color: announcement.iconColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          announcement.author,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: announcement.iconColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (announcement.description != null &&
                        announcement.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        announcement.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          announcement.category,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            announcement.location,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat(
                            'd MMMM yyyy',
                            'tr_TR',
                          ).format(announcement.date),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.school, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  'UniConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Etkinlikler'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profilim'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('İlanlar'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notlar'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            title: Text(widget.isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
            onTap: () {
              widget.onToggleDarkMode();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Announcement {
  final String id;
  final String title;
  final String author;
  final String location;
  final DateTime date;
  final String category;
  final IconData icon;
  final Color iconColor;
  final String? imageUrl;
  final String? description;

  Announcement({
    required this.id,
    required this.title,
    required this.author,
    required this.location,
    required this.date,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.imageUrl,
    this.description,
  });
}
