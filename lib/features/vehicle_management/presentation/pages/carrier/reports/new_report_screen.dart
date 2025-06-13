// lib/features/vehicle_management/presentation/pages/carrier/reports/new_report_screen.dart

import 'package:flutter/material.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/report_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/repository/report_repository.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/report_service.dart';
// ... otros imports para la navegación del drawer ...

class NewReportScreen extends StatefulWidget {
  // AJUSTADO: Se reciben los datos del usuario necesarios
  final int userId;
  final String driverName;

  const NewReportScreen({
    Key? key,
    required this.userId,
    required this.driverName,
  }) : super(key: key);

  @override
  _NewReportScreenState createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReportType;
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _reportTypes = ['Problemas con el vehiculo', 'Cliente no disponible', 'Direccion incorrecta', 'Accidente en autopista', 'Otro'];

  // AJUSTADO: Se utiliza el ReportRepository
  late final ReportRepository _reportRepository;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // AJUSTADO: Inicialización del repositorio
    _reportRepository = ReportRepository(reportService: ReportService());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // AJUSTADO: Lógica de creación a través del repositorio
  Future<void> _createReport() async {
    if (_formKey.currentState!.validate()) {
      showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // La API (`CreateReportResource`) no necesita el userId ni createdAt,
      // por lo que creamos un modelo temporal solo para pasarlo al repositorio.
      // El método `toJsonForCreation` se encargará de enviar solo los campos correctos.
      final tempReport = ReportModel(
        id: 0, // Dummy value
        userId: widget.userId, // Dummy value
        type: _selectedReportType!,
        description: _descriptionController.text.trim(),
        driverName: widget.driverName,
        createdAt: DateTime.now(), // Dummy value
      );

      final success = await _reportRepository.createReport(tempReport);

      Navigator.pop(context); // Cierra el dialogo de carga

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte creado exitosamente'), backgroundColor: Colors.green),
        );
        // Simplemente regresa a la pantalla anterior. No se necesita devolver datos.
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el reporte'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reporte', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C2F38),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF1A1F24),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildReportForm(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportForm() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F38),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles del Reporte',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Tipo de Reporte',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A1F24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            dropdownColor: const Color(0xFF2C2F38),
            value: _selectedReportType,
            items: _reportTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedReportType = newValue;
              });
            },
            validator: (value) => value == null ? 'Por favor, seleccione un tipo de reporte' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Descripción',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF1A1F24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            style: const TextStyle(color: Colors.white),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'La descripción no puede estar vacía' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEA8E00),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 5,
      ),
      onPressed: _createReport,
      child: const Text(
        'ENVIAR REPORTE',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}