// lib/features/vehicle_management/data/remote/profile_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movigestion_mobile/core/app_constants.dart';
import 'profile_model.dart';

class ProfileService {
  // Obtiene un perfil usando el ID del usuario (idCredential en la API)
  Future<ProfileModel?> getProfileByUserId(int userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.profile}/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to fetch profile. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Actualiza un perfil usando el ID del perfil
  Future<bool> updateProfile(int profileId, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.profile}/$profileId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        print('Profile updated successfully');
        return true;
      } else {
        print('Failed to update profile. Status: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<ProfileModel?> createProfile(int userId, String name, String lastName, String? telephone) async {
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.profile}');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idCredential': userId,
          'name': name,
          'lastName': lastName,
          'telephone': telephone, // API espera un string, puede ser null
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProfileModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to create profile. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating profile: $e');
      return null;
    }
  }
}