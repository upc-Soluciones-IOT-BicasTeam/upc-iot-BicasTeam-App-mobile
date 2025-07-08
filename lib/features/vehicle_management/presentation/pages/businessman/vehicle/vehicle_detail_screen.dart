import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/repository/vehicle_repository.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/profile/profile_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/shipments/shipments_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/vehicle/vehicles_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/reports/reports_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/login_register/login_screen.dart';
import 'package:movigestion_mobile/features/vehicle_management/presentation/pages/businessman/carrier_profiles/carrier_profiles.dart';
import 'dart:convert';

class VehicleDetailScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final String name;
  final String lastName;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicle,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  _VehicleDetailScreenState createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late TextEditingController licensePlateController;
  late TextEditingController modelController;
  late TextEditingController colorController;
  late TextEditingController lastTechnicalInspectionDateController;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  final VehicleRepository vehicleRepository =
      VehicleRepository(vehicleService: VehicleService());

  GoogleMapController? _mapController;
  LatLng? _vehicleLocation;

  @override
  void initState() {
    super.initState();
    licensePlateController = TextEditingController(text: widget.vehicle.licensePlate);
    modelController = TextEditingController(text: widget.vehicle.model);
    colorController = TextEditingController(text: widget.vehicle.color);
    lastTechnicalInspectionDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.vehicle.lastTechnicalInspectionDate),
    );

    _parseLocation(widget.vehicle.location);
  }

  void _parseLocation(String locationString) {
    final latRegex = RegExp(r"Latitude: (-?\d+\.\d+)");
    final lonRegex = RegExp(r"Longitude: (-?\d+\.\d+)");

    final latMatch = latRegex.firstMatch(locationString);
    final lonMatch = lonRegex.firstMatch(locationString);

    // Si encontramos ambos valores...
    if (latMatch != null && lonMatch != null) {
      final latString = latMatch.group(1);
      final lonString = lonMatch.group(1);

      if (latString != null && lonString != null) {
        final lat = double.tryParse(latString);
        final lon = double.tryParse(lonString);

        if (lat != null && lon != null) {
          setState(() {
            _vehicleLocation = LatLng(lat, lon);
          });
        }
      }
    } else {
       // Si el formato es "lat,lon" (como respaldo)
      final locationParts = locationString.split(',');
      if (locationParts.length == 2) {
        final lat = double.tryParse(locationParts[0].trim());
        final lon = double.tryParse(locationParts[1].trim());
        if (lat != null && lon != null) {
          setState(() {
             _vehicleLocation = LatLng(lat, lon);
          });
        }
      }
    }
  }
  
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateVehicle() async {
    try {
      final selectedDate = DateFormat('yyyy-MM-dd').parse(lastTechnicalInspectionDateController.text);
      final currentDate = DateTime.now();
      final initialDate = widget.vehicle.lastTechnicalInspectionDate;

      if (selectedDate.isAfter(currentDate)) {
        _showSnackbar('La fecha no puede ser futura.');
        return;
      }

      if (selectedDate.isBefore(initialDate)) {
        _showSnackbar('La fecha no puede ser menor a la ya registrada (${DateFormat('yyyy-MM-dd').format(initialDate)}).');
        return;
      }

      VehicleModel updatedVehicle = VehicleModel(
        id: widget.vehicle.id,
        managerId: widget.vehicle.managerId,
        licensePlate: licensePlateController.text,
        brand: widget.vehicle.brand,
        model: modelController.text,
        temperature: widget.vehicle.temperature,
        humidity: widget.vehicle.humidity,
        maxLoad: widget.vehicle.maxLoad,
        driverId: widget.vehicle.driverId,
        vehicleImage: _selectedImage != null
            ? _encodeImageToBase64(_selectedImage!)
            : widget.vehicle.vehicleImage,
        color: colorController.text,
        lastTechnicalInspectionDate: selectedDate,
        location: widget.vehicle.location,
        speed: widget.vehicle.speed,
        createdAt: widget.vehicle.createdAt,
      );

      bool success = await vehicleRepository.updateVehicle(
        widget.vehicle.id,
        updatedVehicle,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VehiclesScreen(
              name: widget.name,
              lastName: widget.lastName,
            ),
          ),
        );
      } else {
        _showSnackbar('Error al actualizar el vehículo');
      }
    } catch (error) {
      _showSnackbar('Error al actualizar el vehículo: $error');
    }
  }

  Future<void> _deleteVehicle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar este vehículo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        bool success = await vehicleRepository.deleteVehicle(widget.vehicle.id);
        if (success && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => VehiclesScreen(
                name: widget.name,
                lastName: widget.lastName,
              ),
            ),
            (route) => false,
          );
        } else {
          _showSnackbar('Error al eliminar el vehículo');
        }
      } catch (e) {
        _showSnackbar('Error al eliminar el vehículo: $e');
      }
    }
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String _encodeImageToBase64(File image) {
    List<int> imageBytes = image.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  Widget _buildMap() {
    if (_vehicleLocation == null) {
      return const Center(
        child: Text(
          "Ubicación no disponible para mostrar en el mapa.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _vehicleLocation!,
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId(widget.vehicle.id.toString()),
              position: _vehicleLocation!,
              infoWindow: InfoWindow(
                title: 'Ubicación Actual',
                snippet: widget.vehicle.licensePlate,
              ),
            ),
          },
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: false,
          zoomControlsEnabled: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F38),
        title: const Text('Detalle del Vehículo', style: TextStyle(color: Colors.grey)),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      backgroundColor: const Color(0xFF1E1F24),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? _buildVehicleImage(_selectedImage!)
                  : widget.vehicle.vehicleImage.isNotEmpty
                      ? _buildVehicleNetworkImage(widget.vehicle.vehicleImage)
                      : _buildNoImagePlaceholder(),
            ),
            const SizedBox(height: 20),
            _buildSectionContainer(_buildReadOnlyField('Marca', widget.vehicle.brand)),
            _buildSectionContainer(_buildTextField('Placa', licensePlateController)),
            _buildSectionContainer(_buildTextField('Modelo', modelController)),
            _buildSectionContainer(_buildTextField('Color', colorController)),
            _buildSectionContainer(_buildDateField('Última Inspección Técnica', lastTechnicalInspectionDateController)),
            _buildSectionContainer(_buildSensorData()),

            // ***** EL MAPA SE MUESTRA AQUÍ *****
            _buildSectionContainer(_buildMap()),
            const SizedBox(height: 4),

            ElevatedButton(
              onPressed: _updateVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA8E00),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Guardar cambios', style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Eliminar Vehículo', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) => TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFF3A414B),
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFEA8E00)),
        ),
        style: const TextStyle(color: Colors.white),
        onTap: () async {
          DateTime initial;
          try {
            initial = DateFormat('yyyy-MM-dd').parse(controller.text);
          } catch (e) {
            initial = DateTime.now();
          }

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) => Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFFEA8E00),
                  onPrimary: Colors.white,
                  surface: Color(0xFF2C2F38),
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: const Color(0xFF2C2F38),
              ),
              child: child!,
            ),
          );
          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      );

  Widget _buildVehicleImage(File image) => ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.file(image, height: 200, width: double.infinity, fit: BoxFit.cover),
      );

  Widget _buildVehicleNetworkImage(String imageUrl) => ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          imageUrl, 
          height: 200, 
          width: double.infinity, 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildNoImagePlaceholder(),
        ),
      );

  Widget _buildNoImagePlaceholder() => Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2E35),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.white70, size: 40),
              SizedBox(height: 8),
              Text('Toca para seleccionar imagen', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );

  Widget _buildSectionContainer(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2F353F),
          borderRadius: BorderRadius.circular(15),
        ),
        child: child,
      );

  Widget _buildTextField(String label, TextEditingController controller) => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFF3A414B),
        ),
        style: const TextStyle(color: Colors.white),
      );

  Widget _buildReadOnlyField(String label, String value) => TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFF3A414B),
        ),
        style: const TextStyle(color: Colors.white),
      );

  Widget _buildSensorData() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.thermostat, color: Colors.amber),
            const SizedBox(width: 8),
            Text('Temp: ${widget.vehicle.temperature}°C',
                style: const TextStyle(color: Colors.white)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.water_drop, color: Colors.cyan),
            const SizedBox(width: 8),
            Text('Humedad: ${widget.vehicle.humidity}%',
                style: const TextStyle(color: Colors.white)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.speed, color: Colors.lightBlue),
            const SizedBox(width: 8),
            Text('Velocidad: ${widget.vehicle.speed}',
                style: const TextStyle(color: Colors.white)),
          ]),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.greenAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ubicación: ${widget.vehicle.location}',
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildDrawer() => Drawer(
        backgroundColor: const Color(0xFF2C2F38),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1F24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/login_logo.png', height: 80),
                  const SizedBox(height: 10),
                  Text('${widget.name} ${widget.lastName}',
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const Text('Gerente', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            _buildDrawerItem(Icons.person, 'PERFIL',
                ProfileScreen(name: widget.name, lastName: widget.lastName)),
            _buildDrawerItem(Icons.people, 'TRANSPORTISTAS',
                CarrierProfilesScreen(name: widget.name, lastName: widget.lastName)),
            _buildDrawerItem(Icons.report, 'REPORTES',
                ReportsScreen(name: widget.name, lastName: widget.lastName)),
            _buildDrawerItem(Icons.directions_car, 'VEHICULOS',
                VehiclesScreen(name: widget.name, lastName: widget.lastName)),
            _buildDrawerItem(Icons.local_shipping, 'ENVIOS',
                ShipmentsScreen(name: widget.name, lastName: widget.lastName)),
            const Spacer(),
             ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      );

  Widget _buildDrawerItem(IconData icon, String title, Widget page) => ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
        }
      );
}