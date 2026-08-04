import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';

class NotificationsCard extends StatefulWidget {
  final bool enabled;
  final TimeOfDay time;
  final ValueChanged<bool>? onChanged;
  final ValueChanged<TimeOfDay>? onTimeChanged;

  const NotificationsCard({
    super.key,
    this.enabled = true,
    this.time = const TimeOfDay(hour: 21, minute: 0),
    this.onChanged,
    this.onTimeChanged,
  });

  @override
  State<NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<NotificationsCard> {
  late bool _enabled;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
    _time = widget.time;
  }

  @override
  void didUpdateWidget(covariant NotificationsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _enabled = widget.enabled;
    }
    if (oldWidget.time != widget.time) {
      _time = widget.time;
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null) {
      setState(() {
        _time = picked;
      });

      widget.onTimeChanged?.call(picked);
    }
  }

  void _toggleNotifications() {
    setState(() {
      _enabled = !_enabled;
    });

    widget.onChanged?.call(_enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Notificaciones",
                  style: AppTextStyles.subtitle
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: _toggleNotifications,
                child: Icon(
                  Icons.check_circle,
                  color: _enabled ? Colors.green : Colors.grey,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.schedule, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Hora del recordatorio", style: AppTextStyles.body),
              ),
              GestureDetector(
                onTap: _selectTime,
                child: Text(
                  _time.format(context),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
