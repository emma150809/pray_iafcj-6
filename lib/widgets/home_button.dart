import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class HomeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const HomeButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        width: 155,

        child: Column(
          children: [
            //----------------------------------------------------------
            // Cuadro del icono
            //----------------------------------------------------------
            Container(
              width: 132,
              height: 150,

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(28),

                border: Border.all(color: AppColors.border, width: 1.2),
              ),

              child: Center(
                child: Icon(icon, size: 68, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 15),

            //----------------------------------------------------------
            // Texto
            //----------------------------------------------------------
            Text(
              title,

              textAlign: TextAlign.center,

              style: AppTextStyles.body.copyWith(
                fontSize: 17,
                height: 1.4,
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
