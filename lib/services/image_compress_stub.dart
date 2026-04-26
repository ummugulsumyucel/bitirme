import 'dart:typed_data';

/// Stub implementation for non-web platforms
Future<Uint8List> compressImageWebImpl(
  Uint8List bytes,
  String mime, {
  int maxDimension = 600,
  double quality = 0.75,
}) async {
  // This should never be called on non-web platforms
  throw UnsupportedError(
    'Web image compression is not supported on this platform',
  );
}
