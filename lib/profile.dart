import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String name;
  final String email;
  final String phoneNumber;

  User({
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Dio _dio = Dio();
  late Future<User> _userFuture;

  Future<User> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      _dio.options.headers["Authorization"] = "Bearer $token";

      Response response = await _dio.get('http://192.168.1.38:8080/v1/user');

      if (response.statusCode == 200) {
        print('Response data: ${response.data}');

        if (response.data is List) {
          if (response.data.isNotEmpty) {
            String? currentUserId = prefs.getString('user_id');
            var currentUserData = response.data.firstWhere(
                (user) => user['user_id'] == currentUserId, orElse: () => null);

            if (currentUserData != null) {
              return User.fromJson(currentUserData);
            } else {
              throw Exception('No matching user found for the current session');
            }
          } else {
            throw Exception('Received an empty list from the API');
          }
        } else {
          throw Exception('Expected a list but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load user data: ${response.statusCode} ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text('Profile'),
        ),
        backgroundColor: const Color(0xFFFFDCBC),
      ),
      body: Container(
        color: const Color(0xFFFFECDB), // Background color
        child: FutureBuilder<User>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              User user = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color.fromARGB(255, 211, 154, 154),
                        child: const Icon(Icons.person, size: 50, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),

                    const Text('Contact', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Divider(thickness: 1.5, color: Colors.grey),
                    const SizedBox(height: 10),

                    Text('Email: ${user.email}', style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    Text('Phone: ${user.phoneNumber}', style: const TextStyle(fontSize: 20)),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
