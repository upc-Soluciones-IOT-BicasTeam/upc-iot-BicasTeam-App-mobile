// lib/features/vehicle_management/data/remote/shipment_model.dart

class ShipmentModel {
  final int id;
  final int userId;
  final String destiny;
  final String description;
  final DateTime createdAt;
  final String status;
  final String driverName;

  ShipmentModel({
    required this.id,
    required this.userId,
    required this.destiny,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.driverName,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'],
      userId: json['userId'],
      destiny: json['destiny'],
      description: json['description'],
      createdAt: DateTime.tryParse(json['createdAt']) ?? DateTime(2000),
      status: json['status'],
      driverName: json['driverName'],
    );
  }

  // AJUSTADO: Se crea un método para generar el JSON para crear un envío
  // que coincide con `CreateShipmentResource` de la API.
  Map<String, dynamic> toJsonForCreation() {
    return {
      'destiny': destiny,
      'description': description,
      'driverName': driverName,
      'status': status,
    };
  }
}