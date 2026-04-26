import 'dart:async';
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'note_upload_common.dart';

Future<String?> uploadNoteFile(PlatformFile file) async {
  final originalName = file.name;
  if (originalName.isEmpty) return null;

  final safeName = sanitizeFileName(originalName);
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final objectPath = 'notes/${timestamp}_$safeName';

  final mime = guessMime(file.extension);
  final bytes = file.bytes;
  final path = file.path;

  final buckets = <String?>[
    null,
    '${FirebaseStorage.instance.app.options.projectId}.appspot.com',
  ];

  for (final bucket in buckets) {
    try {
      final storage = bucket == null
          ? FirebaseStorage.instance
          : FirebaseStorage.instanceFor(bucket: bucket);
      final ref = storage.ref().child(objectPath);

      if (path != null && path.isNotEmpty) {
        await ref
            .putFile(File(path), SettableMetadata(contentType: mime))
            .timeout(
              const Duration(seconds: 90),
            ); // Büyük dosyalar için süre artırıldı
      } else {
        if (bytes == null || bytes.isEmpty) return null;
        await ref
            .putData(bytes, SettableMetadata(contentType: mime))
            .timeout(
              const Duration(seconds: 90),
            ); // Büyük dosyalar için süre artırıldı
      }

      final url = await ref.getDownloadURL().timeout(
        const Duration(seconds: 10),
      );
      if (url.isNotEmpty) return url;
    } on TimeoutException {
      continue;
    } on FirebaseException {
      continue;
    }
  }
  return null;
}
