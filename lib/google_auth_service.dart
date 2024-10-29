import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio dio = Dio();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // If the user cancels the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? token = googleAuth.idToken;
      print("token google $token");

      if (token != null) {
        // ส่ง token ไปที่ Go server
        final response = await dio.post(
          'http://192.168.1.35:8080/v1/user/google-login',
          data: {'token': token},
        );

        if (response.statusCode == 200) {
          print('Login successful: ${response.data}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        } else {
          print('Login failed: ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${response.data['message']}')),
          );
        }
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }
}
