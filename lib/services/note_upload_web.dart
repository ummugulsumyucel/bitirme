import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'note_upload_common.dart';

Future<String?> uploadNoteFile(PlatformFile file) async {
  final originalName = file.name;
  if (originalName.isEmpty) return null;

  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    debugPrint('uploadNoteFile: bytes is null or empty');
    return null;
  }

  // Küçük dosyalar için base64 data URL döndür (Firestore'a kaydedilecek)
  if (bytes.length < 500 * 1024) {
    // 500KB'dan küçükse
    debugPrint(
      'uploadNoteFile: using base64 data URL for ${bytes.length} bytes',
    );
    final mime = guessMime(file.extension);
    final base64Data = base64Encode(bytes);
    return 'data:$mime;base64,$base64Data';
  }

  // Büyük dosyalar için Firebase Storage'a yükle
  final safeName = sanitizeFileName(originalName);
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final objectPath = 'notes/${timestamp}_$safeName';
  final mime = guessMime(file.extension);

  debugPrint(
    'uploadNoteFile: uploading to Storage $objectPath (${bytes.length} bytes, $mime)',
  );

  final storage = FirebaseStorage.instance;
  debugPrint('uploadNoteFile: storageBucket=${storage.bucket}');

  try {
    final ref = storage.ref().child(objectPath);
    final metadata = SettableMetadata(contentType: mime);

    final TaskSnapshot snapshot = await ref
        .putData(bytes, metadata)
        .then((s) => s)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () =>
              throw TimeoutException('Upload timed out after 60 seconds'),
        );

    debugPrint('uploadNoteFile: upload complete, state=${snapshot.state}');

    if (snapshot.state != TaskState.success) {
      debugPrint('uploadNoteFile: upload state is not success');
      return null;
    }

    final url = await ref.getDownloadURL().timeout(const Duration(seconds: 15));
    debugPrint('uploadNoteFile: success url=$url');
    return url.isNotEmpty ? url : null;
  } on TimeoutException catch (e) {
    debugPrint('uploadNoteFile: timeout: $e');
    // Timeout durumunda base64 fallback
    debugPrint('uploadNoteFile: falling back to base64 data URL');
    final mime = guessMime(file.extension);
    final base64Data = base64Encode(bytes);
    return 'data:$mime;base64,$base64Data';
  } on FirebaseException catch (e) {
    debugPrint('uploadNoteFile: FirebaseException: ${e.code} ${e.message}');
    // Firebase hatası durumunda base64 fallback
    if (bytes.length < 1024 * 1024) {
      // 1MB'dan küçükse
      debugPrint('uploadNoteFile: falling back to base64 data URL');
      final mime = guessMime(file.extension);
      final base64Data = base64Encode(bytes);
      return 'data:$mime;base64,$base64Data';
    }
    return null;
  } catch (e, st) {
    debugPrint('uploadNoteFile: unexpected error: $e\n$st');
    return null;
  }
}
