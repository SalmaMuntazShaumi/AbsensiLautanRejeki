// models/user_model.dart
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? role;
  final String? phone;
  final String? birthdate;
  final String? photoUrl;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.role,
    this.phone,
    this.birthdate,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:        json['id'],
      name:      json['name'],
      email:     json['email'],
      role:      json['role'],
      phone:     json['phone'],
      birthdate: json['birthdate'],
      photoUrl:  json['photo_url'] ?? json['photo'] ?? '',
    );
  }
}