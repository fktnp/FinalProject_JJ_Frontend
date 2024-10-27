import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/theme.dart';

class Themepage extends StatelessWidget {
  const Themepage({super.key});

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
