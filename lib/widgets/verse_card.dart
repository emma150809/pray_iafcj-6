import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../data/phrases.dart';

class VerseCard extends StatelessWidget {
  const VerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dayNumber = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

    final frase = AppPhrases.phrases[dayNumber % AppPhrases.phrases.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),

      child: Text(
        frase,

        textAlign: TextAlign.center,

        style: AppTextStyles.body.copyWith(
          fontSize: 20,
          height: 1.5,
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
