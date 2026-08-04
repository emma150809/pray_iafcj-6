import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_responsive.dart';
import '../../core/app_text_styles.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_user_card.dart';
import 'widgets/user_display.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AdminHeader(subtitle: 'Usuarios'),
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

                          final biography = (data['biografia'] ?? '')
                              .toString()
                              .trim();
                          final birthday = (data['cumpleanos'] ?? '')
                              .toString();
                          final age = ageFromBirthday(birthday);
                          final notifications =
                              (data['notificacion'] ?? true) == true;

                          return AdminUserCard(
                            title: displayNameOfUser(data),
                            subtitle: usernameOfUser(data),
                            buildContent: (_) => Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _UserDetailRow(
                                  label: 'Nombre',
                                  value: displayNameOfUser(data),
                                ),
                                _UserDetailRow(
                                  label: 'Usuario',
                                  value: usernameOfUser(data),
                                ),
                                _UserDetailRow(
                                  label: 'Biograf\u00eda',
                                  value: biography.isNotEmpty
                                      ? biography
                                      : 'Sin biograf\u00eda',
                                ),
                                _UserDetailRow(
                                  label: 'Nacimiento',
                                  value: birthday.isNotEmpty
                                      ? birthday
                                      : 'Sin fecha',
                                ),
                                _UserDetailRow(
                                  label: 'Edad',
                                  value: age.isNotEmpty
                                      ? '$age a\u00f1os'
                                      : 'Sin edad',
                                ),
                                _UserDetailRow(
                                  label: 'Notificaciones',
                                  value: notifications
                                      ? 'Activadas'
                                      : 'Desactivadas',
                                ),
                              ],
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

class _UserDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _UserDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110 * s,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 14 * s,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontSize: 14 * s,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
