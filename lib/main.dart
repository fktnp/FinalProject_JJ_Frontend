import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coop.dart';
import 'goal.dart';
import 'login_screen.dart';
import 'model/theme.dart';
import 'setting.dart';
import 'todotolist.dart';
import 'calendar.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeNotifier(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'My App',
          theme: themeNotifier.themeData,
          home: FutureBuilder<bool>(
            future: checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.data == true) {
                  return FutureBuilder<String?>(
                    future: _getUserId(),
                    builder: (context, userIdSnapshot) {
                      if (userIdSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return MyHomePage(userId: userIdSnapshot.data ?? '');
                      }
                    },
                  );
                } else {
                  return const LoginScreen();
                }
              }
            },
          ),
        );
      },
    );
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}

class MyHomePage extends StatefulWidget {
  final String userId;

  const MyHomePage({
    super.key,
    required this.userId,
  });

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1;
  @override
  void initState() {
    super.initState();
    _triggerServerCreation(); // เรียกใช้ฟังก์ชันเมื่อแอพเริ่มทำงาน
  }

  Future<void> _triggerServerCreation() async {
    final url = 'http://10.0.2.2:8080/v1/calendar/subjob/user/${widget.userId}';

    try {
      final response =
          await http.get(Uri.parse(url)); // ใช้ GET ตามที่ตั้งค่าใน Postman
      if (response.statusCode == 200) {
        print('Server triggered successfully');
        print('http://10.0.2.2:8080/v1/calendar/subjob/user/${widget.userId}');
      } else {
        print('Failed to trigger server: ${response.statusCode}');
      }
    } catch (error) {
      print('Error triggering server: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;

    return Scaffold(
      body: _getPage(_currentIndex),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: screenHeight * 0.08,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: pastel.pastel1,
            selectedItemColor: const Color.fromARGB(255, 26, 26, 26),
            unselectedItemColor: const Color.fromARGB(255, 255, 123, 0),
            selectedFontSize: 0,
            unselectedFontSize: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: screenWidth * 0.10,
            items: [
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ?? Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'lib/Pic/settings.png',
                    width: _currentIndex == 0
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                    height: _currentIndex == 0
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ?? Colors.black,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'lib/Pic/calendar.png',
                    width: _currentIndex == 1
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                    height: _currentIndex == 1
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ?? Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'lib/Pic/Task.png',
                    width: _currentIndex == 2
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                    height: _currentIndex == 2
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ?? Colors.black,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'lib/Pic/goal.png',
                    width: _currentIndex == 3
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                    height: _currentIndex == 3
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ?? Colors.black,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'lib/Pic/Co-op.png',
                    width: _currentIndex == 4
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                    height: _currentIndex == 4
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SettingsPage(userId: widget.userId);
      case 1:
        return MyCalendarView(userId: widget.userId);
      case 2:
        return ToDoList(userId: widget.userId);
      case 3:
        return GoalsPage(userId: widget.userId);
      case 4:
        return CoopPage(userId: widget.userId);
      default:
        return MyCalendarView(userId: widget.userId);
    }
  }
}
