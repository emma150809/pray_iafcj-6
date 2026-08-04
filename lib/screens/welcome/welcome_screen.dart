import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_navigation.dart';
import '../../core/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/brand_circle.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final logoSize = isMobile
        ? (size.width * 0.48).clamp(150.0, 210.0)
        : (size.width * 0.24).clamp(150.0, 220.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.09,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BrandCircle(size: logoSize),

                  const SizedBox(height: 18),

                  Text('Pray IAFCJ', style: AppTextStyles.appTitle),

                  const SizedBox(height: 24),

                  Text(
                    'Registro de oración y\nlectura bíblica personal',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: size.width < 600 ? double.infinity : 280,
                    child: AppButton(
                      text: 'Continuar',
                      onPressed: () {
                        Navigator.push(
                          context,
                          fadeRoute(const LoginScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
