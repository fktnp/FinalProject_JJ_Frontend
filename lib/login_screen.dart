import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; 
import 'components/custom_button.dart';
import 'components/custom_textfield.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

Future<void> login(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    String username = _userNameController.text;
    String password = _passwordController.text;

    // สร้าง Dio instance
    Dio dio = Dio();

    try {
      dio.options.headers['Content-Type'] = 'application/json';
      
      // API endpoint สำหรับการ login (ปรับ URL ให้ตรงกับ API ของคุณ)
      String url = 'http://localhost:8080/v1/user/login';

      // ทำ POST request
      Response response = await dio.post(
        url,
        data: {
          "user_id": "e8dc9a17-cbf8-4685-91f5-d070a44b849a", 
          "email": username,                  
          "password": password  
        },
      );

      // ตรวจสอบ response
      if (response.statusCode == 200) {
        // ถ้า login สำเร็จ, คุณสามารถดำเนินการเพิ่มเติมได้
        print('Login success: ${response.data}');
        Navigator.pushNamed(context, '/home'); // ไปยังหน้า home
      } else {
        // ถ้า login ไม่สำเร็จ
        print('Login failed: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.data['message']}')),
        );
      }
    } catch (e) {
      // จัดการข้อผิดพลาดจากการเรียก API
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
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
                    login(context);  // เรียกใช้ฟังก์ชัน login
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
