import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'model/theme.dart';

class Themepage extends StatelessWidget {
  const Themepage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final pastelTheme = Theme.of(context).extension<Pastel>()!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: pastelTheme.pastel2,
      appBar: AppBar(
        backgroundColor: pastelTheme.pastel1,
        title: Text(
          AppLocalizations.of(context).translate('theme'),
          style: TextStyle(
            fontSize: 20,
            color: pastelTheme.pastelFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!themeNotifier.isLightTheme) {
                      themeNotifier.toggleTheme();
                    }
                  },
                  child: Container(
                    height: screenWidth * 0.3,
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 220, 188),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).translate('light_mode'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    if (themeNotifier.isLightTheme) {
                      themeNotifier.toggleTheme();
                    }
                  },
                  child: Container(
                    height: screenWidth * 0.3,
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).translate('dark_mode'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
