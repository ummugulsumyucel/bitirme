// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';

/// Web'de dosyayı yeni sekmede açar (base64 data URL veya https URL)
Future<void> openFileInBrowser(String url, {String? fileName}) async {
  if (url.startsWith('data:')) {
    final commaIndex = url.indexOf(',');
    if (commaIndex == -1) return;

    final meta = url.substring(5, commaIndex); // "application/pdf;base64"
    final mimeType = meta.split(';').first;
    final base64Data = url.substring(commaIndex + 1);
    final bytes = base64Decode(base64Data);
    final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);

    // Önce pencereyi aç, sonra location'ı set et (popup blocker bypass)
    final newWindow = html.window.open('', '_blank');
    newWindow.location.href = objectUrl;

    Future.delayed(const Duration(seconds: 30), () {
      html.Url.revokeObjectUrl(objectUrl);
    });
  } else {
    html.window.open(url, '_blank');
  }
}

/// Web'de dosyayı indirir
Future<void> downloadFileInBrowser(String url, {String? fileName}) async {
  if (url.startsWith('data:')) {
    final commaIndex = url.indexOf(',');
    if (commaIndex == -1) return;

    final meta = url.substring(5, commaIndex);
    final mimeType = meta.split(';').first;
    final base64Data = url.substring(commaIndex + 1);
    final bytes = base64Decode(base64Data);
    final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: objectUrl)
      ..setAttribute('download', fileName ?? 'dosya')
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    Future.delayed(const Duration(seconds: 5), () {
      html.Url.revokeObjectUrl(objectUrl);
    });
  } else {
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName ?? 'dosya')
      ..setAttribute('target', '_blank')
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }
}
