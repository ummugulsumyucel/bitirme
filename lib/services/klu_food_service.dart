import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class KluFoodService {
  // Web platformunda local emulator kullan
  static const String _url = kIsWeb
      ? 'http://127.0.0.1:5001/bitirme-a6f96/us-central1/fetchKluMenu'
      : 'https://sks.klu.edu.tr/Takvimler/73-yemek-takvimi.klu';

  // Önbellek: aynı oturumda tekrar istek atmamak için
  static String? _cachedHtml;

  static Future<String?> _fetchHtml() async {
    if (_cachedHtml != null) return _cachedHtml;
    try {
      final response = await http
          .get(
            Uri.parse(_url),
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
              'Accept': 'text/html,application/xhtml+xml',
              'Accept-Language': 'tr-TR,tr;q=0.9',
            },
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('[KluFood] status: ${response.statusCode}');
      if (response.statusCode != 200) return null;
      _cachedHtml = response.body;
      return _cachedHtml;
    } catch (e) {
      debugPrint('[KluFood] hata: $e');
      return null;
    }
  }

  static List<dynamic>? _parseEvents(String html) {
    final start = html.indexOf('>[{');
    final end = html.lastIndexOf('}]');
    if (start == -1 || end == -1) return null;
    final jsonStr = html.substring(start + 1, end + 2);
    try {
      return jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Verilen tarih için yemek listesi döner.
  static Future<List<String>> fetchMenuForDate(DateTime date) async {
    final html = await _fetchHtml();
    if (html == null) return [];
    final events = _parseEvents(html);
    if (events == null) return [];

    final target =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    debugPrint('[KluFood] toplam event: ${events.length}, hedef: $target');

    for (final e in events) {
      final eventStart = (e['start'] as String? ?? '');
      if (eventStart.startsWith(target)) {
        final aciklama = (e['aciklama'] as String? ?? '').trim();
        if (aciklama.isEmpty) return [];
        return aciklama
            .split('\n')
            .map((s) => s.trim().replaceAll(RegExp(r',+$'), ''))
            .where((s) => s.isNotEmpty)
            .toList();
      }
    }
    return [];
  }

  /// Bugün veya bugünden sonraki en yakın menü tarihini döner.
  /// Menü yoksa null döner.
  static Future<DateTime?> fetchNearestMenuDate() async {
    final html = await _fetchHtml();
    if (html == null) return null;
    final events = _parseEvents(html);
    if (events == null) return null;

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Tarihleri topla ve sırala
    final dates = <DateTime>[];
    for (final e in events) {
      final s = (e['start'] as String? ?? '');
      if (s.length >= 10) {
        try {
          final d = DateTime.parse(s.substring(0, 10));
          dates.add(d);
        } catch (_) {}
      }
    }
    dates.sort((a, b) => a.compareTo(b));

    // Bugün veya sonraki en yakın tarihi bul
    for (final d in dates) {
      final dStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (dStr.compareTo(todayStr) >= 0) return d;
    }
    return null;
  }

  /// Önbelleği temizler (pull-to-refresh için).
  static void clearCache() => _cachedHtml = null;
}
