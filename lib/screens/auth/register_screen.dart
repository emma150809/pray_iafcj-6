import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Colores de la aplicación
import '../../core/app_colors.dart';

// Notificaciones de la aplicación
import '../../core/app_snackbar.dart';

// Estilos de texto
import '../../core/app_text_styles.dart';

// Servicio de autenticación
import '../../services/auth_service.dart';

// Botón personalizado
import '../../widgets/app_button.dart';

// Campo de texto personalizado
import '../../widgets/app_text_field.dart';

///==============================================================
/// Pantalla de Registro
///==============================================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //==============================================================
  // Controladores de cada campo de texto.
  // Permiten obtener lo que escribe el usuario.
  //==============================================================

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  final nameController = TextEditingController();

  final lastnameController = TextEditingController();

  final birthdayController = TextEditingController();

  final _authService = AuthService();

  //==============================================================
  // Liberamos la memoria cuando se cierre la pantalla.
  //==============================================================

  @override
  void dispose() {
    usernameController.dispose();

    passwordController.dispose();

    nameController.dispose();

    lastnameController.dispose();

    birthdayController.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    AppSnackBar.show(context, message);
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      birthdayController.text =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";
    }
  }

  Future<void> _registerUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final nombre = nameController.text.trim();
    final apellido = lastnameController.text.trim();
    final cumpleanos = birthdayController.text.trim();

    if (username.isEmpty) {
      _showMessage("Escribe un nombre de usuario.");
      return;
    }

    final regex = RegExp(r'^@[a-zA-Z0-9_]{3,20}$');

    if (!regex.hasMatch(username)) {
      _showMessage(
        "El usuario debe comenzar con @ y contener solo letras, números o _.",
      );
      return;
    }

    if (password.length < 6) {
      _showMessage("La contraseña debe tener al menos 6 caracteres.");
      return;
    }

    if (nombre.isEmpty) {
      _showMessage("Escribe tu nombre.");
      return;
    }

    if (apellido.isEmpty) {
      _showMessage("Escribe tu apellido.");
      return;
    }

    if (cumpleanos.isEmpty) {
      _showMessage("Escribe tu cumpleaños.");
      return;
    }

    try {
      await _authService.register(
        username: username,
        password: password,
        nombre: nombre,
        apellido: apellido,
        cumpleanos: cumpleanos,
      );

      if (!mounted) return;

      _showMessage("¡Cuenta creada correctamente!");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String mensaje;

      switch (e.code) {
        case 'weak-password':
          mensaje = "La contraseña es demasiado débil.";
          break;
        case 'email-already-in-use':
          mensaje = "Ese nombre de usuario ya está registrado.";
          break;
        case 'invalid-email':
          mensaje = "Nombre de usuario no válido.";
          break;
        case 'operation-not-allowed':
          mensaje = "El registro no está disponible por ahora.";
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
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),

            child: Column(
              children: [
                //--------------------------------------------------
                // Título
                //--------------------------------------------------
                Text("Regístrate", style: AppTextStyles.appTitle),

                const SizedBox(height: 30),

                //--------------------------------------------------
                // Tarjeta blanca
                //--------------------------------------------------
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Column(
                    children: [
                      //------------------------------------------------
                      // Usuario
                      //------------------------------------------------
                      AppTextField(
                        controller: usernameController,

                        hintText: "Crea un nombre de usuario",

                        fillColor: AppColors.background,
                      ),

                      const SizedBox(height: 12),

                      //------------------------------------------------
                      // Contraseña
                      //------------------------------------------------
                      AppTextField(
                        controller: passwordController,

                        hintText: "Crea una contraseña",

                        obscureText: true,

                        showPasswordIcon: true,

                        fillColor: AppColors.background,
                      ),

                      const SizedBox(height: 12),

                      //------------------------------------------------
                      // Nombre
                      //------------------------------------------------
                      AppTextField(
                        controller: nameController,

                        hintText: "Nombre",

                        fillColor: AppColors.background,
                      ),

                      const SizedBox(height: 12),

                      //------------------------------------------------
                      // Apellido
                      //------------------------------------------------
                      AppTextField(
                        controller: lastnameController,

                        hintText: "Apellido",

                        fillColor: AppColors.background,
                      ),

                      const SizedBox(height: 12),

                      //------------------------------------------------
                      // Cumpleaños
                      //------------------------------------------------
                      AppTextField(
                        controller: birthdayController,
                        hintText: "Fecha de nacimiento",
                        fillColor: AppColors.background,
                        readOnly: true,
                        onTap: _selectBirthDate,
                      ),

                      const SizedBox(height: 35),

                      //------------------------------------------------
                      // Botón Registrar
                      //------------------------------------------------
                      AppButton(text: "Registrarse", onPressed: _registerUser),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
