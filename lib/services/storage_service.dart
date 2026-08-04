import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube la foto de perfil de un usuario a Firebase Storage y
  /// devuelve su URL de descarga con un parámetro de caché.
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage
        .ref()
        .child('usuarios')
        .child(uid)
        .child('profile.jpg');

    await ref.putFile(file);

    final url = await ref.getDownloadURL();
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }
}
