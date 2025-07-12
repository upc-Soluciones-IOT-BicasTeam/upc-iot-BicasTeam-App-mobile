import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/carrier_profiles/carrier_profiles.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/analytics/analytics_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? name;
  final String? lastName;
  final int? userId;
  final String? email;

  const ProfileScreen({
    Key? key,
    this.name,
    this.lastName,
    this.userId,
    this.email,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController dialogEmailController;
  late TextEditingController dialogPasswordController;

  final ProfileService profileService = ProfileService();
  bool _isLoading = true;
  bool _isEditable = false;
  String userType = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    dialogEmailController = TextEditingController();
    dialogPasswordController = TextEditingController();

    if (widget.userId != null) {
      // Nueva forma: obtiene perfil desde backend
      emailController.text = widget.email ?? '';
      _fetchProfileData();
    } else {
      // Forma antigua: solo muestra datos estáticos
      nameController.text = widget.name ?? '';
      lastNameController.text = widget.lastName ?? '';
      emailController.text = '';
      _isLoading = false;
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      if (widget.userId == null) {
        _showSnackbar('No se proporcionó userId.');
        return;
      }

      final profile = await profileService.getProfileByUserId(widget.userId!);

      if (profile != null) {
        setState(() {
          nameController.text = profile.name;
          lastNameController.text = profile.lastName;
          _isLoading = false;
        });
      } else {
        _showSnackbar('No se encontró el perfil para este usuario.');
      }
    } catch (e) {
      print('ERROR EN _fetchProfileData: $e');
      _showSnackbar('Error al obtener los datos del perfil.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateProfileData() async {
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackbar('Las contraseñas no coinciden.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmación de actualización'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dialogEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dialogPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final updatedProfileData = {
                  'name': nameController.text,
                  'lastName': lastNameController.text,
                  'email': emailController.text,
                  'password': passwordController.text,
                  'type': userType,
                };


              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Perfil',
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1E1F24),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA8E00)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/Gerente.png',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                'Bienvenido, ${widget.name} ${widget.lastName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildLabeledTextField('Nombre', nameController, _isEditable),
            const SizedBox(height: 16),
            _buildLabeledTextField('Apellido', lastNameController, _isEditable),
            const SizedBox(height: 16),
            _buildLabeledTextField('Email', emailController, _isEditable),
            const SizedBox(height: 16),
            if (_isEditable)
              Column(
                children: [
                  _buildLabeledTextField('Contraseña', passwordController, true),
                  const SizedBox(height: 16),
                  _buildLabeledTextField('Confirmar Contraseña', confirmPasswordController, true),
                ],
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isEditable ? _updateProfileData : () {
                  setState(() {
                    _isEditable = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA8E00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditable ? 'CONFIRMAR ACTUALIZACIÓN' : 'EDITAR DATOS',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller, bool isEditable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditable,
          obscureText: label.toLowerCase().contains('contraseña'),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2C2F38),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(

            child: Column(
              children: [
                Image.asset(
                  'assets/images/login_logo.png',
                  height: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.name} ${widget.lastName} - Gerente',
                  style: const TextStyle(color: Colors.grey,  fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PROFILE', ProfileScreen( userId: widget.userId, email: widget.email,name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.people, 'CARRIERS', CarrierProfilesScreen(name: widget.name ?? '', lastName: widget.lastName ?? '')),
          _buildDrawerItem(Icons.report, 'REPORTS', ReportsScreen(name: widget.name ?? '', lastName: widget.lastName ?? '')),
          _buildDrawerItem(Icons.directions_car, 'VEHICLES', VehiclesScreen(name: widget.name ?? '', lastName: widget.lastName ?? '')),
          _buildDrawerItem(Icons.local_shipping, 'SHIPMENTS', ShipmentsScreen(name: widget.name ?? '', lastName: widget.lastName ?? '')),
          _buildDrawerItem(Icons.analytics, 'ANALYTICS', AnalyticsScreen(name: widget.name ?? '', lastName: widget.lastName ?? '')),
          const SizedBox(height: 160),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(

                  ),
                ),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
