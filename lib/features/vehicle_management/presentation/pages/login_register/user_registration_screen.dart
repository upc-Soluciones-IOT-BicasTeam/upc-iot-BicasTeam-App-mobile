// lib/features/vehicle_management/presentation/pages/login_register/user_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/repository/profile_repository.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/profile/profile_screen2.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';

import '../../../data/remote/auth_service.dart';
import '../../../data/remote/user_service.dart';

class UserRegistrationScreen extends StatefulWidget {
  final String selectedRole;

  const UserRegistrationScreen({
    Key? key,
    required this.selectedRole,
  }) : super(key: key);

  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;

  late final ProfileRepository _profileRepository;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository(
      authService: AuthService(),
      profileService: ProfileService(),
      userService: UserService(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistrationForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        _showSnackbar('Debes aceptar los Términos y Condiciones', Colors.orange);
        return;
      }

      showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final success = await _profileRepository.registerUserAndProfile(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: widget.selectedRole,
      );

      Navigator.pop(context); // Cierra el indicador de carga

      if (success) {
        _showSnackbar('Registro exitoso', Colors.green);
        await Future.delayed(const Duration(seconds: 1));
        _navigateBasedOnRole();
      } else {
        _showSnackbar('Error en el registro. El email podría ya estar en uso.', Colors.red);
      }
    }
  }

  void _navigateBasedOnRole() {
    Widget targetScreen;
    if (widget.selectedRole == 'Gerente') {
      targetScreen = ProfileScreen(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
    } else {
      targetScreen = ProfileScreen2(
          userId: _nameController.hashCode,
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
          (Route<dynamic> route) => false,
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F24),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login_logo.png',
                height: 100,
              ),
              const SizedBox(height: 30),
              Text(
                'Registro de ${widget.selectedRole}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextFormField('Nombre', _nameController, (value) {
                if (value == null || value.isEmpty) return 'El nombre es obligatorio';
                return null;
              }),
              const SizedBox(height: 20),
              _buildTextFormField('Apellido', _lastNameController, (value) {
                if (value == null || value.isEmpty) return 'El apellido es obligatorio';
                return null;
              }),
              const SizedBox(height: 20),
              _buildTextFormField('Email', _emailController, (value) {
                if (value == null || !value.contains('@')) return 'Ingrese un email válido';
                return null;
              }),
              const SizedBox(height: 20),
              _buildTextFormField('Contraseña', _passwordController, (value) {
                if (value == null || value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                return null;
              }, obscureText: true),
              const SizedBox(height: 20),
              _buildTextFormField('Confirmar Contraseña', _confirmPasswordController, (value) {
                if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                return null;
              }, obscureText: true),
              const SizedBox(height: 10),
              _buildTermsCheckbox(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
              const SizedBox(height: 20),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, String? Function(String?)? validator, {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2F353F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (bool? newValue) {
            setState(() {
              _termsAccepted = newValue ?? false;
            });
          },
          activeColor: Colors.amber,
          checkColor: Colors.black,
        ),
        const Flexible(
          child: Text(
            'Acepto los Términos y Condiciones',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitRegistrationForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'EMPEZAR',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      },
      child: const Text(
        '¿Ya eres usuario? - Inicia Sesión',
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}