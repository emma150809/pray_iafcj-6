import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class BrandCircle extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const BrandCircle({
    super.key,
    required this.size,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'P',
          style: TextStyle(
            fontFamily: 'IMFell',
            color: textColor ?? Colors.black,
            fontSize: fontSize ?? size * 0.48,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
