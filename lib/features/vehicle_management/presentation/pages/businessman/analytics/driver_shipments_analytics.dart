import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/shipment_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/shipment_service.dart';

class DriverShipmentsAnalyticsScreen extends StatefulWidget {
  const DriverShipmentsAnalyticsScreen({Key? key}) : super(key: key);

  @override
  _DriverShipmentsAnalyticsScreenState createState() => _DriverShipmentsAnalyticsScreenState();
}

class _DriverShipmentsAnalyticsScreenState extends State<DriverShipmentsAnalyticsScreen> {
  final ShipmentService _shipmentService = ShipmentService();
  bool _isLoading = true;
  Map<String, List<ShipmentModel>> _shipmentsByDriver = {};

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    setState(() => _isLoading = true);

    try {
      final shipments = await _shipmentService.getAllShipments();
      
      final grouped = <String, List<ShipmentModel>>{};

      for (final shipment in shipments) {
        final driverKey = shipment.driverName.trim().isNotEmpty
            ? shipment.driverName.trim()
            : 'Sin conductor';

        if (!grouped.containsKey(driverKey)) {
          grouped[driverKey] = [];
        }
        grouped[driverKey]!.add(shipment);
      }

      setState(() {
        _shipmentsByDriver = grouped;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackbar('Error al cargar los envíos: $e');
      setState(() => _isLoading = false);
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
        title: const Row(
          children: [
            Icon(Icons.local_shipping, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Envíos por Conductor',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
          : _shipmentsByDriver.isEmpty
              ? const Center(child: Text('No hay envíos registrados', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _shipmentsByDriver.entries.map((entry) {
                      final driverName = entry.key;
                      final shipments = entry.value;

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
                              driverName,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total de envíos: ${shipments.length}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              children: shipments
                                  .map((shipment) => _buildShipmentCard(shipment))
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
        onPressed: _loadShipments,
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
