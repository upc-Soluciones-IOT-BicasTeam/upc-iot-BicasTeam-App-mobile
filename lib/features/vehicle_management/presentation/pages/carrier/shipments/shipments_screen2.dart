import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/profile/profile_screen2.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/reports/reports_carrier_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/vehicle/vehicle_detail_carrier_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';

// AJUSTADO: Se define un modelo local para manejar los datos del envío de forma segura.
class _Shipment {
  final int id;
  final String destiny;
  final String description;
  final String driverName;
  String status;
  final DateTime createdAt;

  _Shipment({
    required this.id,
    required this.destiny,
    required this.description,
    required this.driverName,
    required this.status,
    required this.createdAt,
  });

  factory _Shipment.fromJson(Map<String, dynamic> json) {
    return _Shipment(
      id: json['id'] ?? 0,
      destiny: json['destiny'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
      driverName: json['driverName'] ?? '',
      status: json['status'] ?? 'Pendiente',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ShipmentsScreen2 extends StatefulWidget {
  // AJUSTADO: Parámetros consistentes con otras pantallas del transportista
  final int userId;
  final String name;
  final String lastName;

  const ShipmentsScreen2({
    Key? key,
    required this.userId,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _ShipmentsScreen2State createState() => _ShipmentsScreen2State();
}

class _ShipmentsScreen2State extends State<ShipmentsScreen2> with SingleTickerProviderStateMixin {
  // AJUSTADO: La lista ahora es de tipo _Shipment
  List<_Shipment> _shipments = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchShipments();
  }

  // AJUSTADO: Lógica principal de obtención y filtrado de datos
  Future<void> _fetchShipments() async {
    // 1. Construir el nombre completo del conductor actual
    final driverFullName = '${widget.name} ${widget.lastName}';

    try {
      // 2. Obtener todos los envíos
      final shipmentsResponse = await http.get(Uri.parse('http://localhost:8080/api/shipments'));

      if (shipmentsResponse.statusCode == 200) {
        List<dynamic> allShipmentsData = json.decode(shipmentsResponse.body);

        // 3. Mapear a objetos _Shipment y filtrar por nombre de conductor
        final filteredShipments = allShipmentsData
            .map((data) => _Shipment.fromJson(data))
            .where((shipment) => shipment.driverName.trim() == driverFullName.trim())
            .toList();

        if (mounted) {
          setState(() {
            _shipments = filteredShipments;
            _isLoading = false;
          });
          _animationController.forward();
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
        // Manejar error de la API
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      // Manejar error de conexión
    }
  }

  Future<void> _markAsDelivered(int index) async {
    final shipment = _shipments[index];
    final id = shipment.id;
    // La API espera "Envio Entregado" como estado para marcarlo como entregado.
    final String newStatus = "Envio Entregado";

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/shipments/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      // La API puede devolver 200 (OK) o 204 (No Content) en un PUT exitoso.
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          setState(() {
            _shipments[index].status = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Confirmación entregada al gerente.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // ... manejo de errores ...
      }
    } catch (e) {
      // ... manejo de errores ...
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
            Icon(Icons.local_shipping, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Envíos Asignados',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _shipments.isEmpty
          ? FadeTransition(
        opacity: _fadeAnimation,
        child: const Center(
          child: Text(
            'No tienes envíos asignados.',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _fetchShipments,
          color: Colors.amber,
          backgroundColor: const Color(0xFF2C2F38),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _shipments.length,
            itemBuilder: (context, index) {
              final shipment = _shipments[index];
              // AJUSTADO: Se pasa el objeto completo a la tarjeta
              return _buildShipmentCard(shipment, index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentCard(_Shipment shipment, int index) {
    bool isDelivered = shipment.status == 'Envio Entregado';
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16.0),
      color: isDelivered ? Colors.grey.shade300 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDelivered ? Colors.green.shade100 : Colors.amber.shade100,
                  child: Icon(
                    isDelivered ? Icons.check_circle_outline : Icons.local_shipping_outlined,
                    color: isDelivered ? Colors.green : Colors.amber.shade800,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destino: ${shipment.destiny}',
                        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Descripción: ${shipment.description}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(shipment.createdAt)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isDelivered ? null : () => _markAsDelivered(index),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: isDelivered ? Colors.grey : Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(isDelivered ? Icons.check : Icons.delivery_dining, size: 20),
                label: Text(isDelivered ? 'ENTREGADO' : 'Confirmar Entrega'),
              ),
            ),
          ],
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
                  style: const TextStyle(color: Colors.grey,  fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PERFIL', ProfileScreen2(userId: widget.userId, name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.report, 'REPORTES', ReportsCarrierScreen(userId: widget.userId, name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.directions_car, 'VEHICULOS',VehicleDetailCarrierScreenScreen(userId: widget.userId, name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.local_shipping, 'ENVIOS',this.widget ),
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