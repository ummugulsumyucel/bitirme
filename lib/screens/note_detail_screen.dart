import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/web_file_opener.dart';
import '../services/session_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final String? noteId;
  final String title;
  final String author;
  final String course;
  final double rating;
  final String colorLabel;
  final Color tagColor;
  final String? description;
  final String? department;
  final String? semester;
  final String? fileUrl;
  final String? fileName;

  const NoteDetailScreen({
    super.key,
    this.noteId,
    required this.title,
    required this.author,
    required this.course,
    required this.rating,
    required this.colorLabel,
    required this.tagColor,
    this.description,
    this.department,
    this.semester,
    this.fileUrl,
    this.fileName,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  int _userRating = 0;
  bool _ratingSubmitted = false;
  bool _loadingRating = true;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  /// Kullanıcının bu nota daha önce verdiği puanı yükle
  Future<void> _loadUserRating() async {
    final nid = widget.noteId?.trim();
    if (nid == null || nid.isEmpty) {
      setState(() => _loadingRating = false);
      return;
    }
    final uid = await SessionService.ensureUserDocId();
    if (!mounted) return;
    if (uid == null) {
      setState(() => _loadingRating = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('note_ratings')
          .doc('${uid}_$nid')
          .get();
      if (doc.exists && mounted) {
        final prev = (doc.data()?['rating'] as num?)?.toInt() ?? 0;
        setState(() {
          _userRating = prev;
          _ratingSubmitted = prev > 0;
        });
      }
    } catch (e) {
      debugPrint('_loadUserRating: $e');
    } finally {
      if (mounted) setState(() => _loadingRating = false);
    }
  }

  bool get _hasFile =>
      widget.fileUrl != null && widget.fileUrl!.trim().isNotEmpty;

  Future<void> _openFile(BuildContext context) async {
    final url = widget.fileUrl?.trim();
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu not için dosya bağlantısı yok.')),
      );
      return;
    }

    // Loading göster
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Dosya açılıyor...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      await openFileInBrowser(url, fileName: widget.fileName);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dosya açılamadı: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    final url = widget.fileUrl?.trim();
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu not için dosya bağlantısı yok.')),
      );
      return;
    }

    // Loading göster
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Dosya indiriliyor...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      await downloadFileInBrowser(url, fileName: widget.fileName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dosya başarıyla indirildi ve açıldı!'),
          backgroundColor: Color(0xFF5A7FCF),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'İndirme başarısız: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitRating(int stars) async {
    final nid = widget.noteId?.trim();
    if (nid == null || nid.isEmpty) return;

    final uid = await SessionService.ensureUserDocId();
    if (!mounted) return;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puan vermek için giriş yapmalısınız.')),
      );
      return;
    }

    setState(() {
      _userRating = stars;
      _ratingSubmitted = true;
    });

    try {
      // Kullanıcının önceki puanını kontrol et
      final ratingRef = FirebaseFirestore.instance
          .collection('note_ratings')
          .doc('${uid}_$nid');
      final existing = await ratingRef.get();

      await ratingRef.set({
        'userDocId': uid,
        'noteId': nid,
        'rating': stars,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Notun ortalama puanını güncelle (transaction ile)
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final noteRef = FirebaseFirestore.instance.collection('notes').doc(nid);
        final noteSnap = await tx.get(noteRef);
        if (!noteSnap.exists) return;

        final data = noteSnap.data()!;
        final oldAvg = (data['ratingAvg'] as num?)?.toDouble() ?? 0.0;
        final oldCount = (data['ratingCount'] as num?)?.toInt() ?? 0;

        double newAvg;
        int newCount;

        if (existing.exists) {
          // Önceki puanı güncelle
          final oldRating =
              (existing.data()?['rating'] as num?)?.toDouble() ?? 0.0;
          final totalScore = oldAvg * oldCount - oldRating + stars;
          newCount = oldCount;
          newAvg = newCount > 0 ? totalScore / newCount : stars.toDouble();
        } else {
          // Yeni puan ekle
          newCount = oldCount + 1;
          newAvg = (oldAvg * oldCount + stars) / newCount;
        }

        tx.update(noteRef, {
          'ratingAvg': double.parse(newAvg.toStringAsFixed(1)),
          'ratingCount': newCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$stars yıldız verdiniz! Teşekkürler 🌟'),
          backgroundColor: const Color(0xFF5A7FCF),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Puan verilemedi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Not Detayı'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.tagColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.tagColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.colorLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.tagColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 18,
                        color: Color(0xFFFACC15),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    context,
                    Icons.person_outline,
                    'Yazar',
                    widget.author,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoCard(
                    context,
                    Icons.menu_book_outlined,
                    'Ders',
                    widget.course,
                  ),
                  if (widget.department != null &&
                      widget.department!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      context,
                      Icons.school_outlined,
                      'Bölüm',
                      widget.department!,
                    ),
                  ],
                  if (widget.semester != null &&
                      widget.semester!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      context,
                      Icons.calendar_today_outlined,
                      'Sınıf / Dönem',
                      widget.semester!,
                    ),
                  ],

                  const SizedBox(height: 24),

                  Text(
                    'Not İçeriği',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.description != null &&
                                  widget.description!.trim().isNotEmpty)
                              ? widget.description!.trim()
                              : 'Bu not için henüz metin özeti yok. Eklenen PDF veya görseli aşağıdan açabilirsin.',
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        if (widget.fileName != null &&
                            widget.fileName!.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 18,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.fileName!.trim(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dosya butonları
                  if (_hasFile) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text(
                          'Dosyayı Görüntüle',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _openFile(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: scheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: Icon(
                          Icons.download_outlined,
                          color: scheme.primary,
                        ),
                        label: Text(
                          'İndir',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                        onPressed: () => _downloadFile(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: scheme.onSurfaceVariant,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Bu nota dosya eklenmemiş.',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Puan ver
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _ratingSubmitted
                            ? const Color(0xFFFACC15).withValues(alpha: 0.5)
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _ratingSubmitted
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 18,
                              color: _ratingSubmitted
                                  ? const Color(0xFFFACC15)
                                  : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _ratingSubmitted
                                  ? 'Puanınız: $_userRating / 5'
                                  : 'Bu notu puanla',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            if (_ratingSubmitted) ...[
                              const Spacer(),
                              TextButton(
                                onPressed: _loadingRating
                                    ? null
                                    : () => setState(() {
                                        _ratingSubmitted = false;
                                        _userRating = 0;
                                      }),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Değiştir',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_loadingRating)
                          const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          Row(
                            children: List.generate(5, (i) {
                              final star = i + 1;
                              return GestureDetector(
                                onTap: _ratingSubmitted
                                    ? null
                                    : () => _submitRating(star),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    star <= _userRating
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: star <= _userRating
                                        ? const Color(0xFFFACC15)
                                        : scheme.outlineVariant,
                                    size: 36,
                                  ),
                                ),
                              );
                            }),
                          ),
                        if (!_ratingSubmitted) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Yıldıza dokunarak puan ver',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Kaydet butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A7FCF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.bookmark_outline),
                      label: const Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        final nid = widget.noteId?.trim();
                        if (nid == null || nid.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bu not için kayıt kimliği yok.'),
                            ),
                          );
                          return;
                        }
                        final uid = await SessionService.ensureUserDocId();
                        if (!context.mounted) return;
                        if (uid == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Kaydetmek için giriş yapmalısınız.',
                              ),
                            ),
                          );
                          return;
                        }
                        try {
                          await FirebaseFirestore.instance
                              .collection('saved_notes')
                              .doc('${uid}_$nid')
                              .set({
                                'userDocId': uid,
                                'noteId': nid,
                                'noteTitle': widget.title,
                                'course': widget.course,
                                'savedAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Not profiline kaydedildi.'),
                              backgroundColor: Color(0xFF5A7FCF),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData iconData,
    String label,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
