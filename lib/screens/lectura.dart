import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/app_text_styles.dart';
import '../services/reading_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/reading_record_dialog.dart';

class LecturaScreen extends StatelessWidget {
  const LecturaScreen({super.key});

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
    final saved = await showReadingRecordDialog(
      context,
      recordId: recordId,
      initialData: data,
    );

    if (saved != true || !context.mounted) return;

    AppSnackBar.show(context, 'Registro de lectura guardado.');
  }

  Future<void> _deleteRecord(BuildContext context, String recordId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar registro'),
          content: const Text(
            '\u00bfSeguro que deseas eliminar este registro de lectura?',
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

    await ReadingService().deleteReading(recordId);
    if (!context.mounted) return;

    AppSnackBar.show(context, 'Registro de lectura eliminado.');
  }

  Widget _buildRow(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final cita = data['cita'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 2, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              cita,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _openEditor(context, recordId: doc.id, data: data),
            icon: const Icon(Icons.edit),
            color: AppColors.primary,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            onPressed: () => _deleteRecord(context, doc.id),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppTopBar(
            title: 'Historial de\nLecturas',
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
                                stream: ReadingService().streamReadings(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        'No se pudieron cargar las lecturas.',
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
                                        'A\u00fan no hay lecturas registradas.',
                                        style: AppTextStyles.body,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  final grouped =
                                      <
                                        String,
                                        List<
                                          QueryDocumentSnapshot<
                                            Map<String, dynamic>
                                          >
                                        >
                                      >{};

                                  for (final doc in docs) {
                                    final date = _formatDate(
                                      doc.data()['fechaLectura'],
                                    );
                                    grouped.putIfAbsent(date, () => []).add(doc);
                                  }

                                  final groups = grouped.entries.toList();

                                  return ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: groups.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(
                                          height: 1,
                                          color: AppColors.primary,
                                        ),
                                    itemBuilder: (context, index) {
                                      final records = groups[index].value;

                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          dividerColor: Colors.transparent,
                                          listTileTheme:
                                              const ListTileThemeData(
                                                dense: true,
                                              ),
                                        ),
                                        child: ExpansionTile(
                                          shape: const Border(),
                                          collapsedShape: const Border(),
                                          tilePadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 6,
                                              ),
                                          childrenPadding: EdgeInsets.zero,
                                          leading: const Icon(
                                            Icons.calendar_month,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                          title: Text(
                                            groups[index].key,
                                            style: AppTextStyles.body
                                                .copyWith(
                                                  color: AppColors.text,
                                                  fontSize: 17,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                          ),
                                          subtitle: Text(
                                            '${records.length} '
                                            'registro'
                                            '${records.length == 1 ? '' : 's'}',
                                            style: AppTextStyles.body
                                                .copyWith(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.secondaryText,
                                                ),
                                          ),
                                          children: [
                                            for (final doc in records)
                                              _buildRow(context, doc),
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
