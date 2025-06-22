// lib/features/auth/data/remote/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile/core/app_constants.dart';
import 'user_model.dart'; // Asegúrate de tener este modelo

class UserService {
  Future<UserModel?> createUser(String email, String password, String role) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.users}');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to create user. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }
}