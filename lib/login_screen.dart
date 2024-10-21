import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_1/main.dart';
import 'components/custom_button.dart';
import 'components/custom_textfield.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Dio dio = Dio();

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
            await dio.post('http://10.0.2.2:8080/v1/user/login', data: {
          "user_id": "ffa2d7fd-bdbe-48da-9874-eed74a585ec3",
          "email": username,
          "password": password,
        });
        // ตรวจสอบ response
        if (response.statusCode == 200) {
          print('Login successful: ${response.data}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MyHomePage()), // ไปยังหน้า home
          );
        } else {
          print('Login failed: ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Login failed: ${response.data['message']}')),
          );
        }
      } on DioException catch (e) {
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
                const SizedBox(height: 90),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()),
                    );
                    // login(context);  // เรียกใช้ฟังก์ชัน login
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
