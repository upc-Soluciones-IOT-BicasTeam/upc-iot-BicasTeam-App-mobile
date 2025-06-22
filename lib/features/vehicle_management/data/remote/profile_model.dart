// lib/features/vehicle_management/data/remote/profile_model.dart

class ProfileModel {
  final int id;
  final int idCredential; // Corresponde al ID del usuario
  final String name;
  final String lastName;
  final String? telephone; // El teléfono puede no estar presente

  ProfileModel({
    required this.id,
    required this.idCredential,
    required this.name,
    required this.lastName,
    this.telephone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      idCredential: json['idCredential'],
      name: json['name'],
      lastName: json['lastName'],
      telephone: json['telephone'],
    );
  }

  // Este toJson es para el cuerpo de la solicitud de actualización (CreateProfileResource)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'idCredential': idCredential,
      'name': name,
      'lastName': lastName,
      'telephone': telephone,
    };
  }
}