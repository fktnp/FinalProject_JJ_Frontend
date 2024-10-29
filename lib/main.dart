import 'package:flutter/material.dart';
import 'package:flutter_application_1/task.dart';
import 'goal.dart';
import 'login_screen.dart';
import 'setting.dart';
import 'todotolist.dart';
import 'calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JodJum',
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
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          SettingsPage(),
          MyCalendarView(),
          ToDoList(),
          GoalsPage(),
          TaskListPage(),
        ],
      ),
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
            backgroundColor: const Color(0xFFFFDCBC),
            selectedItemColor: const Color.fromARGB(255, 26, 26, 26),
            unselectedItemColor: const Color.fromARGB(255, 255, 123, 0),
            selectedFontSize: 0,
            unselectedFontSize: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: screenWidth * 0.10,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/Pic/settings.png',
                  width: _currentIndex == 0
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                  height: _currentIndex == 0
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/Pic/calendar.png',
                  width: _currentIndex == 1
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                  height: _currentIndex == 1
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/Pic/Task.png',
                  width: _currentIndex == 2
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                  height: _currentIndex == 2
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/Pic/goal.png',
                  width: _currentIndex == 3
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                  height: _currentIndex == 3
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/Pic/Co-op.png',
                  width: _currentIndex == 4
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                  height: _currentIndex == 4
                      ? screenWidth * 0.08
                      : screenWidth * 0.10,
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
