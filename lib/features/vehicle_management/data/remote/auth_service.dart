// lib/features/auth/data/remote/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile/core/app_constants.dart';
import 'user_model.dart';

class AuthService {
  // Llama al endpoint de autenticación de la API
  Future<UserModel?> login(String email, String password) async {
    // AVISO: Aunque funcional, este endpoint sigue siendo inseguro.
    // Lo ideal es un POST a /api/auth/login con el body {'email': email, 'password': password}
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.users}/email/$email/password/$password');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        print('Login failed. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login request: $e');
      return null;
    }
  }
}