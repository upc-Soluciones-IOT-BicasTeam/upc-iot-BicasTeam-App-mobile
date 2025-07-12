import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_service.dart';

class DriverVehiclesAnalyticsScreen extends StatefulWidget {
  const DriverVehiclesAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _DriverVehiclesAnalyticsScreenState createState() =>
      _DriverVehiclesAnalyticsScreenState();
}

class _DriverVehiclesAnalyticsScreenState
    extends State<DriverVehiclesAnalyticsScreen> {
  final VehicleService _vehicleService = VehicleService();
  bool _isLoading = true;
  Map<String, List<VehicleModel>> _vehiclesByDriver = {};

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allVehicles = await _vehicleService.getAllVehicles();
      final grouped = _groupVehiclesByDriver(allVehicles);

      setState(() {
        _vehiclesByDriver = grouped;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackbar('Error al cargar los vehículos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, List<VehicleModel>> _groupVehiclesByDriver(List<VehicleModel> vehicles) {
    final Map<String, List<VehicleModel>> grouped = {};

    for (var vehicle in vehicles) {
      final driverKey = vehicle.driverId != null
          ? 'Conductor ID ${vehicle.driverId}'
          : 'Sin asignar';

      if (!grouped.containsKey(driverKey)) {
        grouped[driverKey] = [];
      }

      grouped[driverKey]!.add(vehicle);
    }

    return grouped;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: const Row(
          children: [
            Icon(Icons.directions_car, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Vehículos por Conductor',
              style: TextStyle(
                  color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF1E1F24),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA8E00)))
          : _vehiclesByDriver.isEmpty
              ? const Center(
                  child: Text('No hay vehículos registrados',
                      style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: _vehiclesByDriver.entries.map((entry) {
                      final driverKey = entry.key;
                      final vehicles = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2F38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverKey,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total de vehículos: ${vehicles.length}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: vehicles
                                  .map((vehicle) => _buildVehicleCard(vehicle))
                                  .toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEA8E00),
        child: const Icon(Icons.refresh, color: Colors.black),
        onPressed: _loadVehicles,
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final formattedInspectionDate =
        dateFormatter.format(vehicle.lastTechnicalInspectionDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.model} - ${vehicle.licensePlate}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Últ. inspección: $formattedInspectionDate',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Uint8List _base64ToBytes(String base64) {
    try {
      return base64Decode(base64);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return Uint8List(0);
    }
  }
}
