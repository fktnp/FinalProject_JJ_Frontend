import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/main.dart';
import 'components/custom_button.dart';
import 'components/custom_textfield.dart';
import 'register_screen.dart';
import 'google_auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio dio = Dio();
  final GoogleAuthService _googleAuthService =
      GoogleAuthService(); // สร้างอินสแตนซ์ของ GoogleAuthService

  LoginScreen({super.key});

  Future<void> login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        dio.options.headers['Content-Type'] =
            'application/json'; // ตั้งค่า Header สำหรับ JSON

        // นำค่าจาก TextEditingController มาใช้ในการส่งข้อมูล
        String username = _userNameController.text; // ใช้ email แทน username
        String password = _passwordController.text;

        // ทำ POST request
        Response response =
            await dio.post('http://192.168.1.38:8080/v1/user/login', data: {
          "email": username,
          "password": password,
        });
        // ตรวจสอบ response
        if (response.statusCode == 200) {
          print('Login successful: ${response.data}');

          // เพิ่มการเปลี่ยนหน้าแบบมีอนิเมชั่น easeInOut
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(seconds: 1), // กำหนดระยะเวลาการเคลื่อนไหว
              pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = const Offset(1.0, 0.0); // เริ่มจากทางขวาของจอ
                var end = Offset.zero;
                var curve = Curves.easeInOut; // ใช้ easeInOut curve

                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        } else {
          print('Login failed: ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Login failed: ${response.data['message']}')),
          );
        }
      } on DioError catch (e) {
        print('Dio error: ${e.response?.statusCode} - ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: ${e.message}')),
        );
      }
    }
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
                    _googleAuthService.signInWithGoogle(context);  //google login
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
                    login(context); // เรียกใช้ฟังก์ชัน login
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