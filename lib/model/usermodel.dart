import 'dart:convert';
import 'package:http/http.dart' as http;

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

Future<User?> fetchUserByEmail(String email) async {
  final url = Uri.parse('http://192.168.1.36:8080/v1/user');
  print('in fetch user use : $email');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      for (var item in data) {
        User user = User.fromJson(item);
        print('got this user : ${user.name}');
        if (user.email == email) {
          print(user.email);
          return user; // คืนค่า User ที่ตรงกัน
        }
      }
    }
  } catch (e) {
    print("Error fetching user: $e");
  }

  return null; // คืนค่า null หากไม่พบผู้ใช้
}

Future<User?> fetchUserById(String userId) async {
  final url = Uri.parse('http://192.168.1.36:8080/v1/user/$userId');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      return User.fromJson(userData);
    }
  } catch (e) {
    print("Error fetching user: $e");
  }

  return null;
}
