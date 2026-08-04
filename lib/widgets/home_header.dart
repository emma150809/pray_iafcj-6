import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'brand_circle.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get(),

      builder: (context, snapshot) {
        String nombre = "Usuario";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          nombre = data["nombre"] ?? "Usuario";
        }

        const logoSize = 44.0;

        return Row(
          children: [
            //-------------------------------------------------
            // Logo
            //-------------------------------------------------
            BrandCircle(size: logoSize),

            const SizedBox(width: 12),

            //-------------------------------------------------
            // Saludo
            //-------------------------------------------------
            Expanded(
              child: Text(
                "¡Hola, $nombre!",
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.text,
                  fontSize: 26,
                ),
              ),
            ),

            //-------------------------------------------------
            // Botón información
            //-------------------------------------------------
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
              icon: const Icon(Icons.info_outline),
              color: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
}
