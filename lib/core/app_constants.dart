// lib/core/app_constants.dart

class AppConstants {
  static const String baseUrl = 'http://localhost:8080';

  // Rutas de API
  static const String users = '/api/users'; // AÑADIDO: Para la autenticación
  static const String profile = '/api/profiles';
  static const String report = '/api/reports';
  static const String shipment = '/api/shipments';
  static const String vehicle = '/api/vehicles';
}