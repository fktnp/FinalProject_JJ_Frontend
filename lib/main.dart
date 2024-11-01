import 'package:flutter/material.dart';
import 'goal.dart';
import 'login_screen.dart';
import 'setting.dart';
import 'task.dart';
import 'todotoday.dart';
import 'calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          SettingsPage(),
          CalendarView(),
          TryTodotoday(),
          GoalsPage(),
          TaskList(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: screenHeight * 0.088,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFFFFDCBC),
          selectedItemColor: const Color.fromARGB(255, 26, 26, 26),
          unselectedItemColor: const Color.fromARGB(255, 255, 123, 0),
          selectedFontSize: screenHeight * 0.02,
          unselectedFontSize: 0,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'lib/Pic/settings.png',
                width: _currentIndex == 0 ? 32 : 38,
                height: _currentIndex == 0 ? 32 : 38,
              ),
              label: 'Setting',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'lib/Pic/calendar.png',
                width: _currentIndex == 1 ? 32 : 38,
                height: _currentIndex == 1 ? 32 : 38,
              ),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'lib/Pic/Task.png',
                width: _currentIndex == 2 ? 32 : 38,
                height: _currentIndex == 2 ? 32 : 38,
              ),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'lib/Pic/goal.png',
                width: _currentIndex == 3 ? 32 : 38,
                height: _currentIndex == 3 ? 32 : 38,
              ),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'lib/Pic/Co-op.png',
                width: _currentIndex == 4 ? 32 : 38,
                height: _currentIndex == 4 ? 32 : 38,
              ),
              label: 'Co-op',
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildPage(String title) {
  //   return Center(
  //     child: Text(
  //       title,
  //       style: const TextStyle(fontSize: 24),
  //     ),
  //   );
  // }
}
