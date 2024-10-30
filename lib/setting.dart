import 'package:flutter/material.dart';
import 'model/theme.dart';
import 'main.dart';
import 'profile.dart';
import 'themepage.dart'; // เพิ่มการนำเข้า ProfileScreen

class SettingsPage extends StatefulWidget {
  final String userId;
  const SettingsPage({
    super.key, required this.userId,
  });
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pastel.pastel1,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Settings',
            style: TextStyle(color: pastel.pastelFont),
            textAlign: TextAlign.right,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: pastel.pastel2,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person, size: 50),
              title: Text(
                'Profile',
                style: TextStyle(fontSize: 24,color: pastel.pastelFont),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.palette, size: 50),
              title: Text(
                'Theme',
                style: TextStyle(fontSize: 24,color: pastel.pastelFont),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Themepage()));
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, size: 50),
              title: Text(
                'Sign out',
                style: TextStyle(fontSize: 24,color: pastel.pastelFont),
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
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const MyApps(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var begin = const Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.easeInOut;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
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
