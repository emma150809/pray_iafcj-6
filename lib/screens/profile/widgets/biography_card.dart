import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';

class BiographyCard extends StatelessWidget {
  final String biography;
  final VoidCallback? onTap;

  const BiographyCard({
    super.key,
    this.biography =
        "Pertenezco al grupo de alabanza,\nme gustan los cheetos flamin hot y la Arizona. ❤️\nMe gusta cantar y sigo mejorando.",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Biografía",
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(biography, style: AppTextStyles.body),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.edit, color: AppColors.primary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
