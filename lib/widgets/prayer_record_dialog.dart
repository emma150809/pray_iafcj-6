import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../services/prayer_service.dart';

Future<bool?> showPrayerRecordDialog(
  BuildContext context, {
  String? recordId,
  Map<String, dynamic>? initialData,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) =>
        _PrayerRecordDialog(recordId: recordId, initialData: initialData),
  );
}

class _PrayerRecordDialog extends StatefulWidget {
  final String? recordId;
  final Map<String, dynamic>? initialData;

  const _PrayerRecordDialog({this.recordId, this.initialData});

  @override
  State<_PrayerRecordDialog> createState() => _PrayerRecordDialogState();
}

class _PrayerRecordDialogState extends State<_PrayerRecordDialog> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();

  String? _errorText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;
    if (data == null) {
      final now = DateTime.now();
      _dateController.text =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      _hoursController.clear();
      _minutesController.clear();
      return;
    }

    final fecha = data['fechaOracion'];
    if (fecha != null) {
      final date = fecha is DateTime ? fecha : (fecha as dynamic).toDate();
      _dateController.text =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    final tiempo = (data['tiempoOracion'] ?? data['horaOracion'] ?? '0h 15m')
        .toString();
    final parts = tiempo.replaceAll(' ', '').toLowerCase().split('h');
    final hours = parts.first.isEmpty ? 0 : int.tryParse(parts.first) ?? 0;
    final minutesPart = parts.length > 1 ? parts[1].replaceAll('m', '') : '0';
    final minutes = int.tryParse(minutesPart) ?? 0;

    _hoursController.text = '$hours';
    _minutesController.text = '$minutes';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  DateTime? _parseDate() {
    final parts = _dateController.text.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return null;

    return DateTime(year, month, day);
  }

  Future<void> _save() async {
    final fechaOracion = _parseDate();
    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    if (fechaOracion == null) {
      setState(() => _errorText = 'Selecciona una fecha válida.');
      return;
    }

    if (hours == 0 && minutes == 0) {
      setState(() => _errorText = 'Escribe una duración válida.');
      return;
    }

    final tiempoOracion = '${hours}h ${minutes}m';

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await PrayerService().savePrayer(
        id: widget.recordId,
        fechaOracion: fechaOracion,
        tiempoOracion: tiempoOracion,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _errorText = 'No se pudo guardar el registro. Int\u00e9ntalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Registro de oraci\u00f3n',
                style: AppTextStyles.body.copyWith(fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: IgnorePointer(
                      child: TextField(
                        controller: _dateController,
                        style: AppTextStyles.body.copyWith(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Fecha',
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tiempo de oración',
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body.copyWith(fontSize: 16),
                    decoration: const InputDecoration(hintText: 'Horas'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.body.copyWith(fontSize: 16),
                    decoration: const InputDecoration(hintText: 'Minutos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: AppTextStyles.body.copyWith(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Text(
                      _saving ? 'Guardando...' : 'Guardar',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
