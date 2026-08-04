import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:pray_iafcj/firebase_options.dart';
import 'package:pray_iafcj/core/app_navigation.dart';
import 'package:pray_iafcj/core/app_theme.dart';
import 'package:pray_iafcj/screens/about_screen.dart';
import 'package:pray_iafcj/screens/splash.dart';
import 'package:pray_iafcj/screens/welcome/welcome_screen.dart';
import 'package:pray_iafcj/screens/auth/login_screen.dart';
import 'package:pray_iafcj/screens/auth/register_screen.dart';
import 'package:pray_iafcj/screens/home/tab_shell.dart';
import 'package:pray_iafcj/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print("Firebase iniciado correctamente");
  } catch (e, s) {
    print("ERROR FIREBASE:");
    print(e);
    print(s);
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const PrayIAFCJ());
}

class PrayIAFCJ extends StatelessWidget {
  const PrayIAFCJ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pray IAFCJ',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return fadeRoute(const Splash());
          case '/':
          case '/welcome':
            return fadeRoute(const WelcomeScreen());
          case '/login':
            return fadeRoute(const LoginScreen());
          case '/register':
            return fadeRoute(const RegisterScreen());
          case '/home':
            return fadeRoute(const TabShell());
          case '/lectura':
            return fadeRoute(const TabShell(initialIndex: 1));
          case '/oracion':
            return fadeRoute(const TabShell(initialIndex: 2));
          case '/profile':
            return fadeRoute(const TabShell(initialIndex: 3));
          case '/about':
            return fadeRoute(const AboutScreen());
          default:
            return fadeRoute(const WelcomeScreen());
        }
      },
    );
  }
}
