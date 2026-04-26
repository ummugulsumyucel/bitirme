String sanitizeFileName(String originalName) {
  return originalName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
}

String guessMime(String? ext) {
  switch ((ext ?? '').toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'webp':
      return 'image/webp';
    default:
      return 'application/octet-stream';
  }
}
