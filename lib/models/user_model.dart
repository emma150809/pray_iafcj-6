import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String nombre;
  final String apellido;
  final DateTime cumpleanos;
  final String biografia;
  final String? foto;
  final bool notificacion;
  final String recordHora;
  final int notificationHour;
  final int notificationMinute;
  final bool stickerPastel;
  final bool stickerBrillos;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.nombre,
    required this.apellido,
    required this.cumpleanos,
    required this.biografia,
    this.foto,
    required this.notificacion,
    required this.recordHora,
    required this.notificationHour,
    required this.notificationMinute,
    required this.stickerPastel,
    required this.stickerBrillos,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'nombre': nombre,
      'apellido': apellido,
      'cumpleanos': Timestamp.fromDate(cumpleanos),
      'biografia': biografia,
      'foto': foto,
      'notificacion': notificacion,
      'recordHora': recordHora,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
      'sticker_pastel': stickerPastel,
      'sticker_brillos': stickerBrillos,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      cumpleanos: map['cumpleanos'] is Timestamp
          ? (map['cumpleanos'] as Timestamp).toDate()
          : DateTime.tryParse(map['cumpleanos'] ?? '') ?? DateTime(1970),
      biografia: map['biografia'] ?? '',
      foto: map['foto'],
      notificacion: map['notificacion'] ?? true,
      recordHora: map['recordHora'] ?? '21:00',
      notificationHour: map['notificationHour'] ?? 21,
      notificationMinute: map['notificationMinute'] ?? 0,
      stickerPastel: map['sticker_pastel'] ?? false,
      stickerBrillos: map['sticker_brillos'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }
}
