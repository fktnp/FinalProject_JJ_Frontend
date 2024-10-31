class User {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
    );
  }
}
