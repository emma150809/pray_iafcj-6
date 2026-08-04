import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_navigation.dart';
import '../../core/app_snackbar.dart';
import '../../core/app_text_styles.dart';
import '../../screens/admin/admin_home_screen.dart';
import '../../screens/home/tab_shell.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_circle.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    AppSnackBar.show(context, message);
  }

  Future<void> _loginUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      _showMessage("Escribe tu nombre de usuario.");
      return;
    }

    if (password.isEmpty) {
      _showMessage("Escribe tu contraseña.");
      return;
    }

    try {
      await _authService.login(username: username, password: password);

      NotificationService.initialize();

      if (!mounted) return;

      final userData = await _authService.getUserData();
      final userDoc = userData?.data() as Map<String, dynamic>?;
      final role = userDoc?['role'];

      _showMessage("¡Bienvenido!");

      if (role == 'admin') {
        pushFadeAndRemoveUntil(context, const AdminHomeScreen());
      } else {
        pushFadeAndRemoveUntil(context, const TabShell());
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;

      switch (e.code) {
        case 'user-not-found':
          mensaje = "No existe una cuenta con ese usuario.";
          break;
        case 'wrong-password':
          mensaje = "Contraseña incorrecta.";
          break;
        case 'invalid-credential':
          mensaje = "Usuario o contraseña incorrectos.";
          break;
        case 'invalid-email':
          mensaje = "Nombre de usuario no válido.";
          break;
        case 'user-disabled':
          mensaje = "Esa cuenta ha sido deshabilitada.";
          break;
        case 'too-many-requests':
          mensaje = "Demasiados intentos. Inténtalo más tarde.";
          break;
        case 'network-request-failed':
          mensaje = "Problema de conexión. Revisa tu internet.";
          break;
        default:
          mensaje = "Ocurrió un error. Inténtalo de nuevo.";
      }

      _showMessage(mensaje);
    } catch (_) {
      _showMessage("Ocurrió un error. Inténtalo de nuevo.");
    }
  }

  @override
  Widget build(BuildContext context) {
    const logoSize = 44.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BrandCircle(size: logoSize),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      "Inicio de Sesión",
                      style: AppTextStyles.appTitle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 90),
              AppTextField(
                controller: usernameController,
                hintText: "Nombre de usuario",
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: passwordController,
                hintText: "Contraseña",
                obscureText: true,
                showPasswordIcon: true,
              ),
              const SizedBox(height: 25),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, fadeRoute(const RegisterScreen()));
                  },
                  child: Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: AppTextStyles.body.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: AppButton(text: "Continuar", onPressed: _loginUser),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
