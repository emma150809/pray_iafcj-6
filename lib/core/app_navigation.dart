import 'package:flutter/material.dart';

/// Ruta con transición de desvanecido suave.
Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}

/// Reemplaza todo el stack de navegación con [page] usando
/// una transición de desvanecido suave.
Future<void> pushFadeAndRemoveUntil(BuildContext context, Widget page) {
  return Navigator.of(context).pushAndRemoveUntil(
    fadeRoute(page),
    (route) => false,
  );
}
