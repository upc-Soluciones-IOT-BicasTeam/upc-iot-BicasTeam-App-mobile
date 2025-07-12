import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/analytics_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/report_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/shipment_model.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/vehicle_model.dart';

class AnalyticsRepository {
  final AnalyticsService analyticsService;

  AnalyticsRepository({required this.analyticsService});

  Future<List<DriverAnalyticsModel>> getDriversAnalytics() async {
    return await analyticsService.getDriversAnalytics();
  }

  Future<List<ReportModel>> getReportsByDriverName(String driverName) async {
    return await analyticsService.getReportsByDriverName(driverName);
  }

  Future<List<ShipmentModel>> getShipmentsByDriverName(String driverName) async {
    return await analyticsService.getShipmentsByDriverName(driverName);
  }

  Future<List<VehicleModel>> getVehiclesByDriverId(int driverId) async {
    return await analyticsService.getVehiclesByDriverId(driverId);
  }
}
