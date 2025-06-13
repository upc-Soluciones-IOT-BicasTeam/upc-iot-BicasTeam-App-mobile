// lib/features/vehicle_management/presentation/pages/carrier/reports/reports_carrier_screen.dart

import 'package:flutter/material.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/report_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/repository/report_repository.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/report_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/reports/new_report_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/shipments/shipments_screen2.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/vehicle/vehicle_detail_carrier_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/carrier/profile/profile_screen2.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';

class ReportsCarrierScreen extends StatefulWidget {
  final int userId;
  final String name;
  final String lastName;

  const ReportsCarrierScreen({
    Key? key,
    required this.userId,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _ReportsCarrierScreenState createState() => _ReportsCarrierScreenState();
}

class _ReportsCarrierScreenState extends State<ReportsCarrierScreen> with SingleTickerProviderStateMixin {
  late final ReportRepository _reportRepository;
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _reportRepository = ReportRepository(reportService: ReportService());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fetchReports();
  }

  // AJUSTADO: Lógica de obtención y filtrado por nombre de conductor
  Future<void> _fetchReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // 1. Construir el nombre completo del conductor actual
    final driverFullName = '${widget.name} ${widget.lastName}';

    try {
      // 2. Obtener todos los reportes desde el repositorio
      final allReports = await _reportRepository.getAllReports();
      if (mounted) {
        setState(() {
          // 3. Filtrar los reportes donde 'driverName' coincida con el nombre completo
          _reports = allReports
              .where((report) => report.driverName.trim() == driverFullName.trim())
              .toList();
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar los reportes'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _navigateToNewReportScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewReportScreen(
          userId: widget.userId,
          driverName: '${widget.name} ${widget.lastName}',
        ),
      ),
    );
    // Vuelve a cargar los reportes para reflejar cualquier nueva adición
    _fetchReports();
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
            Icon(Icons.report, color: Colors.amber),
            SizedBox(width: 10),
            Text(
              'Tus Reportes',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.amber,
          strokeWidth: 3,
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: _reports.isEmpty
            ? const Center(
          child: Text(
            'No has realizado ningún reporte.',
            style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        )
            : RefreshIndicator(
          onRefresh: _fetchReports,
          color: Colors.amber,
          backgroundColor: const Color(0xFF2C2F38),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _reports.length,
            itemBuilder: (context, index) {
              final report = _reports[index];
              return _buildReportCard(report);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewReportScreen,
        backgroundColor: const Color(0xFFFFA000),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(report),
            const SizedBox(height: 10),
            _buildReportDetails('Tipo', report.type),
            _buildReportDetails('Descripción', report.description),
            _buildReportDetails('Fecha', '${report.createdAt.toLocal().day}/${report.createdAt.toLocal().month}/${report.createdAt.toLocal().year}'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(ReportModel report) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.amber.shade100,
          child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 30),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            report.driverName,
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildReportDetails(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
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
          _buildDrawerItem(Icons.report, 'REPORTES', this.widget),
          _buildDrawerItem(Icons.directions_car, 'VEHICULOS',VehicleDetailCarrierScreenScreen(userId: widget.userId, name: widget.name, lastName: widget.lastName)),
          _buildDrawerItem(Icons.local_shipping, 'ENVIOS',ShipmentsScreen2(userId: widget.userId, name: widget.name, lastName: widget.lastName) ),
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