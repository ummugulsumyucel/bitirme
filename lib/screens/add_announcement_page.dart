import 'package:flutter/material.dart';
import 'announcements_page.dart';

class AddAnnouncementPage extends StatefulWidget {
  const AddAnnouncementPage({super.key});

  @override
  State<AddAnnouncementPage> createState() => _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends State<AddAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLocation;
  IconData _selectedIcon = Icons.business_center;
  Color _selectedIconColor = Colors.brown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Ekle'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'İlan Başlığı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen başlık girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Adınız',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'Kayıp Eşya', child: Text('Kayıp Eşya')),
                  DropdownMenuItem(value: 'Buluntu', child: Text('Buluntu')),
                  DropdownMenuItem(value: 'Satılık', child: Text('Satılık')),
                  DropdownMenuItem(value: 'Kiralık', child: Text('Kiralık')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    if (value == 'Kayıp Eşya') {
                      _selectedIcon = Icons.search;
                      _selectedIconColor = Colors.blue;
                    } else if (value == 'Buluntu') {
                      _selectedIcon = Icons.business_center;
                      _selectedIconColor = Colors.brown;
                    } else if (value == 'Satılık') {
                      _selectedIcon = Icons.shopping_cart;
                      _selectedIconColor = Colors.green;
                    } else if (value == 'Kiralık') {
                      _selectedIcon = Icons.home;
                      _selectedIconColor = Colors.orange;
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Lütfen kategori seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: 'Konum',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: const [
                  DropdownMenuItem(value: 'Kütüphane - 1. Kat', child: Text('Kütüphane - 1. Kat')),
                  DropdownMenuItem(value: 'Kütüphane - 2. Kat', child: Text('Kütüphane - 2. Kat')),
                  DropdownMenuItem(value: 'Kantin Bölgesi', child: Text('Kantin Bölgesi')),
                  DropdownMenuItem(value: 'Amfi 1', child: Text('Amfi 1')),
                  DropdownMenuItem(value: 'Amfi 2', child: Text('Amfi 2')),
                  DropdownMenuItem(value: 'Amfi 3 - Giriş', child: Text('Amfi 3 - Giriş')),
                  DropdownMenuItem(value: 'Yurt - A Blok', child: Text('Yurt - A Blok')),
                  DropdownMenuItem(value: 'Yurt - B Blok', child: Text('Yurt - B Blok')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Lütfen konum seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final announcement = Announcement(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      author: _authorController.text,
                      location: _selectedLocation!,
                      date: DateTime.now(),
                      category: _selectedCategory!,
                      icon: _selectedIcon,
                      iconColor: _selectedIconColor,
                    );
                    Navigator.pop(context, announcement);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A7FCF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('İlan Ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
}
