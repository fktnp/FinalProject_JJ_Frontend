import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyTryApp(),
    ),
  );
}

class MyTryApp extends StatelessWidget {
  const MyTryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'My App',
          theme: themeNotifier.themeData,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pastel = Theme.of(context).extension<Pastel>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(width: 100, height: 100, color: pastel.pastel1),
            const SizedBox(width: 10),
            Container(width: 100, height: 100, color: pastel.pastel2),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Theme Settings'),
            Switch(
              value: Provider.of<ThemeNotifier>(context).isLightTheme,
              onChanged: (value) {
                Provider.of<ThemeNotifier>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ],
        ),
      ),
    );
  }
}
