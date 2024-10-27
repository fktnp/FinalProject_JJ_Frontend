import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/custom_button.dart';
import 'components/custom_textfield.dart';
import 'register_screen.dart';
import 'google_auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio dio = Dio();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  String? _passwordError;

  Future<void> login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        dio.options.headers['Content-Type'] = 'application/json';
        dio.options.validateStatus = (status) => status! < 500;

        String username = _userNameController.text;
        String password = _passwordController.text;

        Response response = await dio.post(
          'http://192.168.1.35:8080/v1/user/login',
          data: {
            "email": username,
            "password": password,
          },
        );

        if (response.statusCode == 200) {
          print('Login successful: ${response.data}');

          // เก็บ token และข้อมูลผู้ใช้ใน SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', response.data['token'] ?? '');
          await prefs.setString('user_id', response.data['user_id'] ?? '');
          await prefs.setString('user_name', response.data['name'] ?? '');
          await prefs.setString('user_email', response.data['email'] ?? '');
          await prefs.setString(
              'user_phone', response.data['phone_number'] ?? '');

          setState(() {
            _passwordError = null; // Clear any previous error
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          setState(() {
            _passwordError = 'Login failed. Please try again.';
          });
        }
      } on DioError catch (e) {
        print('Dio error: ${e.response?.statusCode} - ${e.message}');
        setState(() {
          _passwordError = 'Server error. Please try again later.';
        });
      } catch (e) {
        print('Unexpected error: $e');
        setState(() {
          _passwordError = 'An unexpected error occurred. Please try again.';
        });
      }
    }
  }

  Future<void> checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print('Token: $token');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 220, 188, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'lib/Pic/logo.png',
                  height: 200,
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  controller: _userNameController,
                  hintText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFFFFECDB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFFFECDB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFFFFECDB),
                    errorText: _passwordError, // Display error message here
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFFFECDB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google,
                      size: 30, color: Colors.black),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFECDB),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () {
                    _googleAuthService.signInWithGoogle(
                        context); // เรียกฟังก์ชัน signInWithGoogle
                  },
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'No account? Register',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                ),
                const SizedBox(height: 30),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 50,
                  color: Colors.black,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFECDB),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: () {
                    login(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
