import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        // คุณสามารถใช้ googleAuth.accessToken และ googleAuth.idToken เพื่อเข้าสู่ระบบกับเซิร์ฟเวอร์ของคุณได้
        print('Google Sign-In successful: ${googleAuth.accessToken}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()), // ไปยังหน้า home
        );
      }
    } catch (error) {
      print('Google Sign-In failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $error')),
      );
    }
  }
}
