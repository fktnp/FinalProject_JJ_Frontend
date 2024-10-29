import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/theme.dart';
import 'model/usermodel.dart';

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

      Response response = await _dio.get('http://10.0.2.2:8080/v1/user');

      if (response.statusCode == 200) {
        print('Response data: ${response.data}');

        if (response.data is List) {
          if (response.data.isNotEmpty) {
            String? currentUserId = prefs.getString('user_id');
            var currentUserData = response.data.firstWhere(
                (user) => user['user_id'] == currentUserId,
                orElse: () => null);
            print(currentUserId);

            if (currentUserData != null) {
              return User.fromJson(currentUserData);
            } else {
              throw Exception('No matching user found for the current session');
            }
          } else {
            throw Exception('Received an empty list from the API');
          }
        } else {
          throw Exception(
              'Expected a list but got ${response.data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to load user data: ${response.statusCode} ${response.statusMessage}');
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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text('Profile'),
        ),
        backgroundColor: pastel.pastel1,
      ),
      body: Container(
        color: pastel.pastel2, // Background color
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
                    const Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Color.fromARGB(255, 211, 154, 154),
                        child:
                            Icon(Icons.person, size: 50, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(user.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),
                    Text('Contact',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: pastel.pastelFont)),
                    const Divider(thickness: 1.5, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text('Email: ${user.email}',
                        style:
                            TextStyle(fontSize: 20, color: pastel.pastelFont)),
                    const SizedBox(height: 10),
                    Text('Phone: ${user.phoneNumber}',
                        style:
                            TextStyle(fontSize: 20, color: pastel.pastelFont)),
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
