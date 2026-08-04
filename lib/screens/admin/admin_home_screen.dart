import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_navigation.dart';
import '../../core/app_responsive.dart';
import '../../core/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'admin_lecturas_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_oraciones_screen.dart';
import 'admin_users_screen.dart';
import 'widgets/admin_header.dart';
import 'widgets/admin_menu_box.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<Map<String, int>> _loadStats() async {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    final users = await FirebaseFirestore.instance
        .collection('usuarios')
        .get();

    final oraciones = await FirebaseFirestore.instance
        .collectionGroup('oraciones')
        .get();
    final lecturas = await FirebaseFirestore.instance
        .collectionGroup('lecturas')
        .get();

    var newToday = 0;
    for (final doc in [...oraciones.docs, ...lecturas.docs]) {
      final value = doc.data()['fechaRegistro'];
      if (value is Timestamp && !value.toDate().isBefore(startOfToday)) {
        newToday++;
      }
    }

    return {
      'usuarios': users.docs.length,
      'nuevosHoy': newToday,
    };
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    pushFadeAndRemoveUntil(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AdminHeader(
            trailing: IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(22 * s, 0, 22 * s, 20 * s),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 420 * s),
                  child: Column(
                    children: [
                      SizedBox(height: 14 * s),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '\u00a1Hola, admin!',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 18 * s,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * s),
                      Expanded(
                        child: FutureBuilder<Map<String, int>>(
                          future: _loadStats(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'No se pudieron cargar los datos.',
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

                            final stats = snapshot.data!;
                            final usuarios = stats['usuarios'] ?? 0;
                            final nuevosHoy = stats['nuevosHoy'] ?? 0;

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  _InfoBanner(
                                    usuarios: usuarios,
                                    nuevosHoy: nuevosHoy,
                                  ),
                                  SizedBox(height: 28 * s),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AdminMenuBox(
                                        icon: Icons.group,
                                        title: 'Usuarios\nregistrados',
                                        onTap: () {
                                          Navigator.of(context).push(
                                            fadeRoute(
                                              const AdminUsersScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: 20 * s),
                                      AdminMenuBox(
                                        icon: Icons.volunteer_activism,
                                        title: 'Registros de\noraciones',
                                        onTap: () {
                                          Navigator.of(context).push(
                                            fadeRoute(
                                              const AdminOracionesScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20 * s),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: AdminMenuBox(
                                      icon: Icons.menu_book,
                                      title: 'Registros de\nlectura',
                                      onTap: () {
                                        Navigator.of(context).push(
                                          fadeRoute(
                                            const AdminLecturasScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

class _InfoBanner extends StatelessWidget {
  final int usuarios;
  final int nuevosHoy;

  const _InfoBanner({required this.usuarios, required this.nuevosHoy});

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16 * s),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            fadeRoute(const AdminNotificationsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16 * s),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 14 * s,
            horizontal: 16 * s,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * s),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 24 * s,
              ),
              SizedBox(width: 10 * s),
              Expanded(
                child: Text(
                  'usuarios $usuarios, registros nuevos $nuevosHoy',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 16 * s,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 24 * s,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
