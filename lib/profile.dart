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
  String? _selectedImagePath;

  final List<String> _sampleImages = [
    'assets/images/image1.png',
    'assets/images/image2.png',
    'assets/images/image3.png',
  ];

  Future<User> fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Token not found. Please log in again.');
      }

      _dio.options.headers["Authorization"] = "Bearer $token";

      Response response = await _dio.get('http://192.168.1.35:8080/v1/user');

      if (response.statusCode == 200) {
        if (response.data is List && response.data.isNotEmpty) {
          String? currentUserId = prefs.getString('user_id');
          var currentUserData = response.data.firstWhere(
              (user) => user['user_id'] == currentUserId,
              orElse: () => null);

          if (currentUserData != null) {
            return User.fromJson(currentUserData);
          } else {
            throw Exception('No matching user found for the current session');
          }
        } else {
          throw Exception('Unexpected data format');
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
    _userFuture.then((user) {
      _loadSelectedImagePath(
          user.userId); // Load the image specific to the current user
    });
  }

  Future<void> _loadSelectedImagePath(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedImagePath =
          prefs.getString('profile_image_path_$userId') ?? _sampleImages[0];
    });
  }

  Future<void> changeProfileImage(String imagePath, String userId) async {
    setState(() {
      _selectedImagePath = imagePath;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path_$userId',
        imagePath); // Save image path specific to the user
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
        color: pastel.pastel2,
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
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Select Profile Image'),
                              content: SizedBox(
                                height: 200,
                                width: double.maxFinite,
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: _sampleImages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        changeProfileImage(
                                            _sampleImages[index], user.userId);
                                        Navigator.of(context)
                                            .pop(); // Close dialog after selecting image
                                      },
                                      child: Image.asset(
                                        _sampleImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close dialog
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _selectedImagePath != null
                              ? AssetImage(_selectedImagePath!)
                              : (user.profileImageUrl.isNotEmpty
                                  ? NetworkImage(user.profileImageUrl)
                                      as ImageProvider
                                  : const AssetImage(
                                      'assets/default_avatar.png')),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(user.name,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: pastel.pastelFont)),
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