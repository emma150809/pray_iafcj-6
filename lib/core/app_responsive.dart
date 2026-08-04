import 'package:flutter/material.dart';

/// Ancho de diseño de referencia (teléfono estándar).
const double _designWidth = 390;

/// Factor de escala según el ancho de la pantalla.
///
/// Toma como base un ancho de 390px y se ajusta entre 0.8 (pantallas
/// pequeñas) y 1.4 (tablets), para que fuentes y medidas no se vean
/// desproporcionadas en ningún dispositivo.
double screenScale(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return (width / _designWidth).clamp(0.8, 1.4);
}

/// Tamaño/medida escalado al ancho de la pantalla.
double responsiveSize(BuildContext context, double base) {
  return base * screenScale(context);
}
