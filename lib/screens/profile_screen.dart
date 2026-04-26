import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_photo_service.dart';
import '../services/session_service.dart';
import 'edit_profile_screen.dart';
import 'login_page.dart';
import 'new_listing_screen.dart';
import 'new_note_screen.dart';
import 'notes_feed_screen.dart';
import 'register_page.dart';
import 'suggestion_complaint_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool embeddedInShell;
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    this.embeddedInShell = false,
    this.onToggleTheme,
    this.isDarkMode = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userDocId;
  bool _loadingSession = true;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Kullanıcı giriş durumunu kontrol et ve gerekli verileri yükle
    if (AuthService().isLoggedIn) {
      _bootstrap();
    } else {
      _loadingSession = false;
    }
  }

  Future<void> _bootstrap() async {
    setState(() => _loadingSession = true);
    String? id;
    try {
      id = await SessionService.getUserDocId();
    } catch (e, st) {
      debugPrint('ProfileScreen._bootstrap: $e\n$st');
      id = null;
    }
    if (!mounted) return;
    setState(() {
      _userDocId = id;
      _loadingSession = false;
    });
  }

  Future<void> _openEditProfile() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (changed == true && mounted) {
      await _bootstrap();
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final uid = _userDocId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce profil bilgilerini kaydet.')),
      );
      return;
    }

    if (kIsWeb) {
      // Web'de FilePicker kullan
      setState(() => _uploadingPhoto = true);
      try {
        final file = await pickProfileImageWeb();
        if (file == null || !mounted) {
          setState(() => _uploadingPhoto = false);
          return;
        }
        final url = await uploadProfilePhoto(uid, file);
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'photoUrl': url,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı güncellendi.'),
              backgroundColor: Color(0xFF5A7FCF),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Yükleme başarısız: $e')));
        }
      } finally {
        if (mounted) setState(() => _uploadingPhoto = false);
      }
      return;
    }

    // Mobil: ImagePicker ile kaynak seç
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeriden seç'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera ile çek'),
              onTap: () => Navigator.pop(ctx, 'camera'),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      // Mobil'de image_picker kullan
      // ignore: depend_on_referenced_packages
      final picker = _MobileImagePicker();
      final file = await picker.pick(source);
      if (file == null || !mounted) {
        setState(() => _uploadingPhoto = false);
        return;
      }
      final url = await uploadProfilePhoto(uid, file);
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': url,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı güncellendi.'),
            backgroundColor: Color(0xFF5A7FCF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Yükleme başarısız: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Widget _buildAuthRequiredGate(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: scheme.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: 20),
              Text(
                'Profil ve kişisel alan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'İlanlarını, notlarını ve etkinlik özetini görmek için giriş yap veya yeni hesap oluştur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                    if (!mounted) return;
                    if (AuthService().isLoggedIn) await _bootstrap();
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Giriş Yap'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                    if (!mounted) return;
                    if (AuthService().isLoggedIn) await _bootstrap();
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Kayıt Ol'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService().isLoggedIn) {
      final gate = _buildAuthRequiredGate(context);
      if (widget.embeddedInShell) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox.expand(child: gate),
        );
      }
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Profilim'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: gate,
      );
    }

    final inner = _loadingSession
        ? const Center(child: CircularProgressIndicator())
        : _userDocId == null
        ? _buildSetupPrompt()
        : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_userDocId)
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Profil verisi alınamadı:\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final userData = snap.data?.data() ?? {};
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildProfileCard(userData),
                      const SizedBox(height: 12),
                      _buildPersonalInfoCard(userData),
                      const SizedBox(height: 12),
                      _buildMyEventsSection(_userDocId!),
                      const SizedBox(height: 12),
                      _buildMyPersonalEventsSection(_userDocId!),
                      const SizedBox(height: 12),
                      _buildMyListingsSection(_userDocId!),
                      const SizedBox(height: 12),
                      _buildMyNotesSection(_userDocId!),
                      const SizedBox(height: 12),
                      _buildSavedNotesSection(_userDocId!),
                      const SizedBox(height: 16),
                      _buildPrimaryButton(
                        'Şikayet / Öneri Ekle',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuggestionComplaintScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );

    if (widget.embeddedInShell) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox.expand(child: inner),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: inner,
    );
  }

  Widget _buildSetupPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 64,
              color: Color(0xFF1E3A8A),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profilini oluştur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kişisel bilgilerini kaydet; ilan, not ve etkinliklerin burada görünsün.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A7FCF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _openEditProfile,
                child: const Text('Profil bilgilerini gir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? photoUrl) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      return _avatarPlaceholder();
    }

    // base64 data URL
    if (url.startsWith('data:image/')) {
      try {
        final commaIndex = url.indexOf(',');
        if (commaIndex != -1) {
          final bytes = base64Decode(url.substring(commaIndex + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _avatarPlaceholder(),
          );
        }
      } catch (_) {}
      return _avatarPlaceholder();
    }

    // https URL
    final uri = Uri.tryParse(url);
    final ok =
        uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;

    if (!ok) return _avatarPlaceholder();

    return Image.network(
      uri.toString(),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _avatarPlaceholder(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: const Color(0xFFE8EEF9),
      child: const Icon(Icons.person, size: 48, color: Color(0xFF5A7FCF)),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> userData) {
    final fullName = (userData['fullName'] as String?) ?? 'Öğrenci';
    final role = (userData['role'] as String?) ?? 'Öğrenci';
    final photoUrl = (userData['photoUrl'] as String?)?.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A7FCF), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildProfileAvatar(photoUrl),
                  ),
                ),
              ),
              if (_uploadingPhoto)
                const Positioned.fill(
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Color(0xFF5A7FCF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 16,
                      color: _uploadingPhoto
                          ? Colors.grey
                          : const Color(0xFF1E3A8A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _uploadingPhoto
                          ? 'Yükleniyor...'
                          : 'Profil fotoğrafını düzenle',
                      style: TextStyle(
                        fontSize: 11,
                        color: _uploadingPhoto
                            ? Colors.grey
                            : const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role == 'student' ? 'Öğrenci' : role,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(Map<String, dynamic> userData) {
    final department = (userData['department'] as String?) ?? '—';
    final grade = (userData['grade'] as String?) ?? '—';
    final email = (userData['email'] as String?) ?? '—';

    const labelStyle = TextStyle(fontSize: 12, color: Color(0xFF777777));
    const valueStyle = TextStyle(
      fontSize: 14,
      color: Color(0xFF333333),
      fontWeight: FontWeight.w500,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kişisel Bilgiler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text(
                  'Profilimi Düzenle',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Bölüm', style: labelStyle),
          const SizedBox(height: 2),
          Text(department, style: valueStyle),
          const SizedBox(height: 8),
          const Text('Sınıf', style: labelStyle),
          const SizedBox(height: 2),
          Text(grade, style: valueStyle),
          const SizedBox(height: 8),
          const Text('E-posta', style: labelStyle),
          const SizedBox(height: 2),
          Text(email, style: valueStyle),
        ],
      ),
    );
  }

  Widget _buildMyEventsSection(String userDocId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('event_attendees')
          .where('userDocId', isEqualTo: userDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildSectionCard(
            title: 'Katıldığım Etkinlikler',
            child: Text(
              'Liste yüklenemedi: ${snapshot.error}',
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          );
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final ta = a.data()['joinedAt'];
          final tb = b.data()['joinedAt'];
          final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
          final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });

        final count = docs.length;
        return _buildSectionCard(
          title: 'Katıldığım Etkinlikler',
          trailing: _buildBadge('$count kayıt'),
          child: docs.isEmpty
              ? const Text(
                  'Henüz etkinliğe katılmadın. Etkinlikler sayfasından "Etkinliğe Katıl" ile kayıt ol.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                )
              : Column(
                  children: List.generate(docs.length, (i) {
                    final d = docs[i].data();
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: i < docs.length - 1 ? 8 : 0,
                      ),
                      child: _buildEventItem(
                        title: (d['title'] as String?) ?? 'Etkinlik',
                        subtitle: (d['subtitle'] as String?) ?? '',
                        date:
                            _formatTs(d['joinedAt']) ??
                            (d['dateDisplay'] as String?) ??
                            '',
                      ),
                    );
                  }),
                ),
        );
      },
    );
  }

  String? _formatTs(dynamic v) {
    if (v is Timestamp) {
      final dt = v.toDate();
      return '${dt.day}.${dt.month}.${dt.year}';
    }
    return null;
  }

  Widget _buildMyPersonalEventsSection(String userDocId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('personal_events')
          .where('userId', isEqualTo: userDocId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = [...(snapshot.data?.docs ?? [])];
        if (docs.isEmpty) return const SizedBox.shrink();
        docs.sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
          final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });
        return _buildSectionCard(
          title: 'Kişisel Etkinliklerim',
          trailing: _buildBadge('${docs.length} kayıt'),
          child: Column(
            children: List.generate(docs.length, (i) {
              final d = docs[i].data();
              return Padding(
                padding: EdgeInsets.only(bottom: i < docs.length - 1 ? 8 : 0),
                child: _buildEventItem(
                  title: (d['title'] as String?) ?? 'Etkinlik',
                  subtitle: (d['place'] as String?) ?? '',
                  date: (d['date'] as String?) ?? '',
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildMyListingsSection(String userDocId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('ownerUserDocId', isEqualTo: userDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildSectionCard(
            title: 'Verdiğim İlanlar',
            child: Text(
              'Liste yüklenemedi: ${snapshot.error}',
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          );
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
          final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });

        return _buildSectionCard(
          title: 'Verdiğim İlanlar',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (docs.isEmpty)
                const Text(
                  'Henüz ilan vermedin.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                )
              else
                ...List.generate(docs.length, (i) {
                  final d = docs[i].data();
                  final title = (d['title'] as String?) ?? 'İlan';
                  final created = _formatTs(d['createdAt']);
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < docs.length - 1 ? 8 : 0,
                    ),
                    child: _buildBulletItem(title: title, date: created),
                  );
                }),
              const SizedBox(height: 16),
              _buildPrimaryButton(
                'Yeni İlan Ekle',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewListingScreen(
                        onToggleTheme: widget.onToggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyNotesSection(String userDocId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .where('uploaderUserDocId', isEqualTo: userDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildSectionCard(
            title: 'Paylaştığım Notlar',
            child: Text(
              'Liste yüklenemedi: ${snapshot.error}',
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          );
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
          final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });

        return _buildSectionCard(
          title: 'Paylaştığım Notlar',
          trailing: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E3A8A),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotesFeedScreen(
                    embeddedInShell: false,
                    onToggleTheme: widget.onToggleTheme,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              );
            },
            child: const Text(
              'Tümünü Gör',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          child: Column(
            children: [
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Henüz not paylaşmadın.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _buildNotePreview(
                        title: (docs[0].data()['title'] as String?) ?? '',
                        subtitle: (docs[0].data()['course'] as String?) ?? '',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: docs.length > 1
                          ? _buildNotePreview(
                              title: (docs[1].data()['title'] as String?) ?? '',
                              subtitle:
                                  (docs[1].data()['course'] as String?) ?? '',
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              _buildPrimaryButton(
                'Yeni Not Ekle',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewNoteScreen(
                        onToggleTheme: widget.onToggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedNotesSection(String userDocId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('saved_notes')
          .where('userDocId', isEqualTo: userDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildSectionCard(
            title: 'Kaydedilen Notlar',
            child: Text(
              'Liste yüklenemedi: ${snapshot.error}',
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          );
        }
        final docs = [...(snapshot.data?.docs ?? [])];
        docs.sort((a, b) {
          final ta = a.data()['savedAt'];
          final tb = b.data()['savedAt'];
          final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
          final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
          return mb.compareTo(ma);
        });

        return _buildSectionCard(
          title: 'Kaydedilen Notlar',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (docs.isEmpty)
                const Text(
                  'Kayıtlı not yok. Not detayından "Kaydet" ile ekleyebilirsin.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                )
              else
                ...List.generate(docs.length, (i) {
                  final d = docs[i].data();
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < docs.length - 1 ? 8 : 0,
                    ),
                    child: _buildBulletItem(
                      title: (d['noteTitle'] as String?) ?? 'Not',
                      date: _formatTs(d['savedAt']),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              _buildPrimaryButton(
                'Notlar sayfasına git',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotesFeedScreen(
                        embeddedInShell: false,
                        onToggleTheme: widget.onToggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF5A7FCF).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF1E3A8A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEventItem({
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF5A7FCF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem({required String title, String? date}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
              ),
              if (date != null && date.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotePreview({required String title, required String subtitle}) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.description_outlined, color: Color(0xFF1E3A8A)),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, {VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5A7FCF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Mobil platformlarda image_picker ile fotoğraf seçer
class _MobileImagePicker {
  Future<PlatformFile?> pick(String source) async {
    try {
      // image_picker yerine file_picker kullan (daha güvenilir)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.single;
      if (file.bytes == null || file.bytes!.isEmpty) return null;
      return file;
    } catch (e) {
      debugPrint('_MobileImagePicker.pick: $e');
      return null;
    }
  }
}
