import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/shipment_model.dart';

class DriverShipmentsAnalyticsScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const DriverShipmentsAnalyticsScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _DriverShipmentsAnalyticsScreenState createState() => _DriverShipmentsAnalyticsScreenState();
}

class _DriverShipmentsAnalyticsScreenState extends State<DriverShipmentsAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  List<ProfileModel> _carriers = [];
  List<ShipmentModel> _selectedDriverShipments = [];
  ProfileModel? _selectedDriver;
  Map<String, int> _shipmentStatusDistribution = {};

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
      final shipments = await _analyticsService.getShipmentsByDriverName(driverName);

      // Calcular la distribución de estados de envío
      final statusDistribution = <String, int>{};
      for (var shipment in shipments) {
        statusDistribution[shipment.status] = (statusDistribution[shipment.status] ?? 0) + 1;
      }

      setState(() {
        _selectedDriverShipments = shipments;
        _shipmentStatusDistribution = statusDistribution;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackbar('Error al cargar los envíos: $e');
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
            Icon(Icons.local_shipping, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Envíos por Conductor',
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
                        _buildShipmentStatusDistribution(),
                        const SizedBox(height: 16),
                        _buildDestinationsFrequency(),
                        const SizedBox(height: 16),
                        _buildRecentShipments(),
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
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping, color: Colors.blueAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Total de envíos: ${_selectedDriverShipments.length}',
                            style: const TextStyle(
                              color: Colors.blueAccent,
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

  Widget _buildShipmentStatusDistribution() {
    if (_shipmentStatusDistribution.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay envíos para este conductor',
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
              const Icon(Icons.pie_chart, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Estados de Envíos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${_selectedDriverShipments.length}',
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
          ..._shipmentStatusDistribution.entries.map((entry) {
            final percentage = (entry.value / _selectedDriverShipments.length) * 100;
            Color statusColor;

            switch (entry.key.toLowerCase()) {
              case 'entregado':
                statusColor = Colors.green;
                break;
              case 'en tránsito':
              case 'en transito':
                statusColor = Colors.blue;
                break;
              case 'pendiente':
                statusColor = Colors.amber;
                break;
              case 'cancelado':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Text(
                      '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / _selectedDriverShipments.length,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDestinationsFrequency() {
    if (_selectedDriverShipments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Agrupar por destino
    final destinationFrequency = <String, int>{};
    for (var shipment in _selectedDriverShipments) {
      destinationFrequency[shipment.destiny] = (destinationFrequency[shipment.destiny] ?? 0) + 1;
    }

    // Ordenar por frecuencia (más frecuente primero)
    final sortedDestinations = destinationFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            'Destinos más Frecuentes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedDestinations.take(5).map((entry) {
            final percentage = (entry.value / _selectedDriverShipments.length) * 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${entry.value} envíos (${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentShipments() {
    if (_selectedDriverShipments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay envíos para mostrar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Ordenar los envíos por fecha, del más reciente al más antiguo
    final sortedShipments = List<ShipmentModel>.from(_selectedDriverShipments)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
            'Envíos Recientes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedShipments.take(10).map((shipment) {
            return _buildShipmentCard(shipment);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(ShipmentModel shipment) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormatter.format(shipment.createdAt);

    Color statusColor;
    IconData statusIcon;

    switch (shipment.status.toLowerCase()) {
      case 'entregado':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'en tránsito':
      case 'en transito':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        break;
      case 'pendiente':
        statusColor = Colors.amber;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'cancelado':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destino: ${shipment.destiny}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shipment.description,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      shipment.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fecha: $formattedDate',
                style: TextStyle(color: Colors.grey[400]),
              ),
              Text(
                'ID: ${shipment.id}',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
