class DriverAnalyticsModel {
  final int id;
  final String driverName;
  final String driverLastName;
  final int totalShipments;
  final int totalReports;
  final int vehiclesAssigned;

  DriverAnalyticsModel({
    required this.id,
    required this.driverName,
    required this.driverLastName,
    required this.totalShipments,
    required this.totalReports,
    required this.vehiclesAssigned,
  });

  factory DriverAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DriverAnalyticsModel(
      id: json['id'],
      driverName: json['driverName'],
      driverLastName: json['driverLastName'],
      totalShipments: json['totalShipments'],
      totalReports: json['totalReports'],
      vehiclesAssigned: json['vehiclesAssigned'],
    );
  }
}
