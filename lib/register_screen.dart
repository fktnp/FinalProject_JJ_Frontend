import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'components/custom_textfield.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  final Dio dio = Dio(); // สร้าง instance ของ Dio

  RegisterScreen({super.key});

  // ฟังก์ชันสำหรับเรียก API
  Future<void> _registerUser(BuildContext context) async {
    try { dio.options.headers['Content-Type'] = 'application/json'; // ตั้งค่า Header สำหรับ JSON
      // นำค่าจาก TextEditingController มาใช้ในการส่งข้อมูล
      String email = _emailController.text;
      String password = _passwordController.text;
      String username = _userNameController.text;
      String phoneNumber = _telController.text;

      var response = await dio.post('http://192.168.1.35:8080/v1/user/register', data: {
        "email": email,
        "password": password,
        "name": username,
        "phone_number": phoneNumber,
      });

      if (response.statusCode == 201) {
        print('Registration successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        print('Registration failed: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.response?.statusCode} - ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 220, 188, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/Pic/logo.png',
                height: 200,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _userNameController,
                hintText: 'Username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Username',
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
                controller: _emailController,
                hintText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
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
              CustomTextField(
                controller: _telController,
                hintText: 'Tel.',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Tel.',
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
                  if (_formKey.currentState!.validate()) {
                          _registerUser(context); 
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
