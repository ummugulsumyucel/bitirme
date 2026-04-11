import 'package:file_picker/file_picker.dart';

import 'note_upload_mobile.dart' if (dart.library.html) 'note_upload_web.dart' as impl;

/// PDF veya görseli Firebase Storage'a yükler.
Future<String?> uploadNoteFile(PlatformFile file) => impl.uploadNoteFile(file);
