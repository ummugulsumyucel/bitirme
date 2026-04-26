import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'image_compress.dart';

/// Profil fotoğrafını yükler ve URL döndürür.
/// Önce canvas ile sıkıştırır, sonra base64 veya Storage'a kaydeder.
Future<String> uploadProfilePhoto(String userDocId, PlatformFile file) async {
  final rawBytes = file.bytes;
  if (rawBytes == null || rawBytes.isEmpty) {
    throw Exception('Dosya okunamadı.');
  }

  final ext = (file.extension ?? 'jpg').toLowerCase();
  final safeExt = ['jpg', 'jpeg', 'png', 'webp'].contains(ext) ? ext : 'jpg';
  final mime = switch (safeExt) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };

  // Canvas ile sıkıştır (max 600px, %75 kalite)
  Uint8List bytes = await ImageCompress.compressImageWeb(
    rawBytes,
    mime,
    maxDimension: 600,
    quality: 0.75,
  );

  debugPrint(
    'uploadProfilePhoto: original=${rawBytes.length} compressed=${bytes.length}',
  );

  // Hâlâ büyükse daha agresif sıkıştır
  if (bytes.length >= 900 * 1024) {
    bytes = await ImageCompress.compressImageWeb(
      rawBytes,
      mime,
      maxDimension: 400,
      quality: 0.5,
    );
    debugPrint('uploadProfilePhoto: aggressive compress=${bytes.length}');
  }

  // 900KB altı → base64 olarak Firestore'a kaydet
  if (bytes.length < 900 * 1024) {
    debugPrint('uploadProfilePhoto: saving as base64 (${bytes.length} bytes)');
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  // Hâlâ büyükse → Firebase Storage dene
  final path =
      'users/$userDocId/profile_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
  final ref = FirebaseStorage.instance.ref().child(path);

  try {
    debugPrint('uploadProfilePhoto: uploading to Storage $path');
    await ref
        .putData(bytes, SettableMetadata(contentType: mime))
        .timeout(const Duration(seconds: 45));
    final url = await ref.getDownloadURL();
    debugPrint('uploadProfilePhoto: Storage success $url');
    return url;
  } catch (e) {
    debugPrint('uploadProfilePhoto: Storage failed: $e');
    throw Exception('Resim çok büyük. Lütfen daha küçük bir resim seçin.');
  }
}

/// Web'de FilePicker ile görsel seçer
Future<PlatformFile?> pickProfileImageWeb() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;
  final file = result.files.single;
  if (file.bytes == null || file.bytes!.isEmpty) return null;
  return file;
}
