import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class FileSaverService {
  static Future<SavedFile> savePdfToDownloads({required Uint8List bytes, required String filename}) async {
    final path = await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );
    return SavedFile(path: path ?? '', name: filename);
  }
}

class SavedFile {
  final String path;
  final String name;
  SavedFile({required this.path, required this.name});
}
