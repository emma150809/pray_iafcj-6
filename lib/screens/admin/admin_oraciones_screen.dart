import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../core/app_text_styles.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_user_card.dart';
import 'widgets/admin_user_records.dart';
import 'widgets/user_display.dart';

class AdminOracionesScreen extends StatelessWidget {
  const AdminOracionesScreen({super.key});

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return '';

    final date = value.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');

    return '$day/$month/$year';
  }

  Widget _buildRecordRow(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final s = screenScale(context);
    final data = doc.data();
    final tiempo = (data['tiempoOracion'] ?? '').toString();
    final fecha = _formatDate(data['fechaOracion']);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * s, horizontal: 4 * s),
      child: Row(
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 16 * s,
            color: AppColors.primary,
          ),
          SizedBox(width: 8 * s),
          Expanded(
            child: Text(
              tiempo,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text,
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            fecha,
            style: AppTextStyles.body.copyWith(
              fontSize: 13 * s,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AdminHeader(subtitle: 'Registros de Oraciones'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(22 * s, 0, 22 * s, 30 * s),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 420 * s),
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('usuarios')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'No se pudieron cargar los usuarios.',
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

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            'A\u00fan no hay usuarios registrados.',
                            style: AppTextStyles.body,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10 * s),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data();

                          return AdminUserCard(
                            title: displayNameOfUser(data),
                            subtitle: usernameOfUser(data),
                            buildContent: (_) => AdminUserRecords(
                              uid: docs[index].id,
                              subcollection: 'oraciones',
                              emptyMessage: 'Sin oraciones registradas.',
                              itemBuilder: _buildRecordRow,
                            ),
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
