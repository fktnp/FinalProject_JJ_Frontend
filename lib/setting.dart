import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDCBC),
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Settings',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.palette, size: 50),
              title: const Text(
                'Theme',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, size: 50),
              title: const Text(
                'Sign out',
                style: TextStyle(fontSize: 24),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Sign out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(seconds: 1),
                                pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  var begin = const Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
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
