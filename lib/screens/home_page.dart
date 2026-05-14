// GIT_TEST_999
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/uni_theme.dart';
import '../widgets/common_drawer.dart';
import 'event_detail_screen.dart';
import '../services/klu_clubs_service.dart';
import '../services/club_logo_service.dart';
import '../services/klu_news_service.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onToggleDarkMode;
  final bool isDarkMode;

  /// [MainShell] içindeyken üst bar ve çekmece kabukta olduğundan yalnızca içerik çizilir.
  final bool embeddedInShell;

  const HomePage({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    this.embeddedInShell = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(context),
              _buildAnnouncementBanner(context), // ← Yeni slider
              _buildUpcomingEventSection(context),
              _buildThisWeekSection(context),
              _buildSupportingClubsSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    if (embeddedInShell) {
      return content;
    }

    return Scaffold(
      drawer: CommonDrawer(
        onToggleTheme: onToggleDarkMode,
        isDarkMode: isDarkMode,
        selectedPage: 'home',
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.school, color: scheme.onPrimary),
          const SizedBox(width: 8),
          Text(
            'UniConnect',
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: scheme.onPrimary,
            ),
            onPressed: onToggleDarkMode,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: scheme.onPrimary),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementBanner(BuildContext context) {
    return _AnnouncementBannerSlider();
  }

  Widget _buildHeroSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.65),
            scheme.tertiaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Sol taraf - Metin
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Akademik ve sosyal yaşamınızı kolayca yönetin!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tüm kampüs hayatınız\ntek bir yerde!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Sağ taraf - İkon
          Expanded(
            flex: 2,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.dashboard_rounded,
                  size: 70,
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: UniBrand.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Yaklaşan Etkinlikler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        // Etkinlik kartları
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Etkinlikler yüklenirken hata oluştu',
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                ),
              );
            }

            final events = snapshot.data?.docs ?? [];

            if (events.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 40,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Henüz etkinlik yok. Yakında kampüste düzenlenecek etkinlikler burada görünecek.',
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (int i = 0; i < events.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    _buildEventCard(context, {
                      ...events[i].data(),
                      'id': events[i].id, // Document ID'sini ekle
                    }),
                  ],
                  const SizedBox(
                    height: 32,
                  ), // "Bu hafta kampüste" ile arasında boşluk
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> eventData) {
    final scheme = Theme.of(context).colorScheme;
    final title = (eventData['title'] as String?)?.trim() ?? 'Etkinlik';
    final place = (eventData['place'] as String?)?.trim() ?? '';
    final date = (eventData['date'] as String?)?.trim() ?? '';
    final time = (eventData['time'] as String?)?.trim() ?? '';
    final category = (eventData['category'] as String?)?.trim() ?? '';
    final imageUrl = (eventData['imageUrl'] as String?)?.trim();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Etkinlik detay sayfasına yönlendir
          _navigateToEventDetail(context, eventData);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF3D5296), // Koyu temada orta mavi
                      const Color(
                        0xFF2E3F7A,
                      ), // Biraz daha koyu ama siyah değil
                    ]
                  : [
                      scheme.primary,
                      Color.lerp(
                        scheme.primary,
                        const Color(0xFF0F1729),
                        0.25,
                      )!,
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0xFF3D5296).withValues(alpha: 0.35)
                    : scheme.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Sol taraf - Resim veya Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? _buildCardImage(imageUrl)
                    : Icon(
                        _getEventIcon(category),
                        color: Colors.white,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 16),
              // Sağ taraf - İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Kategori
                    if (category.isNotEmpty)
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Yer
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            place.isNotEmpty ? place : 'Yer belirtilmemiş',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Tarih ve Saat
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          date.isNotEmpty ? date : 'Tarih belirtilmemiş',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        if (time.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kart için resim widget'ı — hem URL hem base64 destekler.
  Widget _buildCardImage(String imageUrl) {
    if (imageUrl.startsWith('data:')) {
      try {
        final comma = imageUrl.indexOf(',');
        if (comma != -1) {
          final bytes = base64Decode(imageUrl.substring(comma + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 64,
            height: 64,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white38,
              size: 28,
            ),
          );
        }
      } catch (_) {}
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.broken_image_outlined,
          color: Colors.white38,
          size: 28,
        ),
      );
    }
    return const Icon(
      Icons.broken_image_outlined,
      color: Colors.white38,
      size: 28,
    );
  }

  IconData _getEventIcon(String category) {
    switch (category.toLowerCase()) {
      case 'konser':
      case 'müzik':
        return Icons.music_note_rounded;
      case 'spor':
        return Icons.sports_soccer_rounded;
      case 'konferans':
      case 'seminer':
        return Icons.school_rounded;
      case 'workshop':
      case 'atölye':
        return Icons.build_rounded;
      case 'sosyal':
      case 'parti':
        return Icons.celebration_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  void _navigateToEventDetail(
    BuildContext context,
    Map<String, dynamic> eventData,
  ) {
    // Firestore document ID'sini al (eğer varsa)
    String? eventId;

    // Eğer eventData bir DocumentSnapshot'tan geliyorsa, ID'yi al
    if (eventData.containsKey('id')) {
      eventId = eventData['id'] as String?;
    }

    // Eğer ID yoksa, title'dan basit bir ID oluştur
    eventId ??=
        eventData['title']?.toString().toLowerCase().replaceAll(' ', '_') ??
        'unknown_event';

    final title = (eventData['title'] as String?)?.trim() ?? 'Etkinlik';
    final place =
        (eventData['place'] as String?)?.trim() ?? 'Yer belirtilmemiş';
    final date =
        (eventData['date'] as String?)?.trim() ?? 'Tarih belirtilmemiş';
    final time = (eventData['time'] as String?)?.trim() ?? 'Saat belirtilmemiş';
    final category = (eventData['category'] as String?)?.trim() ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          eventId: eventId!,
          title: title,
          date: date,
          place: place,
          time: time,
          label: category.isNotEmpty ? category : null,
          icon: _getEventIcon(category),
          onToggleTheme: onToggleDarkMode,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  Widget _buildThisWeekSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        24,
        16,
        0,
      ), // Üstten 24px boşluk eklendi
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: UniBrand.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bu Hafta Kampüste',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Öne Çıkan Başlıklar',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<KluNews>>(
            future: KluNewsService.fetchNews(),
            builder: (context, snapshot) {
              debugPrint('FutureBuilder state: ${snapshot.connectionState}');
              debugPrint('Has data: ${snapshot.hasData}');
              debugPrint('Data: ${snapshot.data}');
              debugPrint('Data length: ${snapshot.data?.length}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                );
              }

              final newsList = snapshot.data ?? [];
              debugPrint('newsList length: ${newsList.length}');

              if (newsList.isEmpty) {
                debugPrint('Liste boş, fallback kart gösteriliyor');
                return _buildNewsCard(
                  context,
                  const KluNews(
                    title: 'HABERLER YÜKLENİYOR...',
                    url:
                        'https://kurumsaliletisim.klu.edu.tr/Sayfalar/43628-rektorumuz-turizm-haftasi-resepsiyonuna-katildi.klu',
                    date: '17/04/2026',
                    views: '0 okunma',
                  ),
                );
              }

              print('${newsList.length} haber gösteriliyor');
              for (var news in newsList) {
                print('Haber: ${news.title} - URL: ${news.url}');
              }

              return Column(
                children: [
                  for (int i = 0; i < newsList.length; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    _buildNewsCard(context, newsList[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, KluNews news) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          debugPrint('Haber tıklandı: ${news.title}');
          debugPrint('URL: ${news.url}');

          // Direkt okulun web sitesindeki habere yönlendir
          final uri = Uri.parse(news.url);
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Haber açılamadı. Lütfen daha sonra tekrar deneyin.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            debugPrint('URL açma hatası: $e');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hata: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              // Sol taraf - Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Sağ taraf - İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      news.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                        height: 1.3,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Tarih ve okunma
                    Text(
                      '${news.date ?? ''} · ${news.views ?? '0 okunma'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportingClubsSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final service = KluClubsService();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Destekleyen Kulüpler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kampüs Topluluğu',
            style: TextStyle(
              fontSize: 13,
              color: scheme.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<KluClub>>(
            future: service.fetchSupportingClubs(),
            builder: (context, snap) {
              final clubs = snap.data ?? KluClubsService.fallbackClubs;
              if (clubs.isEmpty) return const SizedBox.shrink();
              String query = '';
              return StatefulBuilder(
                builder: (context, setLocalState) {
                  final filtered = clubs
                      .where(
                        (c) =>
                            c.name.toLowerCase().contains(query.toLowerCase()),
                      )
                      .toList();

                  return Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 380;

                          final searchField = SizedBox(
                            width: compact ? double.infinity : 180,
                            height: 32,
                            child: TextField(
                              onChanged: (v) =>
                                  setLocalState(() => query = v.trim()),
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Kulüp ara...',
                                hintStyle: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onPrimary.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 16,
                                  color: scheme.onPrimary.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: scheme.onPrimary.withValues(
                                  alpha: 0.14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(
                                    color: scheme.onPrimary.withValues(
                                      alpha: 0.26,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(999),
                                  borderSide: BorderSide(
                                    color: scheme.onPrimary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatistic(
                                        context,
                                        Icons.people_alt_rounded,
                                        '4.740',
                                        'Öğrenci',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatistic(
                                        context,
                                        Icons.event_available_rounded,
                                        '565',
                                        'Etkinlik',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                searchField,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildStatistic(
                                context,
                                Icons.people_alt_rounded,
                                '4.740',
                                'Öğrenci',
                              ),
                              const SizedBox(width: 14),
                              _buildStatistic(
                                context,
                                Icons.event_available_rounded,
                                '565',
                                'Etkinlik',
                              ),
                              const Spacer(),
                              searchField,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, i) {
                            final club = filtered[i];
                            return InkWell(
                              onTap: () => _openClubUrl(context, club.url),
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 92,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        color: scheme.onPrimary.withValues(
                                          alpha: 0.16,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: scheme.onPrimary.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: _buildClubLogo(
                                          context,
                                          club,
                                          scheme,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      club.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: scheme.onPrimary.withValues(
                                          alpha: 0.95,
                                        ),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _clubInitial(String name) {
    final t = name.trim();
    if (t.isEmpty) return 'K';
    return t.characters.first.toUpperCase();
  }

  Widget _buildClubLogo(
    BuildContext context,
    KluClub club,
    ColorScheme scheme,
  ) {
    // Logo yoksa veya boşsa baş harfi göster
    if (club.logoUrl == null || club.logoUrl!.isEmpty) {
      return Center(
        child: Text(
          _clubInitial(club.name),
          style: TextStyle(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      );
    }

    // Logo varsa (defaultLogo dahil) yükle ve göster
    return FutureBuilder<String?>(
      future: ClubLogoService.getBase64Logo(club.logoUrl!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.onPrimary.withValues(alpha: 0.5),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Image.network(
            snapshot.data!,
            width: 62,
            height: 62,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Text(
                _clubInitial(club.name),
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
          );
        }
        // Yükleme başarısız olursa baş harfi göster
        return Center(
          child: Text(
            _clubInitial(club.name),
            style: TextStyle(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        );
      },
    );
  }

  Future<void> _openClubUrl(BuildContext context, String url) async {
    print('_openClubUrl çağrıldı: $url');
    final uri = Uri.tryParse(url);
    if (uri == null) {
      print('URI parse edilemedi: $url');
      return;
    }
    print('URI başarıyla parse edildi: $uri');

    try {
      // Web için externalApplication kullan (yeni sekmede açar)
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('launchUrl sonucu: $ok');
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sayfa açılamadı: $url')));
      }
    } catch (e) {
      print('launchUrl hatası: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Widget _buildStatistic(
    BuildContext context,
    IconData icon,
    String number,
    String label,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: scheme.onPrimary, size: 22),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onPrimary.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Duyuru Banner Slider ────────────────────────────────────────────────────

class _AnnouncementBannerSlider extends StatefulWidget {
  @override
  State<_AnnouncementBannerSlider> createState() =>
      _AnnouncementBannerSliderState();
}

class _AnnouncementBannerSliderState extends State<_AnnouncementBannerSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  Timer? _timer;

  // Uygulama özelliklerini tanıtan banner verileri
  static const List<_BannerItem> _defaultBanners = [
    _BannerItem(
      title: 'AI Asistan',
      subtitle: 'Kampüs sorularını yapay zeka ile anında yanıtla.',
      icon: Icons.smart_toy_rounded,
      gradientStart: Color(0xFF6366F1),
      gradientEnd: Color(0xFF8B5CF6),
    ),
    _BannerItem(
      title: 'Etkinlikler',
      subtitle: 'Kampüsteki tüm etkinlikleri takip et ve katıl.',
      icon: Icons.event_rounded,
      gradientStart: Color(0xFF1E3A8A),
      gradientEnd: Color(0xFF3B82F6),
    ),
    _BannerItem(
      title: 'Yemek Menüsü',
      subtitle: 'Günlük yemekhane menüsünü anında görüntüle.',
      icon: Icons.restaurant_rounded,
      gradientStart: Color(0xFF10B981),
      gradientEnd: Color(0xFF059669),
    ),
    _BannerItem(
      title: 'Duyurular',
      subtitle: 'Üniversite duyurularını ve haberleri kaçırma.',
      icon: Icons.campaign_rounded,
      gradientStart: Color(0xFF0EA5E9),
      gradientEnd: Color(0xFF06B6D4),
    ),
    _BannerItem(
      title: 'Not Paylaşımı',
      subtitle: 'Ders notlarını paylaş, arkadaşlarınkini keşfet.',
      icon: Icons.note_alt_rounded,
      gradientStart: Color(0xFFD97706),
      gradientEnd: Color(0xFFF59E0B),
    ),
    _BannerItem(
      title: 'İkinci El İlanlar',
      subtitle: 'Kampüste al, sat ve takas yap.',
      icon: Icons.storefront_rounded,
      gradientStart: Color(0xFFDC2626),
      gradientEnd: Color(0xFFEF4444),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _defaultBanners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _defaultBanners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final banner = _defaultBanners[index];
              return _buildBannerCard(banner);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Nokta göstergesi
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _defaultBanners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBannerCard(_BannerItem banner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [banner.gradientStart, banner.gradientEnd],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: banner.gradientStart.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // İkon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(banner.icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 16),
            // Metin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    banner.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
  });
}
