import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/session_service.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isDeleting = false;

  Future<void> _deleteListing() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text(
          'Bu ilanı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // true = silindi
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _editListing(Map<String, dynamic> listingData) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditListingScreen(
          listingId: widget.listingId,
          listingData: listingData,
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {}); // Refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('listings')
            .doc(widget.listingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Hata: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('İlan bulunamadı'));
          }

          final data = snapshot.data!.data()!;
          final ownerUserDocId = data['ownerUserDocId'] as String?;

          return FutureBuilder<String?>(
            future: SessionService.getUserDocId(),
            builder: (context, userSnapshot) {
              final currentUserDocId = userSnapshot.data;
              final isOwner =
                  currentUserDocId != null &&
                  ownerUserDocId != null &&
                  currentUserDocId == ownerUserDocId;

              return _buildContent(data, isOwner);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data, bool isOwner) {
    final scheme = Theme.of(context).colorScheme;

    final title = (data['title'] as String?)?.trim() ?? 'Başlıksız';
    final description = (data['description'] as String?)?.trim() ?? '';
    final location = (data['location'] as String?)?.trim() ?? '';
    final type = (data['type'] as String?)?.trim() ?? '';
    final category = (data['category'] as String?)?.trim() ?? '';

    // Çoklu resim desteği - yeni ve eski veri yapısı
    final imageUrls =
        (data['imageUrls'] as List<dynamic>?)
            ?.map((e) => e.toString().trim())
            .where((url) => url.isNotEmpty)
            .toList() ??
        [];

    // Geriye uyumluluk: eski tek resim varsa onu kullan
    if (imageUrls.isEmpty) {
      final singleImageUrl = (data['imageUrl'] as String?)?.trim();
      if (singleImageUrl != null && singleImageUrl.isNotEmpty) {
        imageUrls.add(singleImageUrl);
      }
    }

    final hasImages = imageUrls.isNotEmpty;

    final ts = data['createdAt'];
    DateTime date = DateTime.now();
    if (ts is Timestamp) date = ts.toDate();

    // İkon ve renk belirleme
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim Galerisi veya Placeholder
          if (hasImages)
            _ImageGallery(imageUrls: imageUrls, iconColor: iconColor)
          else
            Container(
              height: 120,
              width: double.infinity,
              color: iconColor.withValues(alpha: 0.08),
              child: Icon(
                icon,
                size: 48,
                color: iconColor.withValues(alpha: 0.4),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tip ve Kategori
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Başlık
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                // Konum
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: 15, color: scheme.onSurface),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Tarih
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('d MMMM yyyy', 'tr_TR').format(date),
                      style: TextStyle(fontSize: 15, color: scheme.onSurface),
                    ),
                  ],
                ),

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Açıklama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],

                // Düzenleme ve Silme Butonları (Sadece sahip görebilir)
                if (isOwner) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'İlan Yönetimi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isDeleting
                              ? null
                              : () => _editListing(data),
                          icon: const Icon(Icons.edit),
                          label: const Text('Düzenle'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: scheme.primary),
                            foregroundColor: scheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDeleting ? null : _deleteListing,
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.delete),
                          label: Text(_isDeleting ? 'Siliniyor...' : 'Sil'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Düzenleme ekranı
class EditListingScreen extends StatefulWidget {
  final String listingId;
  final Map<String, dynamic> listingData;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const EditListingScreen({
    super.key,
    required this.listingId,
    required this.listingData,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  late String _selectedType;
  late String _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.listingData['title'] as String? ?? '',
    );
    _locationController = TextEditingController(
      text: widget.listingData['location'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.listingData['description'] as String? ?? '',
    );
    _selectedType = widget.listingData['type'] as String? ?? 'Kayıp Eşya';
    _selectedCategory = widget.listingData['category'] as String? ?? 'Genel';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateListing() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || location.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(widget.listingId)
          .update({
            'title': title,
            'location': location,
            'description': description,
            'type': _selectedType,
            'category': _selectedCategory,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan başarıyla güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // true = güncellendi
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('İlanı Düzenle'),
        backgroundColor: scheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                'İlan Bilgilerini Düzenle',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Tip Seçici
              _buildTypeSelector(),
              const SizedBox(height: 16),

              // Başlık
              _buildLabeledField(
                label: 'İlan Başlığı',
                child: TextField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    hintText: 'Örn: Kütüphanede Kayıp Cüzdan Bulundu',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kategori
              _buildLabeledField(
                label: 'Kategori Seç',
                child: _buildCategoryDropdown(),
              ),
              const SizedBox(height: 16),

              // Konum
              _buildLabeledField(
                label: 'Konum',
                child: TextField(
                  controller: _locationController,
                  decoration: _inputDecoration(
                    hintText: 'Örn: Kütüphane - 2. Kat',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Açıklama
              _buildLabeledField(
                label: 'Açıklama',
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _inputDecoration(
                    hintText:
                        'Eşyanın rengi, markası, bulunma/kaybolma zamanı gibi detayları yaz.',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Güncelle Butonu
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
                  onPressed: _isSubmitting ? null : _updateListing,
                  child: Text(
                    _isSubmitting
                        ? 'Güncelleniyor...'
                        : 'Değişiklikleri Kaydet',
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
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildChip('Kayıp Eşya'),
        const SizedBox(width: 8),
        _buildChip('Bulunan Eşya'),
      ],
    );
  }

  Widget _buildChip(String value) {
    final scheme = Theme.of(context).colorScheme;
    final bool isSelected = _selectedType == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : scheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final scheme = Theme.of(context).colorScheme;
    final categories = <String>[
      'Genel',
      'Elektronik',
      'Kimlik / Kart',
      'Kitap / Defter',
      'Anahtar',
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
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: scheme.onSurface,
          ),
          items: categories
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(fontSize: 14, color: scheme.onSurface),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedCategory = value);
          },
        ),
      ),
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
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 13,
      ),
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
}

/// Resim galerisi widget'ı - çoklu resim gösterimi
class _ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final Color iconColor;

  const _ImageGallery({required this.imageUrls, required this.iconColor});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          // Resim PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Tam ekran resim gösterimi
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _FullScreenImage(
                        imageUrls: widget.imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: widget.iconColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 64,
                      color: widget.iconColor.withValues(alpha: 0.4),
                    ),
                  ),
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Resim sayısı göstergesi (sağ üst)
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentIndex + 1}/${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Sayfa göstergeleri (alt orta)
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          // Ok tuşları (çoklu resim varsa)
          if (widget.imageUrls.length > 1) ...[
            // Sol ok
            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

            // Sağ ok
            if (_currentIndex < widget.imageUrls.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Tam ekran resim görüntüleme
class _FullScreenImage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenImage({required this.imageUrls, required this.initialIndex});

  @override
  State<_FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<_FullScreenImage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.imageUrls.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
