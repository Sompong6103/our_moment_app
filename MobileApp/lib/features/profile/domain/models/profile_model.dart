class ProfileModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String? avatarUrl;

  const ProfileModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      gender: json['gender'] ?? 'other',
      avatarUrl: json['avatarUrl'],
    );
  }
}
