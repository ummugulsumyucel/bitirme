import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_announcement_page.dart';
import 'login_page.dart';
import '../services/auth_service.dart';

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
  List<Announcement> _announcements = [];
  List<Announcement> _filteredAnnouncements = [];

  @override
  void initState() {
    super.initState();
    _initializeAnnouncements();
  }

  void _initializeAnnouncements() {
    _announcements = [
      Announcement(
        id: '1',
        title: 'Kütüphanede Kayıp Cüzdan Bulundu',
        author: 'Mehmet Kaya',
        location: 'Kütüphane - 2. Kat',
        date: DateTime(2023, 12, 21),
        category: 'Buluntu',
        icon: Icons.business_center,
        iconColor: Colors.brown,
      ),
      Announcement(
        id: '2',
        title: 'Kayıp Telefon Aranıyor',
        author: 'Ayşe Demir',
        location: 'Kantin Bölgesi',
        date: DateTime(2023, 12, 19),
        category: 'Kayıp Eşya',
        icon: Icons.phone_android,
        iconColor: Colors.purple,
      ),
      Announcement(
        id: '3',
        title: 'Anahtar Takımı Bulundu',
        author: 'Ali Yılmaz',
        location: 'Amfi 3 - Giriş',
        date: DateTime(2023, 12, 18),
        category: 'Buluntu',
        icon: Icons.vpn_key,
        iconColor: Colors.amber,
      ),
    ];
    _filteredAnnouncements = _announcements;
  }

  void _filterAnnouncements() {
    setState(() {
      _filteredAnnouncements = _announcements.where((announcement) {
        final matchesSearch = _searchController.text.isEmpty ||
            announcement.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            announcement.author.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == null || announcement.category == _selectedCategory;
        final matchesTime = _selectedTime == null ||
            (announcement.date.year == _selectedTime!.year &&
                announcement.date.month == _selectedTime!.month &&
                announcement.date.day == _selectedTime!.day);
        return matchesSearch && matchesCategory && matchesTime;
      }).toList();
    });
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
            _buildCategoryOption('Kayıp Eşya', 'Kayıp Eşya'),
            _buildCategoryOption('Buluntu', 'Buluntu'),
            _buildCategoryOption('Satılık', 'Satılık'),
            _buildCategoryOption('Kiralık', 'Kiralık'),
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
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAnnouncementPage(),
      ),
    );
    if (result != null && result is Announcement) {
      setState(() {
        _announcements.add(result);
        _filterAnnouncements();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final list = _filteredAnnouncements.isEmpty
        ? Center(
            child: Text(
              'İlan bulunamadı',
              style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredAnnouncements.length,
            itemBuilder: (context, index) {
              return _buildAnnouncementCard(_filteredAnnouncements[index]);
            },
          );

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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                        Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                : DateFormat('dd/MM/yyyy').format(_selectedTime!),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
    final dateFormat = DateFormat('d MMMM yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(announcement.icon, color: const Color(0xFF1E3A8A)),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(announcement.author),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(announcement.location),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(dateFormat.format(announcement.date)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showDetails(announcement);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5A7FCF)),
                  foregroundColor: const Color(0xFF5A7FCF),
                ),
                child: const Text('Detayları Gör'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 8),
                Text(announcement.author),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 8),
                Text(announcement.location),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(DateFormat('d MMMM yyyy').format(announcement.date)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 8),
                Text(announcement.category),
              ],
            ),
          ],
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
            decoration: BoxDecoration(
              color: Color(0xFF1E3A8A),
            ),
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
            leading: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
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

  Announcement({
    required this.id,
    required this.title,
    required this.author,
    required this.location,
    required this.date,
    required this.category,
    required this.icon,
    required this.iconColor,
  });
}
