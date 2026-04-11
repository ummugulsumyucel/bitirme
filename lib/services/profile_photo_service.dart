import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadProfilePhoto(String userDocId, XFile file) async {
  final bytes = await file.readAsBytes();
  final rawName = file.name;
  final ext = rawName.contains('.')
      ? rawName.split('.').last.toLowerCase()
      : 'jpg';
  final safeExt = ['jpg', 'jpeg', 'png', 'webp'].contains(ext) ? ext : 'jpg';
  final path =
      'users/$userDocId/profile_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
  final ref = FirebaseStorage.instance.ref().child(path);
  final mime = switch (safeExt) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
  await ref.putData(bytes, SettableMetadata(contentType: mime));
  return ref.getDownloadURL();
}
