import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

///============================================================
/// Botón oficial de Pray IAFCJ.
///
/// Todos los botones de la aplicación usarán este diseño.
///============================================================
class AppButton extends StatelessWidget {
  // Texto del botón.
  final String text;

  // Acción al presionarlo.
  final VoidCallback onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // Color del botón.
        backgroundColor: AppColors.primary,

        // Texto negro.
        foregroundColor: Colors.black,

        // Sin sombra.
        elevation: 0,

        // Bordes redondeados.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
