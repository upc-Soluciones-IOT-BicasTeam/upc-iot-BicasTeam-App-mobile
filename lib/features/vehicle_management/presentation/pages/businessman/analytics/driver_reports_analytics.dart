import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/report_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/analytics/analytics_screen.dart';

class DriverReportsAnalyticsScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const DriverReportsAnalyticsScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _DriverReportsAnalyticsScreenState createState() => _DriverReportsAnalyticsScreenState();
}

class _DriverReportsAnalyticsScreenState extends State<DriverReportsAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  List<ProfileModel> _carriers = [];
  List<ReportModel> _selectedDriverReports = [];
  ProfileModel? _selectedDriver;
  Map<String, int> _reportTypeDistribution = {};

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
      final reports = await _analyticsService.getReportsByDriverName(driverName);

      // Calcular la distribución de tipos de reporte
      final typeDistribution = <String, int>{};
      for (var report in reports) {
        typeDistribution[report.type] = (typeDistribution[report.type] ?? 0) + 1;
      }

      setState(() {
        _selectedDriverReports = reports;
        _reportTypeDistribution = typeDistribution;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackbar('Error al cargar los reportes: $e');
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
            Icon(Icons.report, color: Colors.amber),
            const SizedBox(width: 10),
            Text(
              'Reportes por Conductor',
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
                        _buildReportTypeDistribution(),
                        const SizedBox(height: 16),
                        _buildReportTimeline(),
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
                
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.report, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Total de reportes: ${_selectedDriverReports.length}',
                            style: const TextStyle(
                              color: Colors.redAccent,
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

  Widget _buildReportTypeDistribution() {
    if (_reportTypeDistribution.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay reportes para este conductor',
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
                'Tipos de Reporte',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${_selectedDriverReports.length}',
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
          ..._reportTypeDistribution.entries.map((entry) {
            final percentage = (entry.value / _selectedDriverReports.length) * 100;
            Color typeColor;

            // Asignar color según el tipo de reporte
            switch (entry.key.toLowerCase()) {
              case 'accidente':
                typeColor = Colors.red;
                break;
              case 'avería':
              case 'averia':
                typeColor = Colors.orange;
                break;
              case 'retraso':
                typeColor = Colors.amber;
                break;
              case 'emergencia':
                typeColor = Colors.purple;
                break;
              default:
                typeColor = Colors.blueGrey;
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
                            color: typeColor,
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
                    value: entry.value / _selectedDriverReports.length,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(typeColor),
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

  Widget _buildReportTimeline() {
    if (_selectedDriverReports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay reportes para mostrar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Ordenar los reportes por fecha, del más reciente al más antiguo
    final sortedReports = List<ReportModel>.from(_selectedDriverReports)
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
            'Historial de Reportes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedReports.map((report) {
            return _buildReportTimelineItem(report);
          }),
        ],
      ),
    );
  }

  Widget _buildReportTimelineItem(ReportModel report) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormatter.format(report.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo: ${report.type}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.description,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
