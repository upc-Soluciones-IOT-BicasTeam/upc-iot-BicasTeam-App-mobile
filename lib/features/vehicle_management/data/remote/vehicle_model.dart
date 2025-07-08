class VehicleModel {
  final int id;
  final int managerId;
  final String licensePlate;
  final String brand;
  final String model;
  final double temperature;
  final double humidity;
  final double maxLoad;
  final int driverId;
  final String vehicleImage;
  final String color;
  final DateTime lastTechnicalInspectionDate;
  final String location;
  final String speed;
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.managerId,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.temperature,
    required this.humidity,
    required this.maxLoad,
    required this.driverId,
    required this.vehicleImage,
    required this.color,
    required this.lastTechnicalInspectionDate,
    required this.location,
    required this.speed,
    required this.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? 0,
      managerId: json['managerId'] ?? 0,
      licensePlate: json['licensePlate'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      maxLoad: (json['maxLoad'] as num?)?.toDouble() ?? 0.0,
      driverId: json['driverId'] ?? 0,
      vehicleImage: json['vehicleImage'] ?? '',
      color: json['color'] ?? '',
      lastTechnicalInspectionDate: DateTime.tryParse(json['lastTechnicalInspectionDate'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      speed: json['speed'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idManager': managerId,
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'temperature': temperature,
      'humidity': humidity,
      'maxLoad': maxLoad,
      'driverId': driverId,
      'vehicleImage': vehicleImage,
      'color': color,
      'lastTechnicalInspectionDate': lastTechnicalInspectionDate.toIso8601String(),
      'latitude': 0,
      'longitude': 0,
      'altitude': 0,
      'speed': 0,
    };
  }
}