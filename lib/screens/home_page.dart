// GIT_TEST_999
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../theme/uni_theme.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'calendar_page.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'announcements_page.dart';
import 'notes_feed_screen.dart';
import 'event_detail_screen.dart';
import '../services/auth_service.dart';
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
      drawer: _buildDrawer(context),
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

  Widget _buildHeroSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> bannerItems = [
      {
        'title': 'Tüm kampüs hayatınız\ntek bir yerde!',
        'subtitle': 'Akademik ve sosyal yaşamınızı kolayca yönetin!',
        'description':
            'Ders programınız, etkinlikler, duyurular ve ilanlar… Hepsi cebinizde.',
        'icon': Icons.dashboard_rounded,
        'gradient': [
          scheme.primaryContainer.withValues(alpha: 0.65),
          scheme.tertiaryContainer.withValues(alpha: 0.5),
          scheme.secondaryContainer.withValues(alpha: 0.4),
        ],
      },
      {
        'title': 'Kampüs hayatını\nkaçırma!',
        'subtitle': 'Etkinliklerden haberdar ol',
        'description':
            'Dersleri takip et, etkinliklerden haberdar ol, yeni arkadaşlıklar kur.',
        'icon': Icons.celebration_rounded,
        'gradient': [
          scheme.secondaryContainer.withValues(alpha: 0.65),
          scheme.primaryContainer.withValues(alpha: 0.5),
          scheme.tertiaryContainer.withValues(alpha: 0.4),
        ],
      },
      {
        'title': 'UniConnect ile\nbağlı kal!',
        'subtitle': 'Kampüs topluluğunun bir parçası ol',
        'description':
            'Kulüpleri keşfet, etkinliklere katıl, notlarını paylaş.',
        'icon': Icons.groups_rounded,
        'gradient': [
          scheme.tertiaryContainer.withValues(alpha: 0.65),
          scheme.secondaryContainer.withValues(alpha: 0.5),
          scheme.primaryContainer.withValues(alpha: 0.4),
        ],
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 220,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
      ),
      items: bannerItems.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item['gradient'] as List<Color>,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  // Sol taraf - İçerik
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                color: scheme.onPrimary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'UniConnect',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                            color: scheme.onSurface,
                            letterSpacing: -0.8,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['description'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.4,
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sağ taraf - Büyük İkon
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.32),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          item['icon'] as IconData,
                          size: 90,
                          color: scheme.onPrimaryContainer.withValues(alpha: 0.88),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
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
                      'id': events[i].id,
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
    final eventId = eventData['id'] as String?;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: eventId != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(
                      eventId: eventId,
                      title: title,
                      date: date,
                      place: place,
                      time: time,
                      onToggleTheme: onToggleDarkMode,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                scheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Sol taraf - Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getEventIcon(category),
                  color: scheme.onPrimary,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimary,
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
                          color: scheme.onPrimary.withValues(alpha: 0.75),
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Yer
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: scheme.onPrimary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            place.isNotEmpty ? place : 'Yer belirtilmemiş',
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onPrimary.withValues(alpha: 0.9),
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
                          color: scheme.onPrimary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          date.isNotEmpty ? date : 'Tarih belirtilmemiş',
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                        if (time.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: scheme.onPrimary.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onPrimary.withValues(alpha: 0.9),
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
              print('FutureBuilder state: ${snapshot.connectionState}');
              print('Has data: ${snapshot.hasData}');
              print('Data: ${snapshot.data}');
              print('Data length: ${snapshot.data?.length}');

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                );
              }

              final newsList = snapshot.data ?? [];
              print('newsList length: ${newsList.length}');

              if (newsList.isEmpty) {
                print('Liste boş, fallback kart gösteriliyor');
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
        onTap: () {
          print('Haber tıklandı: ${news.title}');
          print('URL: ${news.url}');
          _openClubUrl(context, news.url);
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
          colors: [
            scheme.primary,
            scheme.secondary,
          ],
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

  Widget _buildDrawer(BuildContext context) {
    final authService = AuthService();
    final isLoggedIn = authService.isLoggedIn;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E3A8A)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'UniConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUserName ?? 'Kullanıcı',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Etkinlikler'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventsScreen(
                    embeddedInShell: false,
                    onToggleTheme: onToggleDarkMode,
                    isDarkMode: isDarkMode,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Takvim'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profilim'),
            onTap: () {
              Navigator.pop(context);
              if (!isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      embeddedInShell: false,
                      onToggleTheme: onToggleDarkMode,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign),
            title: const Text('İlanlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementsPage(
                    onToggleDarkMode: onToggleDarkMode,
                    isDarkMode: isDarkMode,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Notlar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const NotesFeedScreen(embeddedInShell: false),
                ),
              );
            },
          ),
          const Divider(),
          if (!isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Giriş Yap'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Kayıt Ol'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış Yap'),
              onTap: () async {
                Navigator.pop(context);
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
            leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDarkMode ? 'Açık Mod' : 'Koyu Mod'),
            onTap: () {
              onToggleDarkMode();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
