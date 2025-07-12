// lib/features/vehicle_management/data/remote/profile_repository.dart

import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_service.dart';
import 'package:movigestion_mobile/features/vehicle_management/data/remote/profile_model.dart';

import '../remote/auth_service.dart';
import '../remote/user_model.dart';
import '../remote/user_service.dart';

class ProfileRepository {
  final AuthService authService;
  final ProfileService profileService;
  final UserService userService; // Añadir UserService


  ProfileRepository({required this.authService, required this.profileService, required this.userService,});

  // Nuevo método de login que devuelve el perfil
  Future<(UserModel, ProfileModel)?> loginAndGetProfile(String email, String password) async {
    final user = await authService.login(email, password);
    if (user != null) {
      final profile = await profileService.getProfileByUserId(user.id);
      if (profile != null) {
        return (user, profile); // Devuelve una tupla/record
      }
    }
    return null;
  }
  Future<bool> registerUserAndProfile({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? telephone,
  }) async {
    // Paso 1: Crear el usuario (credenciales)
    final newUser = await userService.createUser(email, password, role);
    if (newUser == null) {
      print("Fallo en la creación del usuario.");
      return false; // Si falla, detenemos el proceso
    }

    // Paso 2: Crear el perfil asociado al nuevo usuario
    final newProfile = await profileService.createProfile(newUser.id, name, lastName, telephone);
    if (newProfile == null) {
      print("Fallo en la creación del perfil.");
      // Opcional: Podrías intentar borrar el usuario creado para consistencia.
      return false;
    }

    // Si ambos pasos son exitosos
    return true;
  }

  // Método para actualizar el perfil
  Future<bool> updateProfile(int profileId, ProfileModel profileToUpdate) async {
    // Usamos el toJsonForUpdate para enviar solo los campos necesarios
    return await profileService.updateProfile(profileId, profileToUpdate.toJsonForUpdate());
  }

  Future<List<ProfileModel>> getAllProfiles() async {
    return await profileService.getAllProfiles();
  }
}