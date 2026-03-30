class ProfileModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String? avatarUrl;

  const ProfileModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.avatarUrl,
  });
}
