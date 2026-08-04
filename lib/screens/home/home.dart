import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_snackbar.dart';
import '../../widgets/home_button.dart';
import '../../widgets/home_header.dart';
import '../../widgets/prayer_record_dialog.dart';
import '../../widgets/reading_record_dialog.dart';
import '../../widgets/verse_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openReadingRecord(BuildContext context) async {
    final saved = await showReadingRecordDialog(context);

    if (saved != true || !context.mounted) return;

    AppSnackBar.show(context, 'Registro de lectura guardado.');
  }

  Future<void> _openPrayerRecord(BuildContext context) async {
    final saved = await showPrayerRecordDialog(context);

    if (saved != true || !context.mounted) return;

    AppSnackBar.show(context, 'Registro de oraci\u00f3n guardado.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: Column(
            children: [
              const HomeHeader(),
              const SizedBox(height: 45),
              const VerseCard(),
              const SizedBox(height: 80),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: HomeButton(
                      icon: Icons.menu_book,
                      title: 'Agregar registro\nlectura b\u00edblica',
                      onTap: () => _openReadingRecord(context),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: HomeButton(
                      icon: Icons.volunteer_activism,
                      title: 'Agregar registro\nde oraci\u00f3n',
                      onTap: () => _openPrayerRecord(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
