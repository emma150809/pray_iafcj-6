import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../widgets/app_top_bar.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<Map<String, dynamic>> _loadDashboard() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return {'lecturas': 0, 'oraciones': 0, 'recordHora': '21:00'};
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? <String, dynamic>{};

    final lecturasSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('lecturas')
        .get();

    final oracionesSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('oraciones')
        .get();

    return {
      'lecturas': lecturasSnapshot.docs.length,
      'oraciones': oracionesSnapshot.docs.length,
      'recordHora': userData['recordHora'] ?? '21:00',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppTopBar(title: 'Administración', onInfoPressed: () {}),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 100),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _loadDashboard(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'No se pudo cargar el panel administrativo.',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  final lecturas = data['lecturas'] as int;
                  final oraciones = data['oraciones'] as int;
                  final recordHora = data['recordHora'] as String;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumen personal',
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SummaryCard(
                                        icon: Icons.menu_book,
                                        label: 'Lecturas',
                                        value: '$lecturas',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _SummaryCard(
                                        icon: Icons.volunteer_activism,
                                        label: 'Oraciones',
                                        value: '$oraciones',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _InfoTile(
                                  icon: Icons.notifications_active,
                                  label: 'Recordatorio',
                                  value: recordHora,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Acciones rápidas',
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '• Revisa tu historial de lectura y oraciones desde la barra inferior.\n• Mantén actualizado tu recordatorio para una rutina constante.\n• Usa el perfil para administrar tu cuenta personal.',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 20,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.text,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label: $value',
              style: AppTextStyles.body.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
