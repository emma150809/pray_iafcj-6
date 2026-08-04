import 'package:flutter/material.dart';
import 'package:pray_iafcj/core/app_colors.dart';
import 'package:pray_iafcj/core/app_text_styles.dart';
import 'package:pray_iafcj/widgets/brand_circle.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  BrandCircle(size: 44, fontSize: 26),
                  const SizedBox(width: 12),
                  Text(
                    'Sobre la aplicación',
                    style: AppTextStyles.screenTitle.copyWith(height: 0.95),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  BrandCircle(
                    size: MediaQuery.of(context).size.width * 0.28,
                    fontSize: 42,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Desarrollada con fines espirituales para mayor constancia en los reportes de oración y lectura, fomentando los buenos hábitos espirituales en los jóvenes y personas que usan la aplicación.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Desarrollada por: Emma Orix',
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versión: 1.0.0',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Pray',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Text(
                    'Dudas o sugerencias, comuníquese personalmente con la administradora al +61 4733 3342.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
