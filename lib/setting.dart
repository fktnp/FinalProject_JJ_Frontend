import 'package:flutter/material.dart';
import 'login_screen.dart';

class SettingsPage extends StatelessWidget {

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDCBC),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Setting',
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.right,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: const Color(0xFFFFECDB),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person, size: 50),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
               
              },
            ),
            const SizedBox(height: 30),  
            ListTile(
              leading: const Icon(Icons.palette, size: 50),
              title: const Text(
                'Theme',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
              
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, size: 50),
              title: const Text(
                'Sign out',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
