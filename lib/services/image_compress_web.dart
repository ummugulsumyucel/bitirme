// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

/// Web'de canvas API ile resmi sıkıştırır
Future<Uint8List> compressImageWebImpl(
  Uint8List bytes,
  String mime, {
  int maxDimension = 600,
  double quality = 0.75,
}) async {
  final completer = Completer<Uint8List>();

  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final img = html.ImageElement();

  img.onLoad.listen((_) {
    try {
      int w = img.naturalWidth;
      int h = img.naturalHeight;

      // Boyutu küçült
      if (w > maxDimension || h > maxDimension) {
        if (w > h) {
          h = (h * maxDimension / w).round();
          w = maxDimension;
        } else {
          w = (w * maxDimension / h).round();
          h = maxDimension;
        }
      }

      final canvas = html.CanvasElement(width: w, height: h);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(img, 0, 0, w, h);

      final outputMime = mime == 'image/png' ? 'image/png' : 'image/jpeg';
      final dataUrl = canvas.toDataUrl(outputMime, quality);

      // data URL → bytes
      final base64Str = dataUrl.split(',').last;
      final result = base64Decode(base64Str);

      html.Url.revokeObjectUrl(url);
      completer.complete(Uint8List.fromList(result));
    } catch (e) {
      html.Url.revokeObjectUrl(url);
      completer.complete(bytes); // fallback: orijinal
    }
  });

  img.onError.listen((_) {
    html.Url.revokeObjectUrl(url);
    completer.complete(bytes); // fallback: orijinal
  });

  img.src = url;
  return completer.future;
}
