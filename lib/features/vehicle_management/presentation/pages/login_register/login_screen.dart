// lib/features/vehicle_management/presentation/pages/login_register/login_screen.dart

import 'package:flutter/material.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/repository/profile_repository.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/register_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/profile/profile_screen2.dart';

import '../../../data/remote/auth_service.dart';
import '../../../data/remote/user_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Instanciación del repositorio con sus dependencias
    final profileRepository = ProfileRepository(
      authService: AuthService(),
      profileService: ProfileService(),
      userService: UserService(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1E1F24),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset('assets/images/login_logo.png', height: 120),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                context,
                controller: emailController,
                hintText: 'Usuario (Email)',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                context,
                controller: passwordController,
                hintText: 'Contraseña',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _buildLoginButton(
                context,
                emailController,
                passwordController,
                profileRepository,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const RegisterScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  child: const Text(
                    "¿No tienes cuenta? - Regístrate",
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  Widget _buildLoginButton(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController,
      ProfileRepository profileRepository,
      ) {
    return ElevatedButton(
      onPressed: () async {
        if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
          showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
          try {
            final loginResult = await profileRepository.loginAndGetProfile(
              emailController.text,
              passwordController.text,
            );

            Navigator.pop(context); // Cierra el dialogo de carga

            if (loginResult != null) {
              final user = loginResult.$1;
              final profile = loginResult.$2;

              Widget targetScreen;
              if (user.role == 'manager') {
                targetScreen = ProfileScreen(
                  userId: user.id,
                  email: user.email,
                  name: profile.name,
                  lastName: profile.lastName,
                );
              } else if (user.role == 'Transportista') {
                targetScreen = ProfileScreen2(
                  userId: profile.id,
                  name: profile.name,
                  lastName: profile.lastName,
                );
              } else {
                _showSnackbar(context, 'Rol de usuario no reconocido.', Colors.orange);
                return;
              }

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(targetScreen: targetScreen),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );

            } else {
              _showSnackbar(context, 'Usuario o contraseña incorrecta', Colors.red);
            }
          } catch (e) {
            Navigator.pop(context);
            _showSnackbar(context, 'Error de conexión. Inténtalo de nuevo.', Colors.red);
            print('Error en el login: $e');
          }
        } else {
          _showSnackbar(context, 'Por favor ingrese usuario y contraseña', Colors.orange);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEA8E00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('INGRESAR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final Widget targetScreen;

  const WelcomeScreen({Key? key, required this.targetScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E1F24),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/login_logo.png', height: 100),
            const SizedBox(height: 20),
            const Text(
              'BIENVENIDO',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}