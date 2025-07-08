import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/repository/vehicle_repository.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/carrier_profiles/carrier_profiles.dart';

class AssignVehicleScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const AssignVehicleScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  State<AssignVehicleScreen> createState() => _AssignVehicleScreenState();
}

class _AssignVehicleScreenState extends State<AssignVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final plateController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final assignedDriverController = TextEditingController();
  final colorController = TextEditingController();
  final maxLoadController = TextEditingController();
  final lastInspectionDateController = TextEditingController();

  final vehicleRepository = VehicleRepository(vehicleService: VehicleService());
  String? _selectedImageBase64;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBase64 = base64Encode(result.files.single.bytes!);
      });
    }
  }

  Future<void> _createVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = VehicleModel(
        id: 0,
        managerId: 1, // Ajusta según sea necesario
        licensePlate: plateController.text,
        brand: brandController.text,
        model: modelController.text,
        temperature: 0,
        humidity: 0,
        maxLoad: double.tryParse(maxLoadController.text) ?? 0,
        driverId: int.tryParse(assignedDriverController.text) ?? 0,
        vehicleImage: _selectedImageBase64 ?? '',
        color: colorController.text,
        lastTechnicalInspectionDate: DateFormat('yyyy-MM-dd').parse(lastInspectionDateController.text),
        location: '', // No se ingresa ubicación manualmente
        speed: '0',
        createdAt: DateTime.now(),
      );

      try {
        final success = await vehicleRepository.createVehicle(vehicle);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo creado'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // <-- Aquí devuelve true para refrescar la lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear vehículo'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Vehículo')),
      backgroundColor: const Color(0xFF1E1F24),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Marca del vehículo', brandController),
              _buildTextField('Modelo del vehículo', modelController),
              _buildTextField('Placa del vehículo', plateController),
              _buildTextField('ID del conductor asignado', assignedDriverController),
              _buildTextField('Color del vehículo', colorController),
              _buildTextField('Carga máxima (Kg)', maxLoadController, isNumber: true),
              _buildDateField('Fecha última inspección', lastInspectionDateController),
              const SizedBox(height: 15),
              _buildImagePicker(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _createVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA8E00),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                ),
                child: const Text('Asignar Vehículo', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF3A414B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(color: Colors.white),
        validator: (value) => value == null || value.isEmpty ? 'Ingrese $label' : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF3A414B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFEA8E00)),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Imagen del vehículo', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        _selectedImageBase64 == null
            ? ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload),
                label: const Text('Seleccionar Imagen'),
              )
            : Column(
                children: [
                  Image.memory(base64Decode(_selectedImageBase64!), height: 150, fit: BoxFit.cover),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit),
                    label: const Text('Cambiar Imagen'),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF2C2F38),
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset('assets/images/login_logo.png', height: 100),
                Text('${widget.name} ${widget.lastName} - Gerente', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'Perfil', ProfileScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.people, 'Transportistas', CarrierProfilesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.report, 'Reportes', ReportsScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.directions_car, 'Vehículos', VehiclesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.local_shipping, 'Envíos', ShipmentsScreen(name: widget.name, lastName: widget.lastName)),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,

              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
