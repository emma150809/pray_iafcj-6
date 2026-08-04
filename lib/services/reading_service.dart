import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/bible_books.dart';

class ReadingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado.');
    }

    return _firestore
        .collection('usuarios')
        .doc(user.uid)
        .collection('lecturas');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamReadings() {
    return _collection().orderBy('fechaRegistro', descending: true).snapshots();
  }

  Future<void> deleteReading(String id) async {
    await _collection().doc(id).delete();
  }

  Future<void> saveReading({
    String? id,
    required String testamento,
    required String libro,
    required int capitulo,
    required int capituloFin,
    required int versiculoInicio,
    required int versiculoFin,
    DateTime? fechaLectura,
  }) async {
    final now = Timestamp.now();
    final selectedDate = fechaLectura ?? now.toDate();
    final data = {
      'testamento': testamento,
      'libro': libro,
      'capitulo': capitulo,
      'capituloFin': capituloFin,
      'versiculoInicio': versiculoInicio,
      'versiculoFin': versiculoFin,
      'cita': _buildCita(
        libro,
        capitulo,
        capituloFin,
        versiculoInicio,
        versiculoFin,
      ),
      'fechaActualizacion': now,
    };

    if (id == null) {
      await _collection().add({
        ...data,
        'fechaLectura': Timestamp.fromDate(selectedDate),
        'fechaRegistro': now,
      });
      return;
    }

    await _collection().doc(id).update({
      ...data,
      'fechaLectura': Timestamp.fromDate(selectedDate),
    });
  }

  String _buildCita(
    String libro,
    int capitulo,
    int capituloFin,
    int versiculoInicio,
    int versiculoFin,
  ) {
    final maxVerses = BibleBooks.find(libro)?.verseCountForChapter(capituloFin);
    final capituloCompleto =
        versiculoInicio == 1 && versiculoFin == maxVerses;

    if (capitulo == capituloFin) {
      return capituloCompleto
          ? '$libro $capitulo'
          : '$libro $capitulo:$versiculoInicio-$versiculoFin';
    }

    return capituloCompleto
        ? '$libro $capitulo-$capituloFin'
        : '$libro $capitulo-$capituloFin:$versiculoInicio-$versiculoFin';
  }
}
