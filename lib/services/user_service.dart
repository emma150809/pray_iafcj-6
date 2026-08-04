import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'storage_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storage = StorageService();

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String uid) {
    return _firestore.collection('usuarios').doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _firestore.collection('usuarios').doc(uid).get();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('usuarios')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Future<String> uploadProfilePhoto(String uid, File file) {
    return _storage.uploadProfilePhoto(uid, file);
  }
}
