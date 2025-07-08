import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  LatLng? _parseLocation(String locationString) {
    final latRegex = RegExp(r"Latitude: (-?\d+\.\d+)");
    final lonRegex = RegExp(r"Longitude: (-?\d+\.\d+)");

    final latMatch = latRegex.firstMatch(locationString);
    final lonMatch = lonRegex.firstMatch(locationString);

    if (latMatch != null && lonMatch != null) {
      final latString = latMatch.group(1);
      final lonString = lonMatch.group(1);

      if (latString != null && lonString != null) {
        final lat = double.tryParse(latString);
        final lon = double.tryParse(lonString);

        if (lat != null && lon != null) {
          return LatLng(lat, lon);
        }
      }
    }
    final parts = locationString.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lon = double.tryParse(parts[1].trim());
      if (lat != null && lon != null) {
        return LatLng(lat, lon);
      }
    }
    
    return null;
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
        iconTheme: const IconThemeData(color: Colors.grey),
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
    final LatLng? vehicleLocation = _parseLocation(vehicle.location);

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
          _buildInfoRow('Color', vehicle.color),
          _buildInfoRow('Temperatura', '${vehicle.temperature}°C'),
          _buildInfoRow('Humedad', '${vehicle.humidity}%'),
          _buildInfoRow('Carga Máxima', '${vehicle.maxLoad} kg'),
          _buildInfoRow('Velocidad', vehicle.speed),
          _buildInfoRow(
              'Última Inspección',
              DateFormat('yyyy-MM-dd').format(vehicle.lastTechnicalInspectionDate)),
          _buildInfoRow('Ubicación', vehicle.location, isLocation: true),
          
          if (vehicleLocation != null) ...[
            const SizedBox(height: 15),
            _buildMapCard(vehicleLocation, vehicle),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard(LatLng location, VehicleModel vehicle) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 14.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId('vehicle_${vehicle.id}'),
              position: location,
              infoWindow: InfoWindow(title: vehicle.licensePlate),
            ),
          },
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }

  Widget _buildVehicleImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, color: Colors.white70, size: 50),
            SizedBox(height: 8),
            Text('No hay imagen disponible', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        )
      );
  
  Widget _buildInfoRow(String label, String value, {bool isLocation = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Expanded( 
            child: Text(
              value,
              style: TextStyle(
                color: isLocation ? Colors.lightBlueAccent : Colors.amber, 
                fontSize: 16
              ),
              textAlign: TextAlign.end,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // FIX: Converted the Drawer's child to a Column and fixed const errors.
  Widget _buildDrawer() => Drawer(
        backgroundColor: const Color(0xFF2C2F38),
        child: Column( // LAYOUT FIX: Changed ListView to Column to make Spacer work.
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E1F24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/login_logo.png', height: 80),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.name} ${widget.lastName}',
                    style:
                        const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Text( // FIX 1: Added const to TextStyle
                    'Transportista',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
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
            const Spacer(), // LAYOUT FIX: Now pushes the logout tile to the bottom.
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('CERRAR SESIÓN',
                  style: const TextStyle(color: Colors.white)), // FIX 2: Added const to TextStyle
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(), // FIX 3: Removed const
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
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
        }
      );
}