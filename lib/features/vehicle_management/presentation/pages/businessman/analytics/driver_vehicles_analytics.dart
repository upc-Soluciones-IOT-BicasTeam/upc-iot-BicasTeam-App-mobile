import 'package:flutter/material.dart';
import 'dart:convert'; // Para base64Decode
import 'dart:typed_data'; // Para Uint8List
import 'package:intl/intl.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';

class DriverVehiclesAnalyticsScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const DriverVehiclesAnalyticsScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _DriverVehiclesAnalyticsScreenState createState() => _DriverVehiclesAnalyticsScreenState();
}

class _DriverVehiclesAnalyticsScreenState extends State<DriverVehiclesAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  List<ProfileModel> _carriers = [];
  List<VehicleModel> _selectedDriverVehicles = [];
  ProfileModel? _selectedDriver;

  @override
  void initState() {
    super.initState();
    _loadCarriers();
  }

  Future<void> _loadCarriers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final carriers = await _analyticsService.getCarrierProfiles();
      setState(() {
        _carriers = carriers;
        _isLoading = false;
      });

      // Si hay conductores, selecciona el primero por defecto
      if (_carriers.isNotEmpty) {
        _selectDriver(_carriers.first);
      }
    } catch (e) {
      _showSnackbar('Error al cargar los transportistas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDriver(ProfileModel driver) async {
    setState(() {
      _isLoading = true;
      _selectedDriver = driver;
    });

    try {
      final driverName = "${driver.name} ${driver.lastName}";
      final vehicles = await _analyticsService.getVehiclesByDriverName(driverName);

      setState(() {
        _selectedDriverVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackbar('Error al cargar los vehículos: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: Row(
          children: [
            Icon(Icons.directions_car, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Vehículos por Conductor',
              style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w600),
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
          : _carriers.isEmpty
              ? const Center(child: Text('No hay transportistas registrados', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDriverSelector(),
                      const SizedBox(height: 24),
                      if (_selectedDriver != null) ...[
                        _buildSelectedDriverInfo(),
                        const SizedBox(height: 16),
                        _buildVehicleSystemsAverages(),
                        const SizedBox(height: 16),
                        _buildVehiclesList(),
                      ],
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFEA8E00),
        child: const Icon(Icons.refresh, color: Colors.black),
        onPressed: () {
          if (_selectedDriver != null) {
            _selectDriver(_selectedDriver!);
          } else {
            _loadCarriers();
          }
        },
      ),
    );
  }

  Widget _buildDriverSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ProfileModel>(
          value: _selectedDriver,
          dropdownColor: const Color(0xFF2C2F38),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          hint: const Text(
            'Seleccionar Conductor',
            style: TextStyle(color: Colors.white70),
          ),
          items: _carriers.map((driver) {
            return DropdownMenuItem<ProfileModel>(
              value: driver,
              child: Text(
                '${driver.name} ${driver.lastName}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (driver) {
            if (driver != null) {
              _selectDriver(driver);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDriverInfo() {
    if (_selectedDriver == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFEA8E00),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/images/driver.png',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedDriver!.name} ${_selectedDriver!.lastName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Email: ${_selectedDriver!.email}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.greenAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Total de vehículos: ${_selectedDriverVehicles.length}',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSystemsAverages() {
    if (_selectedDriverVehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay vehículos para este conductor',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Calcular promedios de los sistemas de los vehículos
    int totalEngine = 0;
    int totalFuel = 0;
    int totalTires = 0;
    int totalElectricalSystem = 0;
    int totalTransmissionTemp = 0;

    for (var vehicle in _selectedDriverVehicles) {
      totalEngine += vehicle.engine;
      totalFuel += vehicle.fuel;
      totalTires += vehicle.tires;
      totalElectricalSystem += vehicle.electricalSystem;
      totalTransmissionTemp += vehicle.transmissionTemperature;
    }

    double avgEngine = totalEngine / _selectedDriverVehicles.length;
    double avgFuel = totalFuel / _selectedDriverVehicles.length;
    double avgTires = totalTires / _selectedDriverVehicles.length;
    double avgElectricalSystem = totalElectricalSystem / _selectedDriverVehicles.length;
    double avgTransmissionTemp = totalTransmissionTemp / _selectedDriverVehicles.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado Promedio de los Sistemas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSystemProgressBar('Motor', avgEngine),
          _buildSystemProgressBar('Combustible', avgFuel),
          _buildSystemProgressBar('Neumáticos', avgTires),
          _buildSystemProgressBar('Sistema Eléctrico', avgElectricalSystem),
          _buildSystemProgressBar('Temperatura de Transmisión', avgTransmissionTemp),
        ],
      ),
    );
  }

  Widget _buildSystemProgressBar(String name, double value) {
    Color progressColor;

    if (value >= 80) {
      progressColor = Colors.green;
    } else if (value >= 50) {
      progressColor = Colors.amber;
    } else {
      progressColor = Colors.redAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: TextStyle(color: progressColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVehiclesList() {
    if (_selectedDriverVehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay vehículos para mostrar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Vehículos Asignados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${_selectedDriverVehicles.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),
          ..._selectedDriverVehicles.map((vehicle) {
            return _buildVehicleCard(vehicle);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final formattedInspectionDate = dateFormatter.format(vehicle.lastTechnicalInspectionDate);

    // Calcular el estado general del vehículo (promedio de todos los sistemas)
    final avgCondition = (vehicle.engine + vehicle.fuel + vehicle.tires +
                          vehicle.electricalSystem + vehicle.transmissionTemperature) / 5;

    Color statusColor;
    String statusText;

    if (avgCondition >= 80) {
      statusColor = Colors.green;
      statusText = "Excelente";
    } else if (avgCondition >= 60) {
      statusColor = Colors.lightGreen;
      statusText = "Bueno";
    } else if (avgCondition >= 40) {
      statusColor = Colors.amber;
      statusText = "Regular";
    } else {
      statusColor = Colors.redAccent;
      statusText = "Atención requerida";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.grey[800],
          backgroundColor: Colors.grey[800],
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: vehicle.vehicleImage.isEmpty
                ? const Icon(Icons.directions_car, size: 35, color: Colors.white54)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _base64ToBytes(vehicle.vehicleImage),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.directions_car, size: 35, color: Colors.white54);
                      },
                    ),
                  ),
          ),
          title: Text(
            '${vehicle.model} - ${vehicle.licensePlate}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Últ. inspección: $formattedInspectionDate',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: const EdgeInsets.all(16),
          children: [
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.color_lens_outlined, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text('Color: ${vehicle.color}', style: const TextStyle(color: Colors.white)),
                const Spacer(),
                const Icon(Icons.date_range, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Registrado: ${DateFormat('dd/MM/yyyy').format(vehicle.createdAt)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Estado de los Sistemas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailedSystemBar('Motor', vehicle.engine, Icons.local_fire_department),
            const SizedBox(height: 8),
            _buildDetailedSystemBar('Combustible', vehicle.fuel, Icons.local_gas_station),
            const SizedBox(height: 8),
            _buildDetailedSystemBar('Neumáticos', vehicle.tires, Icons.tire_repair),
            const SizedBox(height: 8),
            _buildDetailedSystemBar('Sist. Eléctrico', vehicle.electricalSystem, Icons.electrical_services),
            const SizedBox(height: 8),
            _buildDetailedSystemBar('Transmisión', vehicle.transmissionTemperature, Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedSystemBar(String name, int value, IconData icon) {
    Color barColor;

    if (value >= 80) {
      barColor = Colors.green;
    } else if (value >= 60) {
      barColor = Colors.lightGreen;
    } else if (value >= 40) {
      barColor = Colors.amber;
    } else {
      barColor = Colors.redAccent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: barColor),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: TextStyle(
                color: barColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: MediaQuery.of(context).size.width * value / 100 * 0.7,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
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
