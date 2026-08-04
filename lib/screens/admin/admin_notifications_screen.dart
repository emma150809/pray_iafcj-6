import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../core/app_text_styles.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_user_card.dart';
import 'widgets/user_display.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  late Future<List<_UserNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadNotifications();
  }

  Future<List<_UserNotification>> _loadNotifications() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final usersSnap = await FirebaseFirestore.instance
        .collection('usuarios')
        .get();

    final usersData = <String, Map<String, dynamic>>{};
    for (final doc in usersSnap.docs) {
      usersData[doc.id] = doc.data();
    }

    final grouped = <String, _UserNotification>{};

    Future<void> process(String group, String type) async {
      final snap = await FirebaseFirestore.instance
          .collectionGroup(group)
          .get();

      for (final doc in snap.docs) {
        final uid = doc.reference.parent.parent!.id;
        final data = doc.data();
        final registrado = data['fechaRegistro'];

        if (registrado is! Timestamp) continue;

        final registradoDate = registrado.toDate();

        if (!registradoDate.isBefore(startOfToday)) {
          grouped
              .putIfAbsent(
                uid,
                () => _UserNotification(
                  uid: uid,
                  userData: usersData[uid] ?? {},
                ),
              )
              .addNewRecord(type, data);
        } else {
          final actualizado = data['fechaActualizacion'];
          if (actualizado is Timestamp &&
              !actualizado.toDate().isBefore(startOfToday)) {
            grouped
                .putIfAbsent(
                  uid,
                  () => _UserNotification(
                    uid: uid,
                    userData: usersData[uid] ?? {},
                  ),
                )
                .updates
                .add({...data, '_type': type});
          }
        }
      }
    }

    await process('oraciones', 'oracion');
    await process('lecturas', 'lectura');

    final list = grouped.values.where((item) => item.badge > 0).toList();
    list.sort((a, b) => b.badge.compareTo(a.badge));
    return list;
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return '';

    final date = value.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');

    return '$day/$month/$year';
  }

  Widget _recordRow({
    required IconData icon,
    required String text,
    required String date,
  }) {
    final s = screenScale(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * s, horizontal: 4 * s),
      child: Row(
        children: [
          Icon(icon, size: 16 * s, color: AppColors.primary),
          SizedBox(width: 8 * s),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text,
                fontSize: 15 * s,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            date,
            style: AppTextStyles.body.copyWith(
              fontSize: 13 * s,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(_UserNotification item) {
    final children = <Widget>[];

    for (final record in item.newOraciones) {
      children.add(
        _recordRow(
          icon: Icons.volunteer_activism,
          text: 'Oraci\u00f3n \u00b7 ${record['tiempoOracion'] ?? ''}',
          date: _formatDate(record['fechaOracion']),
        ),
      );
    }

    for (final record in item.newLecturas) {
      children.add(
        _recordRow(
          icon: Icons.menu_book,
          text: 'Lectura \u00b7 ${record['cita'] ?? ''}',
          date: _formatDate(record['fechaLectura']),
        ),
      );
    }

    for (final record in item.updates) {
      final esOracion = record['_type'] == 'oracion';
      children.add(
        _recordRow(
          icon: Icons.edit_outlined,
          text: esOracion
              ? 'Actualizado \u00b7 ${record['tiempoOracion'] ?? ''}'
              : 'Actualizado \u00b7 ${record['cita'] ?? ''}',
          date: _formatDate(
            esOracion ? record['fechaOracion'] : record['fechaLectura'],
          ),
        ),
      );
    }

    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AdminHeader(subtitle: 'Notificaciones'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(22 * s, 0, 22 * s, 30 * s),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 420 * s),
                  child: FutureBuilder<List<_UserNotification>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'No se pudieron cargar las notificaciones.',
                            style: AppTextStyles.body,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final items = snapshot.data!;

                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay notificaciones nuevas.',
                            style: AppTextStyles.body,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10 * s),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return AdminUserCard(
                            title: displayNameOfUser(item.userData),
                            subtitle: usernameOfUser(item.userData),
                            badge: item.badge,
                            buildContent: (_) => _buildDetails(item),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserNotification {
  final String uid;
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> newOraciones;
  final List<Map<String, dynamic>> newLecturas;
  final List<Map<String, dynamic>> updates;

  _UserNotification({
    required this.uid,
    required this.userData,
  }) : newOraciones = [],
       newLecturas = [],
       updates = [];

  int get badge {
    var count = 0;
    if (newOraciones.isNotEmpty) count++;
    if (newLecturas.isNotEmpty) count++;
    if (updates.isNotEmpty) count++;
    return count;
  }

  void addNewRecord(String type, Map<String, dynamic> data) {
    if (type == 'oracion') {
      newOraciones.add(data);
    } else {
      newLecturas.add(data);
    }
  }
}
