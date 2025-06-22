import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile/core/app_constants.dart';
import 'shipment_model.dart';

class ShipmentService {
  Future<List<ShipmentModel>> getAllShipments() async { // SIN CAMBIOS
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.shipment}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ShipmentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shipments');
    }
  }

  Future<ShipmentModel?> getShipmentById(int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.shipment}/$id');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return ShipmentModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to load shipment. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching shipment by ID: $e');
      return null;
    }
  }

  // AJUSTADO: Acepta el modelo y usa toJsonForCreation
  Future<bool> createShipment(ShipmentModel shipment) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.shipment}');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // Usa el método que genera el JSON correcto para la creación
        body: json.encode(shipment.toJsonForCreation()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) { // 201 es 'Created'
        return true;
      } else {
        print('Failed to create shipment. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating shipment: $e');
      return false;
    }
  }

  Future<bool> deleteShipment(int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.shipment}/$id');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to delete shipment. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting shipment: $e');
      return false;
    }
  }

  Future<bool> updateShipmentStatus(int id, String status) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.shipment}/$id/status');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update shipment status. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating shipment status: $e');
      return false;
    }
  }

}
