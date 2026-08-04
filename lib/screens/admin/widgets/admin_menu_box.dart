import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_responsive.dart';
import '../../../core/app_text_styles.dart';

class AdminMenuBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AdminMenuBox({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 155 * s,
        child: Column(
          children: [
            Container(
              width: 132 * s,
              height: 150 * s,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28 * s),
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              child: Center(
                child: Icon(icon, size: 68 * s, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 16 * s,
                height: 1.3,
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
