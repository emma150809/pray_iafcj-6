import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

///==============================================================
/// Servicio de autenticación.
///
/// Se encarga de:
/// - Registrar usuarios.
/// - Iniciar sesión.
/// - Cerrar sesión.
/// - Obtener el usuario actual.
///==============================================================
class AuthService {
  //============================================================
  // Instancias de Firebase.
  //============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  //============================================================
  // Convierte el nombre de usuario en un correo interno.
  //
  // Ejemplo:
  //
  // @emma
  //
  // se convierte en
  //
  // emma@prayiafcj.app
  //============================================================

  String _usernameToEmail(String username) {
    username = username.trim();

    if (username.startsWith("@")) {
      username = username.substring(1);
    }

    return "$username@prayiafcj.app";
  }

  //============================================================
  // Registrar usuario.
  //============================================================

  Future<void> register({
    required String username,

    required String password,

    required String nombre,

    required String apellido,

    required String cumpleanos,
  }) async {
    // Genera el correo interno.
    final email = _usernameToEmail(username);

    // Crea la cuenta en Firebase Authentication.
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,

      password: password,
    );

    // Guarda información adicional en Firestore.
    await _firestore.collection("usuarios").doc(credential.user!.uid).set({
      "uid": credential.user!.uid,

      "username": username,

      "nombre": nombre,

      "apellido": apellido,

      "cumpleanos": cumpleanos,

      "biografia": "",

      "foto": "",

      "notificacion": true,

      "recordHora": "21:00",

      "fechaRegistro": Timestamp.now(),

      "role": "user",
    });
  }

  //============================================================
  // Iniciar sesión.
  //============================================================

  Future<void> login({
    required String username,

    required String password,
  }) async {
    final email = _usernameToEmail(username);

    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  //============================================================
  // Cerrar sesión.
  //============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }

  //============================================================
  // Usuario actualmente autenticado.
  //============================================================

  User? get currentUser {
    return _auth.currentUser;
  }

  //============================================================
  // Obtener datos del usuario desde Firestore.
  //============================================================
  Future<DocumentSnapshot?> getUserData() async {
    final user = currentUser;
    if (user == null) {
      return null;
    }
    return await _firestore.collection('usuarios').doc(user.uid).get();
  }

  //============================================================
  // Actualizar foto de perfil.
  //============================================================
  Future<String> updateProfilePicture(File imageFile) async {
    final user = currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado.");
    }

    // 1. Crear una referencia en Firebase Storage
    final ref = _storage
        .ref()
        .child('profile_pictures')
        .child('${user.uid}.jpg');

    // 2. Subir el archivo
    await ref.putFile(imageFile);

    // 3. Obtener la URL de descarga
    final downloadUrl = await ref.getDownloadURL();

    // 4. Actualizar el documento del usuario en Firestore
    await _firestore.collection('usuarios').doc(user.uid).update({
      'foto': downloadUrl,
    });

    return downloadUrl;
  }
}
