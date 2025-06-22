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
  _VehicleDetailCarrierScreenScreenState createState() => _VehicleDetailCarrierScreenScreenState();
}

class _VehicleDetailCarrierScreenScreenState extends State<VehicleDetailCarrierScreenScreen> with SingleTickerProviderStateMixin {
  List<VehicleModel> vehicles = []; // Ahora es una lista de VehicleModel
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _fetchAllVehicles(); // Llama a la función para obtener todos los vehículos
  }

  Future<void> _fetchAllVehicles() async {
    setState(() {
      isLoading = true; // Inicia la carga
    });
    try {
      final List<VehicleModel> fetchedVehicles = await _vehicleService.getAllVehicles();

      setState(() {
        vehicles = fetchedVehicles; // Asigna la lista completa de vehículos
        isLoading = false;
      });
      // Inicia la animación una vez que los datos han sido cargados
      _animationController.forward();
    } catch (e) {
      print('Error fetching vehicles: $e');
      setState(() {
        isLoading = false;
        vehicles = []; // En caso de error, la lista estará vacía
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
        title: Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Todos los Vehículos', // Título actualizado
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : vehicles.isNotEmpty // Verifica si la lista de vehículos no está vacía
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder( // ¡Usamos ListView.builder para mostrar la lista!
                    padding: const EdgeInsets.all(16.0),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return _buildVehicleCard(vehicle); // Un nuevo método para construir cada tarjeta
                    },
                  ),
                )
              : const Center(
                  child: Text(
                    'No se encontraron vehículos disponibles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
    );
  }

  // --- Nuevo método para construir la tarjeta de cada vehículo ---
  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20), // Espacio entre tarjetas
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
          _buildInfoRow('Temperatura', '${vehicle.temperature}°C', isPercentage: true),
          _buildInfoRow('Humedad', '${vehicle.humidity}%', isPercentage: true),
          _buildInfoRow('Carga Máxima', '${vehicle.maxLoad} kg', isPercentage: true),
          _buildInfoRow('Color', vehicle.color),
          _buildInfoRow('Fecha de Última Inspección',
              DateFormat('yyyy-MM-dd HH:mm').format(vehicle.lastTechnicalInspectionDate)),
          _buildInfoRow('Ubicación', vehicle.location),
          _buildInfoRow('Velocidad', vehicle.speed),
          _buildInfoRow('Registrado Desde', DateFormat('yyyy-MM-dd HH:mm').format(vehicle.createdAt)),
        ],
      ),
    );
  }


  Widget _buildInfoRow(String label, String value, {bool isPercentage = false}) {
    String getConditionText(double percentage) {
      if (percentage > 75) {
        return "En excelente estado";
      } else if (percentage > 60) {
        return "En buen estado";
      } else if (percentage > 35) {
        return "Presenta algunas fallas";
      } else {
        return "En mal estado";
      }
    }

    Color getConditionColor(double percentage) {
      if (percentage > 75) {
        return Colors.green;
      } else if (percentage > 60) {
        return Colors.amber;
      } else if (percentage > 35) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Pequeño padding vertical
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.amber, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
                if (isPercentage)
                  Text(
                    getConditionText(double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: getConditionColor(double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleImage(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildNoImagePlaceholder();
          },
        ),
      );
    } else if (imageUrl.isNotEmpty) {
      try {
        final decodedBytes = base64Decode(imageUrl);
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.memory(
            decodedBytes,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildNoImagePlaceholder();
            },
          ),
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
        return _buildNoImagePlaceholder();
      }
    }
    return _buildNoImagePlaceholder();
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF3A414B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          'No hay imagen disponible',
          style: TextStyle(color: Colors.white70, fontSize: 16),
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
                Image.asset(
                  'assets/images/login_logo.png',
                  height: 100,
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.name} ${widget.lastName} - Transportista',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
              Icons.person, 'PERFIL', ProfileScreen2(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.report, 'REPORTES',
              ReportsCarrierScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(
              Icons.directions_car,
              'VEHÍCULOS',
              VehicleDetailCarrierScreenScreen(
                name: widget.name,
                lastName: widget.lastName,
              )),
          _buildDrawerItem(Icons.local_shipping, 'ENVÍOS',
              ShipmentsScreen2(name: widget.name, lastName: widget.lastName)),
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