import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile/core/app_constants.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/report_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/shipment_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';

class AnalyticsService {
  // Obtener perfiles de transportistas
  Future<List<ProfileModel>> getCarrierProfiles() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.profile}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Filtrar solo transportistas
        final carriers = data
            .where((profile) => profile['type'] == 'Transportista')
            .map((json) => ProfileModel.fromJson(json))
            .toList();
        return carriers;
      } else {
        print('Failed to load carrier profiles. Status code: ${response.statusCode}');
        throw Exception('Failed to load carrier profiles');
      }
    } catch (e) {
      print('Error fetching carrier profiles: $e');
      rethrow;
    }
  }

  // Obtener estadísticas para todos los conductores
  Future<List<DriverAnalyticsModel>> getDriversAnalytics() async {
    try {
      // Obtener todos los datos necesarios
      final carriers = await getCarrierProfiles();
      final reports = await getAllReportsForAnalytics();
      final shipments = await getAllShipmentsForAnalytics();
      final vehicles = await getAllVehiclesForAnalytics();

      // Generar estadísticas para cada transportista
      List<DriverAnalyticsModel> analytics = carriers.map((carrier) {
        // Contar reportes asociados a este conductor
        final driverReports = reports.where(
          (report) => report.driverName == '${carrier.name} ${carrier.lastName}'
        ).length;

        // Contar envíos asociados a este conductor
        final driverShipments = shipments.where(
          (shipment) => shipment.driverName == '${carrier.name} ${carrier.lastName}'
        ).length;

        // Contar vehículos asociados a este conductor
        final driverVehicles = vehicles.where(
          (vehicle) => vehicle.driverName == '${carrier.name} ${carrier.lastName}'
        ).length;

        return DriverAnalyticsModel(
          id: carrier.id,
          driverName: carrier.name,
          driverLastName: carrier.lastName,
          totalReports: driverReports,
          totalShipments: driverShipments,
          vehiclesAssigned: driverVehicles,
        );
      }).toList();

      return analytics;
    } catch (e) {
      print('Error generating analytics: $e');
      rethrow;
    }
  }

  // Métodos auxiliares para obtener datos
  Future<List<ReportModel>> getAllReportsForAnalytics() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.report}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReportModel.fromJson(json)).toList();
      } else {
        print('Failed to load reports. Status code: ${response.statusCode}');
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      rethrow;
    }
  }

  Future<List<ShipmentModel>> getAllShipmentsForAnalytics() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.shipment}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShipmentModel.fromJson(json)).toList();
      } else {
        print('Failed to load shipments. Status code: ${response.statusCode}');
        throw Exception('Failed to load shipments');
      }
    } catch (e) {
      print('Error fetching shipments: $e');
      rethrow;
    }
  }

  Future<List<VehicleModel>> getAllVehiclesForAnalytics() async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.vehicle}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => VehicleModel.fromJson(json)).toList();
      } else {
        print('Failed to load vehicles. Status code: ${response.statusCode}');
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
      rethrow;
    }
  }

  // Obtener detalles de reportes por conductor
  Future<List<ReportModel>> getReportsByDriverName(String driverName) async {
    try {
      final allReports = await getAllReportsForAnalytics();
      return allReports.where((report) => report.driverName == driverName).toList();
    } catch (e) {
      print('Error fetching reports for driver: $e');
      rethrow;
    }
  }

  // Obtener detalles de envíos por conductor
  Future<List<ShipmentModel>> getShipmentsByDriverName(String driverName) async {
    try {
      final allShipments = await getAllShipmentsForAnalytics();
      return allShipments.where((shipment) => shipment.driverName == driverName).toList();
    } catch (e) {
      print('Error fetching shipments for driver: $e');
      rethrow;
    }
  }

  // Obtener vehículos por conductor
  Future<List<VehicleModel>> getVehiclesByDriverName(String driverName) async {
    try {
      final allVehicles = await getAllVehiclesForAnalytics();
      return allVehicles.where((vehicle) => vehicle.driverName == driverName).toList();
    } catch (e) {
      print('Error fetching vehicles for driver: $e');
      rethrow;
    }
  }
}
