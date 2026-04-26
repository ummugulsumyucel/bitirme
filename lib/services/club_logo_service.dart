import 'dart:convert';
import 'package:http/http.dart' as http;

class ClubLogoService {
  static final Map<String, String> _logoCache = {};

  /// Logo URL'sini base64 formatına çevirir ve cache'ler
  static Future<String?> getBase64Logo(String logoUrl) async {
    if (_logoCache.containsKey(logoUrl)) {
      return _logoCache[logoUrl];
    }
    try {
      // Proxy kullanarak logoyu indir
      final proxyUrl =
          'https://api.codetabs.com/v1/proxy?quest=${Uri.encodeComponent(logoUrl)}';
      final response = await http
          .get(
            Uri.parse(proxyUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final base64String = base64Encode(response.bodyBytes);
        final extension = logoUrl.split('.').last.toLowerCase();
        final mimeType = _getMimeType(extension);
        final dataUrl = 'data:$mimeType;base64,$base64String';
        _logoCache[logoUrl] = dataUrl;
        return dataUrl;
      }
    } catch (e) {
      print('Logo yükleme hatası: $e');
    }
    return null;
  }

  static String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  static void clearCache() {
    _logoCache.clear();
  }
}
