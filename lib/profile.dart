import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
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
      Response response = await _dio.get('http://192.168.1.44:8080/v1/user');
      if (response.statusCode == 200) {
        if (response.data is List) {
          return User.fromJson(response.data[0]);
        } else {
          throw Exception('Expected a List but got something else');
        }
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
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
        backgroundColor: const Color(0xFFFFDCBC),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // จัดตำแหน่งไปทางขวาสุด
          children: const [
            Text(
              'Profile',
              style: TextStyle(
                  color: Colors.black, fontSize: 25), // ขนาดตัวอักษรใน AppBar
            ),
          ],
        ),
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            User user = snapshot.data!;
            return Container(
              color: const Color(0xFFFFECDB),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // For spacing at the top
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person,
                        size: 50, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Name ${user.name}',
                    style: const TextStyle(
                        fontSize: 30), // ขนาดตัวอักษรใหญ่ขึ้นสำหรับชื่อ
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Contact',
                        style: TextStyle(
                            fontSize:
                                24), // ขนาดตัวอักษรใหญ่ขึ้นสำหรับหัวข้อ 'Contact'
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tel: ${user.phoneNumber}',
                    style: const TextStyle(
                        fontSize:
                            22), // ขนาดตัวอักษรใหญ่ขึ้นสำหรับเบอร์โทรศัพท์
                  ),
                  Text(
                    'email: ${user.email}',
                    style: const TextStyle(
                        fontSize: 22), // ขนาดตัวอักษรใหญ่ขึ้นสำหรับอีเมล
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
