import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_navigation.dart';
import '../core/app_text_styles.dart';
import '../services/notification_service.dart';
import '../widgets/brand_circle.dart';
import 'admin/admin_home_screen.dart';
import 'home/tab_shell.dart';
import 'welcome/welcome_screen.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      NotificationService.initialize();

      var isAdmin = false;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        isAdmin = (doc.data()?['role'] ?? 'user').toString() == 'admin';
      } catch (_) {}

      if (!mounted) return;

      final page = isAdmin ? const AdminHomeScreen() : const TabShell();

      Navigator.of(context).pushAndRemoveUntil(
        fadeRoute(page),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        fadeRoute(const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BrandCircle(size: 155, fontSize: 72),
            const SizedBox(height: 25),
            Text('Pray IAFCJ', style: AppTextStyles.appTitle),
          ],
        ),
      ),
    );
  }
}
