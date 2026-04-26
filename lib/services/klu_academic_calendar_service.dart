/// KLU Akademik Takvim Servisi
/// Kırklareli Üniversitesi 2025-2026 akademik yılı önemli tarihleri.
/// Kaynak: https://oidb.klu.edu.tr (akademik takvim)
library;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AcademicEvent {
  final String title;
  final DateTime start;
  final DateTime? end; // null ise tek günlük
  final AcademicEventType type;

  const AcademicEvent({
    required this.title,
    required this.start,
    this.end,
    required this.type,
  });

  /// Etkinliğin kapsadığı tüm günleri döndürür
  List<DateTime> get days {
    if (end == null) return [_normalize(start)];
    final result = <DateTime>[];
    var current = _normalize(start);
    final last = _normalize(end!);
    while (!current.isAfter(last)) {
      result.add(current);
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}

enum AcademicEventType {
  registration, // Kayıt / ders kaydı
  exam, // Sınav
  holiday, // Tatil / resmi tatil
  semester, // Dönem başlangıç/bitiş
  other, // Diğer
}

class KluAcademicCalendarService {
  KluAcademicCalendarService._();

  /// 2025-2026 Akademik Yılı Takvimi (Güz + Bahar)
  static final List<AcademicEvent> events2025_2026 = [
    // ── GÜZ DÖNEMİ ──────────────────────────────────────────────────────────
    AcademicEvent(
      title: 'Güz Dönemi Ders Kaydı',
      start: DateTime(2025, 9, 15),
      end: DateTime(2025, 9, 19),
      type: AcademicEventType.registration,
    ),
    AcademicEvent(
      title: 'Güz Dönemi Dersleri Başlangıcı',
      start: DateTime(2025, 9, 22),
      type: AcademicEventType.semester,
    ),
    AcademicEvent(
      title: 'Ders Ekleme-Bırakma',
      start: DateTime(2025, 9, 22),
      end: DateTime(2025, 9, 26),
      type: AcademicEventType.registration,
    ),
    AcademicEvent(
      title: 'Cumhuriyet Bayramı (Tatil)',
      start: DateTime(2025, 10, 29),
      type: AcademicEventType.holiday,
    ),
    AcademicEvent(
      title: 'Atatürk\'ü Anma Günü (Tatil)',
      start: DateTime(2025, 11, 10),
      type: AcademicEventType.holiday,
    ),
    AcademicEvent(
      title: 'Güz Dönemi Vize Sınavları',
      start: DateTime(2025, 11, 10),
      end: DateTime(2025, 11, 21),
      type: AcademicEventType.exam,
    ),
    AcademicEvent(
      title: 'Güz Dönemi Final Sınavları',
      start: DateTime(2026, 1, 12),
      end: DateTime(2026, 1, 23),
      type: AcademicEventType.exam,
    ),
    AcademicEvent(
      title: 'Güz Dönemi Bütünleme Sınavları',
      start: DateTime(2026, 1, 26),
      end: DateTime(2026, 2, 6),
      type: AcademicEventType.exam,
    ),

    // ── BAHAR DÖNEMİ ────────────────────────────────────────────────────────
    AcademicEvent(
      title: 'Bahar Dönemi Ders Kaydı',
      start: DateTime(2026, 2, 9),
      end: DateTime(2026, 2, 13),
      type: AcademicEventType.registration,
    ),
    AcademicEvent(
      title: 'Bahar Dönemi Dersleri Başlangıcı',
      start: DateTime(2026, 2, 16),
      type: AcademicEventType.semester,
    ),
    AcademicEvent(
      title: 'Ders Ekleme-Bırakma',
      start: DateTime(2026, 2, 16),
      end: DateTime(2026, 2, 20),
      type: AcademicEventType.registration,
    ),
    AcademicEvent(
      title: 'Nevruz Bayramı (Tatil)',
      start: DateTime(2026, 3, 21),
      type: AcademicEventType.holiday,
    ),
    AcademicEvent(
      title: 'Bahar Dönemi Vize Sınavları',
      start: DateTime(2026, 4, 6),
      end: DateTime(2026, 4, 17),
      type: AcademicEventType.exam,
    ),
    AcademicEvent(
      title: 'Ulusal Egemenlik ve Çocuk Bayramı (Tatil)',
      start: DateTime(2026, 4, 23),
      type: AcademicEventType.holiday,
    ),
    AcademicEvent(
      title: 'Emek ve Dayanışma Günü (Tatil)',
      start: DateTime(2026, 5, 1),
      type: AcademicEventType.holiday,
    ),
    AcademicEvent(
      title: 'Atatürk\'ü Anma, Gençlik ve Spor Bayramı (Tatil)',
      start: DateTime(2026, 5, 19),
      type: AcademicEventType.holiday,
    ),
    AcademicEvent(
      title: 'Bahar Dönemi Final Sınavları',
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 12),
      type: AcademicEventType.exam,
    ),
    AcademicEvent(
      title: 'Bahar Dönemi Bütünleme Sınavları',
      start: DateTime(2026, 6, 15),
      end: DateTime(2026, 6, 26),
      type: AcademicEventType.exam,
    ),
    AcademicEvent(
      title: 'Demokrasi ve Millî Birlik Günü (Tatil)',
      start: DateTime(2026, 7, 15),
      type: AcademicEventType.holiday,
    ),
    AcademicEvent(
      title: 'Zafer Bayramı (Tatil)',
      start: DateTime(2026, 8, 30),
      type: AcademicEventType.holiday,
    ),
  ];

  /// Belirli bir gün için akademik etkinlikleri döndürür
  static List<AcademicEvent> eventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return events2025_2026.where((e) => e.days.contains(normalized)).toList();
  }

  // ── Resmi PDF URL'si ──────────────────────────────────────────────────────

  /// KLÜ akademik takvim sayfasından en güncel PDF linkini çeker.
  /// Başarısız olursa bilinen son URL'yi döndürür.
  static Future<String> fetchLatestPdfUrl() async {
    const pageUrl =
        'https://oidb.klu.edu.tr/Yardimci_Sayfalar/1877-akademik-takvim.klu';
    const fallback =
        'https://oidb.klu.edu.tr/dosyalar/birimler/oidb/dosyalar/dosya_ve_belgeler/klu_2025-2026_onlisans_ve_lisans_akademik_takvimi.pdf';

    try {
      final response = await http
          .get(Uri.parse(pageUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return fallback;

      final body = response.body;

      // Sayfadaki tüm PDF linklerini bul
      final pdfRegex = RegExp(
        r'href="(https?://[^"]*onlisans[^"]*\.pdf)"',
        caseSensitive: false,
      );
      final matches = pdfRegex.allMatches(body).toList();

      if (matches.isEmpty) return fallback;

      // En yüksek yılı içeren linki seç (örn: 2025-2026 > 2024-2025)
      String best = fallback;
      int bestYear = 0;
      for (final m in matches) {
        final url = m.group(1)!;
        final yearMatch = RegExp(r'(\d{4})-\d{4}').firstMatch(url);
        if (yearMatch != null) {
          final year = int.tryParse(yearMatch.group(1)!) ?? 0;
          if (year > bestYear) {
            bestYear = year;
            best = url;
          }
        }
      }
      return best;
    } catch (_) {
      return fallback;
    }
  }

  /// Resmi akademik takvim PDF'ini tarayıcıda açar.
  static Future<void> openOfficialCalendar() async {
    final url = await fetchLatestPdfUrl();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Etkinlik türüne göre renk
  static Color colorForType(AcademicEventType type) {
    switch (type) {
      case AcademicEventType.exam:
        return const Color(0xFFEF4444); // kırmızı
      case AcademicEventType.holiday:
        return const Color(0xFF10B981); // yeşil
      case AcademicEventType.registration:
        return const Color(0xFF6366F1); // mor
      case AcademicEventType.semester:
        return const Color(0xFFF97316); // turuncu
      case AcademicEventType.other:
        return const Color(0xFF6B7280); // gri
    }
  }

  /// Etkinlik türüne göre ikon
  static String labelForType(AcademicEventType type) {
    switch (type) {
      case AcademicEventType.exam:
        return 'Sınav';
      case AcademicEventType.holiday:
        return 'Tatil';
      case AcademicEventType.registration:
        return 'Kayıt';
      case AcademicEventType.semester:
        return 'Dönem';
      case AcademicEventType.other:
        return 'Diğer';
    }
  }
}
