import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SubscriptionScreen extends StatefulWidget {
  final String name;
  final String lastName;

  const SubscriptionScreen({
    Key? key,
    required this.name,
    required this.lastName,
  }) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _uploadedUrl;
  bool _isUploading = false;

  void _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      setState(() {
        _isUploading = true;
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://tuservidor.com/api/subscriptions/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('paymentProof', file.path, filename: fileName),
      );

      try {
        final response = await request.send();
        final resBody = await response.stream.bytesToString();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = json.decode(resBody);
          setState(() {
            _uploadedUrl = responseData['fileUrl'] ?? 'Subido exitosamente';
            _isUploading = false;
          });
          _showSnackbar('Archivo subido correctamente.');
        } else {
          _showSnackbar('Error al subir archivo.');
          setState(() {
            _isUploading = false;
          });
        }
      } catch (e) {
        _showSnackbar('Error de conexión.');
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.amber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C2F38),
          title: const Text('Suscripción'),
        ),
        backgroundColor: const Color(0xFF1E1F24),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
            'Beneficios de Suscribirse:',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
              '- Acceso completo a reportes / Gestión de transportistas / Control de vehículos y mantenimientos / Historial de envíos y reportes / Soporte personalizado',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: Text(_isUploading ? 'Subiendo...' : 'Subir comprobante de pago'),
          onPressed: _isUploading ? null : _pickAndUploadFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEA8E00),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        const SizedBox(height: 20),
        if (_uploadedUrl != null)
    Text(
      'Archivo subido: $_uploadedUrl',
      style: const TextStyle(color: Colors.greenAccent),
    ),
    ],
    ),
    ),
    );
  }
}
