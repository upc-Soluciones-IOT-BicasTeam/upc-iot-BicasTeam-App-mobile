import 'package:flutter/material.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/carrier_profiles/carrier_profiles.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/analytics/driver_reports_analytics.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/analytics/driver_shipments_analytics.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/analytics/driver_vehicles_analytics.dart';

class AnalyticsScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const AnalyticsScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  List<DriverAnalyticsModel> _driversAnalytics = [];

  int _totalVehicles = 0;
  int _totalReports = 0;
  int _totalShipments = 0;

  @override
  void initState() {
    super.initState();
    _loadDriversAnalytics();
  }

  Future<void> _loadDriversAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analytics = await _analyticsService.getDriversAnalytics();
      final vehicles = await _analyticsService.getAllVehiclesForAnalytics();
      final reports = await _analyticsService.getAllReportsForAnalytics();
      final shipments = await _analyticsService.getAllShipmentsForAnalytics();

      setState(() {
        _driversAnalytics = analytics;
        _totalVehicles = vehicles.length;
        _totalReports = reports.length;
        _totalShipments = shipments.length;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackbar('Error al cargar los datos analíticos: $e');
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
            Icon(Icons.analytics, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Analíticas',
              style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1E1F24),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA8E00)))
          : RefreshIndicator(
              onRefresh: _loadDriversAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Resumen de transportistas'),
                    const SizedBox(height: 16),
                    _buildAnalyticsSummaryCards(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Análisis detallado por conductor'),
                    const SizedBox(height: 16),
                    _buildAnalyticsCategories(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Lista de transportistas'),
                    const SizedBox(height: 16),
                    _buildDriverAnalyticsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAnalyticsSummaryCards() {
    // Calcular totales
    int totalReports = 0;
    int totalVehicles = _totalVehicles;
    int totalShipments = _totalShipments;

    for (var driver in _driversAnalytics) {
      totalReports += driver.totalReports;
      totalShipments += driver.totalShipments;
      totalVehicles += driver.vehiclesAssigned;
    }

    return Row(
      children: [
        _buildSummaryCard(
          title: 'Reportes',
          value: totalReports.toString(),
          icon: Icons.report,
          color: Colors.red,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          title: 'Envíos',
          value: totalShipments.toString(),
          icon: Icons.local_shipping,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          title: 'Vehículos',
          value: totalVehicles.toString(),
          icon: Icons.directions_car,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCategories() {
    return Column(
      children: [
        Row(
          children: [
            _buildCategoryCard(
              title: 'Reportes por Conductor',
              icon: Icons.report,
              color: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverReportsAnalyticsScreen(
                      name: widget.name,
                      lastName: widget.lastName,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildCategoryCard(
              title: 'Envíos por Conductor',
              icon: Icons.local_shipping,
              color: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverShipmentsAnalyticsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCategoryCard(
              title: 'Vehículos por Conductor',
              icon: Icons.directions_car,
              color: Colors.greenAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverVehiclesAnalyticsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Placeholder para equilibrar la fila
          ],
        ),
      ],
    );
  }

  Widget _buildDriverAnalyticsList() {
    return Column(
      children: _driversAnalytics.map((driver) => _buildDriverAnalyticsCard(driver)).toList(),
    );
  }

  Widget _buildDriverAnalyticsCard(DriverAnalyticsModel driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEA8E00),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/driver.png',
                    fit: BoxFit.cover,
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${driver.driverName} ${driver.driverLastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'transportista',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Reportes', driver.totalReports.toString(), Icons.report, Colors.redAccent),
              _buildStatItem('Envíos', driver.totalShipments.toString(), Icons.local_shipping, Colors.blueAccent),
              _buildStatItem('Vehículos', driver.vehiclesAssigned.toString(), Icons.directions_car, Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2F38),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ver detalles',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
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
                  '${widget.name} ${widget.lastName} - Gerente',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'PROFILE', ProfileScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.people, 'CARRIERS', CarrierProfilesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.report, 'REPORTS', ReportsScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.directions_car, 'VEHICLES', VehiclesScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.local_shipping, 'SHIPMENTS', ShipmentsScreen(name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.analytics, 'ANALYTICS', AnalyticsScreen(name: widget.name, lastName: widget.lastName)),
          const SizedBox(height: 100),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
            // CÓDIGO CORREGIDO SIN PARÁMETROS
onTap: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      // Simplemente llama al constructor de LoginScreen sin argumentos
      builder: (context) => const LoginScreen(), 
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
