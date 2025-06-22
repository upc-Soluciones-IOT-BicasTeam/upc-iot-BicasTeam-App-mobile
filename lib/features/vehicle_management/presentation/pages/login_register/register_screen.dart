import 'package:flutter/material.dart';

import 'package:movigestion_mobile/features/vehicle_management/data/remote/auth_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/user_service.dart';
import '../../../data/repository/profile_repository.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final ProfileRepository profileRepository = ProfileRepository(
    authService: AuthService(),
    profileService: ProfileService(),
    userService: UserService(),
  );

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Future<void> _handleRegister() async {
    final success = await profileRepository.registerUserAndProfile(
      name: nameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: 'manager', // Fijo para gerentes
      telephone: phoneController.text.trim(),
    );

    if (success) {
      _showSnackbar('Registro exitoso. Ahora puedes iniciar sesión.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      _showSnackbar('Error al registrarse.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F24),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/login_logo.png', height: 100),
              const SizedBox(height: 40),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre', filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido', filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono', filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleRegister,
                child: const Text('Registrarse'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA8E00)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
