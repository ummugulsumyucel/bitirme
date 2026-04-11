import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'note_upload_common.dart';

Future<String?> uploadNoteFile(PlatformFile file) async {
  final originalName = file.name;
  if (originalName.isEmpty) return null;

  final safeName = sanitizeFileName(originalName);
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final objectPath = 'notes/${timestamp}_$safeName';

  final ref = FirebaseStorage.instance.ref().child(objectPath);
  final mime = guessMime(file.extension);

  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) return null;
  await ref.putData(bytes, SettableMetadata(contentType: mime));
  return ref.getDownloadURL();
}
