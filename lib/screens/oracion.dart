import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/app_text_styles.dart';
import '../services/prayer_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/prayer_record_dialog.dart';

class OracionScreen extends StatelessWidget {
  const OracionScreen({super.key});

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return '';

    final date = value.toDate();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');

    return '$day/$month/$year';
  }

  Future<void> _openEditor(
    BuildContext context, {
    String? recordId,
    Map<String, dynamic>? data,
  }) async {
    final saved = await showPrayerRecordDialog(
      context,
      recordId: recordId,
      initialData: data,
    );

    if (saved != true || !context.mounted) return;

    AppSnackBar.show(context, 'Registro de oraci\u00f3n guardado.');
  }

  Future<void> _deleteRecord(BuildContext context, String recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar registro'),
          content: const Text(
            '\u00bfSeguro que deseas eliminar este registro de oraci\u00f3n?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await PrayerService().deletePrayer(recordId);
    if (!context.mounted) return;

    AppSnackBar.show(context, 'Registro de oraci\u00f3n eliminado.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'Historial de\nOraciones',
            onInfoPressed: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 340,
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child:
                              StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>
                              >(
                                stream: PrayerService().streamPrayers(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        'No se pudieron cargar las oraciones.',
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
                                        'A\u00fan no hay oraciones registradas.',
                                        style: AppTextStyles.body,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: docs.length,
                                    separatorBuilder: (_, _) => const Divider(
                                      height: 1,
                                      color: AppColors.primary,
                                    ),
                                    itemBuilder: (context, index) {
                                      final doc = docs[index];
                                      final data = doc.data();
                                      final tiempo =
                                          data['tiempoOracion'] as String? ??
                                          '';
                                      final date = _formatDate(
                                        data['fechaOracion'],
                                      );

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 6,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tiempo,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles.body
                                                        .copyWith(
                                                          color: AppColors.text,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.calendar_month,
                                                        size: 16,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        date,
                                                        style: AppTextStyles
                                                            .body
                                                            .copyWith(
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .text,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _openEditor(
                                                context,
                                                recordId: doc.id,
                                                data: data,
                                              ),
                                              icon: const Icon(Icons.edit),
                                              color: AppColors.primary,
                                              iconSize: 16,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _deleteRecord(
                                                context,
                                                doc.id,
                                              ),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              color: AppColors.error,
                                              iconSize: 16,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 24,
                                                minHeight: 24,
                                              ),
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
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: () => _openEditor(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.border),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Agregar Registro Nuevo',
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                          ),
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
