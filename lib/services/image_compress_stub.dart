import 'dart:typed_data';

/// Stub — web dışı platformlar için (sıkıştırma yapmaz)
Future<Uint8List> compressImageWeb(
  Uint8List bytes,
  String mime, {
  int maxDimension = 600,
  double quality = 0.75,
}) async {
  return bytes;
}
