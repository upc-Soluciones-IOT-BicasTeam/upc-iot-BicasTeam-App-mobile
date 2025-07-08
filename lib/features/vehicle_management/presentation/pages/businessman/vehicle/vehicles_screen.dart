import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/repository/vehicle_repository.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/vehicle/assign_vehicle_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/vehicle/vehicle_detail_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/carrier_profiles/carrier_profiles.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/analytics/analytics_screen.dart';

// ✅ Validación de base64
bool isValidBase64(String str) {
  try {
    if (str.isEmpty || str.length % 4 != 0) return false;
    base64Decode(str);
    return true;
  } catch (_) {
    return false;
  }
}

class VehiclesScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const VehiclesScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleRepository vehicleRepository = VehicleRepository(vehicleService: VehicleService());
  List<VehicleModel> vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      final fetchedVehicles = await vehicleRepository.getAllVehicles();
      setState(() {
        vehicles = fetchedVehicles;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar vehículos', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: const Row(
          children: [
            Icon(Icons.directions_car, color: Colors.amber),
            SizedBox(width: 10),
            Text('Vehículos', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1C1E24),
      drawer: _buildDrawer(),
      body: vehicles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length,
              itemBuilder: (context, index) => _buildVehicleCard(vehicles[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssignVehicleScreen(
                name: widget.name,
                lastName: widget.lastName,
              ),
            ),
          );

          // Si se creó un vehículo, refresca la lista
          if (result == true) {
            _fetchVehicles();
          }
        },
        backgroundColor: const Color(0xFFFFA000),
        label: const Text('Asignar nuevo Vehículo', style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      color: const Color(0xFF2C2F38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VehicleDetailScreen(
                vehicle: vehicle,
                name: widget.name,
                lastName: widget.lastName,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: vehicle.vehicleImage.isNotEmpty
                    ? (Uri.tryParse(vehicle.vehicleImage)?.hasAbsolutePath == true
                        ? Image.network(vehicle.vehicleImage, width: 60, height: 60, fit: BoxFit.cover)
                        : (isValidBase64(vehicle.vehicleImage)
                            ? Image.memory(base64Decode(vehicle.vehicleImage), width: 60, height: 60, fit: BoxFit.cover)
                            : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey)))
                    : const Icon(Icons.directions_car, size: 60, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Marca: ${vehicle.brand}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    Text('Modelo: ${vehicle.model}', style: const TextStyle(color: Colors.white70)),
                    Text('Placa: ${vehicle.licensePlate}', style: const TextStyle(color: Colors.white70)),
                    Text('Color: ${vehicle.color}', style: const TextStyle(color: Colors.white70)),
                    Text('Carga Máx: ${vehicle.maxLoad} t', style: const TextStyle(color: Colors.white70)),
                    Text('Velocidad: ${vehicle.speed}', style: const TextStyle(color: Colors.white70)),
                    Text('Ubicación: ${vehicle.location}', style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF2C2F38),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Column(
              children: [
                Image.asset('assets/images/login_logo.png', height: 100),
                const SizedBox(height: 10),
                Text('${widget.name} ${widget.lastName} - Gerente', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PROFILE', ProfileScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.people, 'CARRIERS', CarrierProfilesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.report, 'REPORTS', ReportsScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.directions_car, 'VEHICLES', VehiclesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.local_shipping, 'SHIPMENTS', ShipmentsScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.analytics, 'ANALYTICS', AnalyticsScreen(name: widget.name, lastName: widget.lastName)),

          const SizedBox(height: 160),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(),
                ),
                (_) => false,
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
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}