class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String? gender;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      phone: json['phone'],
      gender: json['gender'],
    );
  }
}
