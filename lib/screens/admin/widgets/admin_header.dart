import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_responsive.dart';
import '../../../core/app_text_styles.dart';
import '../../../widgets/brand_circle.dart';

class AdminHeader extends StatelessWidget {
  final String? subtitle;
  final Widget? trailing;

  const AdminHeader({super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    final s = screenScale(context);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 82 * s,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                child: BrandCircle(size: 44 * s, fontSize: 24 * s),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Administrador',
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: 32 * s,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 15 * s,
                          color: AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                Positioned(
                  right: 0,
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
