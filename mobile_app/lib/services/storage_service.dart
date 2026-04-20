import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadIncidentImage(File file) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      Reference ref = _storage.ref().child('incidents/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
