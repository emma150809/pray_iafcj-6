import 'package:flutter/material.dart';

/// Utilidad para mostrar notificaciones de la aplicación.
///
/// Usa el tema global de SnackBar (flotantes y sobre la barra de
/// navegación) y una duración corta.
class AppSnackBar {
  AppSnackBar._();

  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
