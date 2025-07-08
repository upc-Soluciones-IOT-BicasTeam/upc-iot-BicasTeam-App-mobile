import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_service.dart';

import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/profile/profile_screen2.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/reports/reports_carrier_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/shipments/shipments_screen2.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';

class VehicleDetailCarrierScreenScreen extends StatefulWidget {
  final int userId;
  final String name;
  final String lastName;

  const VehicleDetailCarrierScreenScreen({
    Key? key,
    required this.userId,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _VehicleDetailCarrierScreenScreenState createState() =>
      _VehicleDetailCarrierScreenScreenState();
}

class _VehicleDetailCarrierScreenScreenState
    extends State<VehicleDetailCarrierScreenScreen>
    with SingleTickerProviderStateMixin {
  List<VehicleModel> vehicles = [];
  bool isLoading = true;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  final VehicleService _vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchAllVehicles();
  }

  Future<void> _fetchAllVehicles() async {
    setState(() => isLoading = true);
    try {
      final fetchedVehicles = await _vehicleService.getAllVehicles();
      setState(() {
        vehicles = fetchedVehicles;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
      setState(() {
        isLoading = false;
        vehicles = [];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            Text('Todos los Vehículos',
                style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : vehicles.isNotEmpty
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) =>
                        _buildVehicleCard(vehicles[index]),
                  ),
                )
              : const Center(
                  child: Text(
                    'No se encontraron vehículos disponibles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F353F),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleImage(vehicle.vehicleImage),
          const SizedBox(height: 15),
          _buildInfoRow('Placa', vehicle.licensePlate),
          _buildInfoRow('Marca', vehicle.brand),
          _buildInfoRow('Modelo', vehicle.model),
          _buildInfoRow('Temperatura', '${vehicle.temperature}°C',
              isPercentage: true),
          _buildInfoRow('Humedad', '${vehicle.humidity}%',
              isPercentage: true),
          _buildInfoRow('Carga Máxima', '${vehicle.maxLoad} kg',
              isPercentage: true),
          _buildInfoRow('Color', vehicle.color),
          _buildInfoRow(
              'Fecha de Última Inspección',
              DateFormat('yyyy-MM-dd HH:mm')
                  .format(vehicle.lastTechnicalInspectionDate)),
          _buildInfoRow('Ubicación', vehicle.location),
          _buildInfoRow('Velocidad', vehicle.speed),
          _buildInfoRow('Registrado Desde',
              DateFormat('yyyy-MM-dd HH:mm').format(vehicle.createdAt)),
        ],
      ),
    );
  }

  Widget _buildVehicleImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return _networkOrPlaceholder(imageUrl);
    } else if (imageUrl.isNotEmpty) {
      try {
        final bytes = base64Decode(imageUrl);
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(
            bytes,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildNoImagePlaceholder(),
          ),
        );
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
      }
    }
    return _buildNoImagePlaceholder();
  }

  Widget _networkOrPlaceholder(String url) => ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          url,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildNoImagePlaceholder(),
        ),
      );

  Widget _buildNoImagePlaceholder() => Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF3A414B),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: const Text('No hay imagen disponible',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
      );

  Widget _buildInfoRow(String label, String value,
      {bool isPercentage = false}) {
    double? percentageValue;
    if (isPercentage) {
      percentageValue =
          double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    String conditionText(double p) {
      if (p > 75) return 'En excelente estado';
      if (p > 60) return 'En buen estado';
      if (p > 35) return 'Presenta algunas fallas';
      return 'En mal estado';
    }

    Color conditionColor(double p) {
      if (p > 75) return Colors.green;
      if (p > 60) return Colors.amber;
      if (p > 35) return Colors.orange;
      return Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: const TextStyle(color: Colors.amber, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end),
                if (isPercentage && percentageValue != null)
                  Text(
                    conditionText(percentageValue),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: conditionColor(percentageValue)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() => Drawer(
        backgroundColor: const Color(0xFF2C2F38),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Image.asset('assets/images/login_logo.png', height: 100),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.name} ${widget.lastName} - Transportista',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              Icons.person,
              'PERFIL',
              ProfileScreen2(
                userId: widget.userId,
                name: widget.name,
                lastName: widget.lastName,
              ),
            ),
            _buildDrawerItem(
              Icons.report,
              'REPORTES',
              ReportsCarrierScreen(
                userId: widget.userId,
                name: widget.name,
                lastName: widget.lastName,
              ),
            ),
            _buildDrawerItem(
              Icons.directions_car,
              'VEHÍCULOS',
              VehicleDetailCarrierScreenScreen(
                userId: widget.userId,
                name: widget.name,
                lastName: widget.lastName,
              ),
            ),
            _buildDrawerItem(
              Icons.local_shipping,
              'ENVÍOS',
              ShipmentsScreen2(
                userId: widget.userId,
                name: widget.name,
                lastName: widget.lastName,
              ),
            ),
            const SizedBox(height: 160),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('CERRAR SESIÓN',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      );

  Widget _buildDrawerItem(IconData icon, String title, Widget page) =>
      ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title,
            style: const TextStyle(color: Colors.white)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      );
}
