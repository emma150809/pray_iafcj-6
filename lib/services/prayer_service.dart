import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrayerService {
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
        .collection('oraciones');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPrayers() {
    return _collection().orderBy('fechaRegistro', descending: true).snapshots();
  }

  Future<void> deletePrayer(String id) async {
    await _collection().doc(id).delete();
  }

  Duration _parseDuration(String time) {
    final parts = time.replaceAll(' ', '').toLowerCase().split('h');
    final hours = parts.first.isEmpty ? 0 : int.tryParse(parts.first) ?? 0;
    final minutesPart = parts.length > 1 ? parts[1].replaceAll('m', '') : '0';
    final minutes = int.tryParse(minutesPart) ?? 0;
    return Duration(hours: hours, minutes: minutes);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _findExisting(
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final snap = await _collection()
        .where('fechaOracion', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('fechaOracion', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first;
  }

  Future<void> savePrayer({
    String? id,
    DateTime? fechaOracion,
    required String tiempoOracion,
  }) async {
    final now = Timestamp.now();
    final selectedDate = fechaOracion ?? now.toDate();
    final newTime = tiempoOracion.trim().isEmpty ? '0h 15m' : tiempoOracion.trim();

    if (id == null) {
      final existing = await _findExisting(selectedDate);

      if (existing != null) {
        final existingData = existing.data()!;
        final existingTime = (existingData['tiempoOracion'] ?? '0h 0m').toString();
        final total = _parseDuration(existingTime) + _parseDuration(newTime);

        await _collection().doc(existing.id).update({
          'tiempoOracion': _formatDuration(total),
          'fechaActualizacion': now,
        });
        return;
      }

      await _collection().add({
        'tiempoOracion': newTime,
        'fechaOracion': Timestamp.fromDate(selectedDate),
        'fechaRegistro': now,
        'fechaActualizacion': now,
      });
      return;
    }

    await _collection().doc(id).update({
      'tiempoOracion': newTime,
      'fechaOracion': Timestamp.fromDate(selectedDate),
      'fechaActualizacion': now,
    });
  }
}
