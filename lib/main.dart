import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/mainjobmodel.dart';
import 'package:provider/provider.dart';
import 'goal.dart';
import 'login_screen.dart';
import 'model/theme.dart';
import 'setting.dart';
import 'todotolist.dart';
import 'calendar.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeNotifier(),
    child: const MyApps(),
  ));
}

class MyApps extends StatelessWidget {
  const MyApps({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
            title: 'My App',
            theme: themeNotifier.themeData,
            home: const LoginScreen());
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String userId; // เพิ่ม userId parameter

  const MyHomePage({
    super.key,
    required this.userId, // รับ userId จาก constructor
  });

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
    final Pastel pastel = Theme.of(context).extension<Pastel>()!;

    return Scaffold(
      body: _getPage(_currentIndex), // ใช้ฟังก์ชันแยกหน้าแทน IndexedStack
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
                    pastel.pastelFont ??
                        Colors.white, // สีขาวที่ต้องการเปลี่ยนเป็น
                    BlendMode.srcIn, // โหมดการผสมสีที่จะเปลี่ยนสีของภาพ
                  ),
                  child: Image.asset(
                    'lib/Pic/settings.png',
                    width: _currentIndex == 0
                        ? screenWidth * 0.08
                        : screenWidth * 0.10, // ยุบลงถ้าเลือก
                    height: _currentIndex == 0
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ), // รูปภาพที่ต้องการเปลี่ยนสี
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ??
                        Colors.black, // สีขาวที่ต้องการเปลี่ยนเป็น
                    BlendMode.srcIn, // โหมดการผสมสีที่จะเปลี่ยนสีของภาพ
                  ),
                  child: Image.asset(
                    'lib/Pic/calendar.png',
                    width: _currentIndex == 1
                        ? screenWidth * 0.08
                        : screenWidth * 0.10, // ยุบลงถ้าเลือก
                    height: _currentIndex == 1
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ), // รูปภาพที่ต้องการเปลี่ยนสี
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ??
                        Colors.white, // สีขาวที่ต้องการเปลี่ยนเป็น
                    BlendMode.srcIn, // โหมดการผสมสีที่จะเปลี่ยนสีของภาพ
                  ),
                  child: Image.asset(
                    'lib/Pic/Task.png',
                    width: _currentIndex == 2
                        ? screenWidth * 0.08
                        : screenWidth * 0.10, // ยุบลงถ้าเลือก
                    height: _currentIndex == 2
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ), // รูปภาพที่ต้องการเปลี่ยนสี
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ??
                        Colors.black, // สีขาวที่ต้องการเปลี่ยนเป็น
                    BlendMode.srcIn, // โหมดการผสมสีที่จะเปลี่ยนสีของภาพ
                  ),
                  child: Image.asset(
                    'lib/Pic/goal.png',
                    width: _currentIndex == 3
                        ? screenWidth * 0.08
                        : screenWidth * 0.10, // ยุบลงถ้าเลือก
                    height: _currentIndex == 3
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ), // รูปภาพที่ต้องการเปลี่ยนสี
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    pastel.pastelFont ??
                        Colors.black, // สีขาวที่ต้องการเปลี่ยนเป็น
                    BlendMode.srcIn, // โหมดการผสมสีที่จะเปลี่ยนสีของภาพ
                  ),
                  child: Image.asset(
                    'lib/Pic/Co-op.png',
                    width: _currentIndex == 4
                        ? screenWidth * 0.08
                        : screenWidth * 0.10, // ยุบลงถ้าเลือก
                    height: _currentIndex == 4
                        ? screenWidth * 0.08
                        : screenWidth * 0.10,
                  ), // รูปภาพที่ต้องการเปลี่ยนสี
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
        return const TaskListPage();
      default:
        return const TaskListPage();
    }
  }
}
