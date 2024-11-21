import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coop.dart';
import 'goal.dart';
import 'l10n/app_localizations_delegate.dart';
import 'login_screen.dart';
import 'model/theme.dart';
import 'providers/locale_provider.dart';
import 'setting.dart';
import 'todotolist.dart';
import 'calendar.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  print(
      'Initial language code: ${prefs.getString('language_code')}'); // Debug print
  await dotenv.load(fileName: "assets/env/api.env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EnvProvider()..loadEnv()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class EnvProvider with ChangeNotifier {
  String _apiUrl = '';

  String get apiUrl => _apiUrl;

  Future<void> loadEnv() async {
    try {
      _apiUrl = dotenv.env['API_URL'] ?? 'https://default.com/api';
      print('Loaded API_URL: $_apiUrl');
      notifyListeners();
    } catch (e) {
      print('Error in EnvProvider: $e');
    }
  }
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
        return Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
          print(
              'Building MaterialApp with locale: ${localeProvider.locale.languageCode}');
          return MaterialApp(
            title: 'My App',
            theme: themeNotifier.themeData,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('th'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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
                          return const Center(
                              child: CircularProgressIndicator());
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
        });
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
  int _currentIndex = 2;
  @override
  void initState() {
    super.initState();
    _triggerServerCreation(); // เรียกใช้ฟังก์ชันเมื่อแอพเริ่มทำงาน
  }

  Future<void> _triggerServerCreation() async {
    final apiUrl = Provider.of<EnvProvider>(context, listen: false).apiUrl;
    final url = '$apiUrl/v1/calendar/subjob/user/${widget.userId}';

    try {
      final response =
          await http.get(Uri.parse(url)); // ใช้ GET ตามที่ตั้งค่าใน Postman
      if (response.statusCode == 200) {
        print(url);
        print('Server triggered successfully');
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
      body: _getPage(_currentIndex, pastel),
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

  Widget _getPage(int index, Pastel pastel) {
    switch (index) {
      case 0:
        return SettingsPage(userId: widget.userId);
      case 1:
        return MyCalendarView(
          userId: widget.userId,
          pastel: pastel,
        );
      case 2:
        return ToDoList(userId: widget.userId);
      case 3:
        return GoalsPage(userId: widget.userId);
      case 4:
        return CoopPage(userId: widget.userId);
      default:
        return ToDoList(userId: widget.userId);
    }
  }
}
