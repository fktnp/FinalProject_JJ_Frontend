import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'language.dart';
import 'model/theme.dart';
import 'profile.dart';
import 'themepage.dart';

class SettingsPage extends StatefulWidget {
  final String userId;
  const SettingsPage({
    super.key,
    required this.userId,
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
          alignment: Alignment.center,
          child: Text(
            overflow: TextOverflow.ellipsis,
            AppLocalizations.of(context).translate('settings'),
            style: TextStyle(
                color: pastel.pastelFont, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: pastel.pastel2,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: const Icon(Icons.person, size: 50),
              title: Text(
                overflow: TextOverflow.ellipsis,
                AppLocalizations.of(context).translate('profile'),
                style: TextStyle(fontSize: 24, color: pastel.pastelFont),
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
                overflow: TextOverflow.ellipsis,
                AppLocalizations.of(context).translate('theme'),
                style: TextStyle(fontSize: 24, color: pastel.pastelFont),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Themepage()));
              },
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.language, size: 50),
              title: Text(
                overflow: TextOverflow.ellipsis,
                AppLocalizations.of(context).translate('language'),
                style: TextStyle(fontSize: 24, color: pastel.pastelFont),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LanguageSetting()));
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, size: 50),
              title: Text(
                overflow: TextOverflow.ellipsis,
                AppLocalizations.of(context).translate('sign_out'),
                style: TextStyle(fontSize: 24, color: pastel.pastelFont),
              ),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                          overflow: TextOverflow.ellipsis,
                          AppLocalizations.of(context)
                              .translate('confirm_sign_out')),
                      content: Text(
                          overflow: TextOverflow.ellipsis,
                          AppLocalizations.of(context).translate('sure')),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                              overflow: TextOverflow.ellipsis,
                              AppLocalizations.of(context).translate('cancel')),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                              overflow: TextOverflow.ellipsis,
                              AppLocalizations.of(context).translate('yes')),
                          onPressed: () async {
                            // ลบข้อมูลที่เกี่ยวข้องกับการล็อกอิน
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.remove('isLoggedIn');
                            await prefs.remove('user_id');

                            // นำผู้ใช้กลับไปที่หน้า LoginScreen
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(seconds: 1),
                                pageBuilder: (context, animation,
                                        secondaryAnimation) =>
                                    const LoginScreen(), // ไปที่หน้า LoginScreen
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
