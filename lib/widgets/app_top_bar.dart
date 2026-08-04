import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'brand_circle.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onInfoPressed;

  const AppTopBar({super.key, required this.title, this.onInfoPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BrandCircle(size: 44, fontSize: 24),
            Text(
              title,
              style: AppTextStyles.screenTitle.copyWith(height: 0.95),
              textAlign: TextAlign.center,
            ),
            IconButton(
              onPressed: onInfoPressed,
              icon: const Icon(Icons.info_outline),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
