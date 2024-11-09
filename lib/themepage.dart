import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/theme.dart';

class Themepage extends StatelessWidget {
  const Themepage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final pastelTheme = Theme.of(context).extension<Pastel>()!;

    return Scaffold(
      backgroundColor: pastelTheme.pastel2, 
      appBar: AppBar(
        backgroundColor: pastelTheme.pastel1, 
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Theme', 
            style: TextStyle(
              fontSize: 20,
              color: pastelTheme.pastelFont,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!themeNotifier.isLightTheme) {
                        themeNotifier.toggleTheme(); 
                      }
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 220, 188), 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Defualt', 
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
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.black, 
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Dark', 
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
      ),
    );
  }
}
