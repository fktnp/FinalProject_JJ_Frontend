import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Pastel extends ThemeExtension<Pastel> {
  const Pastel({
    required this.pastel1,
    required this.pastel2,
    required this.pastelFont,
    required this.pastelFont2,
    required this.pastelProgress,
    required this.pastelIcon,
    required this.pastelBlock,
    required this.participant,
    required this.pastelColors, // เพิ่ม List<Color>
  });

  final Color? pastel1;
  final Color? pastel2;
  final Color? pastelFont;
  final Color? pastelFont2;
  final Color? pastelProgress;
  final Color? pastelIcon;
  final Color? pastelBlock;
  final Color? participant;
  final List<Color> pastelColors; // List ของสี Pastel

  @override
  Pastel copyWith({
    Color? pastel1,
    Color? pastel2,
    Color? pastelFont,
    Color? pastelFont2,
    Color? pastelProgress,
    Color? pastelIcon,
    Color? pastelBlock,
    Color? participant,
    List<Color>? pastelColors,
  }) {
    return Pastel(
      pastel1: pastel1 ?? this.pastel1,
      pastel2: pastel2 ?? this.pastel2,
      pastelFont: pastelFont ?? this.pastelFont,
      pastelFont2: pastelFont2 ?? this.pastelFont2,
      pastelProgress: pastelProgress ?? this.pastelProgress,
      pastelIcon: pastelIcon ?? this.pastelIcon,
      pastelBlock: pastelBlock ?? this.pastelBlock,
      participant: participant ?? this.participant,
      pastelColors: pastelColors ?? this.pastelColors,
    );
  }

  @override
  Pastel lerp(Pastel? other, double t) {
    if (other is! Pastel) {
      return this;
    }
    return Pastel(
      pastel1: Color.lerp(pastel1, other.pastel1, t),
      pastel2: Color.lerp(pastel2, other.pastel2, t),
      pastelFont: Color.lerp(pastelFont, other.pastelFont, t),
      pastelFont2: Color.lerp(pastelFont2, other.pastelFont2, t),
      pastelProgress: Color.lerp(pastelProgress, other.pastelProgress, t),
      pastelIcon: Color.lerp(pastelIcon, other.pastelIcon, t),
      pastelBlock: Color.lerp(pastelBlock, other.pastelBlock, t),
      participant: Color.lerp(participant, other.participant, t),
      pastelColors: List<Color>.generate(
        pastelColors.length,
        (index) => Color.lerp(
          pastelColors[index],
          other.pastelColors[index],
          t,
        )!,
      ),
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  bool _isLightTheme = true;
  static const String _themePreferenceKey = 'is_light_theme';

  ThemeNotifier() {
    // Load the saved theme when the notifier is created
    _loadThemeFromPrefs();
  }

  bool get isLightTheme => _isLightTheme;

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to light theme if no preference is saved
    _isLightTheme = prefs.getBool(_themePreferenceKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isLightTheme = !_isLightTheme;

    // Save the new theme preference
    await prefs.setBool(_themePreferenceKey, _isLightTheme);

    notifyListeners();
  }

  ThemeData get themeData {
    return _isLightTheme ? _lightTheme : _darkTheme;
  }

  static final ThemeData _lightTheme = ThemeData.light().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const Pastel(
        pastel1: Color(0xFFFFDCBC),
        pastel2: Color(0xFFFFECDB),
        pastelFont: Color.fromARGB(255, 41, 41, 41),
        pastelFont2: Color.fromARGB(255, 150, 150, 150),
        pastelProgress: Color.fromARGB(255, 155, 255, 172),
        pastelIcon: Colors.black,
        pastelBlock: Color.fromARGB(255, 190, 223, 255),
        participant: Color.fromARGB(255, 41, 41, 41),
        pastelColors: [
        Color(0xFFFFD1DC), // สี Pastel 1
        Color(0xFFB2E4FA), // สี Pastel 2
        Color(0xFFFFF4B2), // สี Pastel 3
        Color(0xFFC9FFD5), // สี Pastel 4
        Color(0xFFE2CFFF), // สี Pastel 5
      ],
      ),
    ],
  );

  static final ThemeData _darkTheme = ThemeData.dark().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const Pastel(
        pastel1: Color.fromARGB(255, 26, 26, 26),
        pastel2: Color.fromARGB(255, 44, 44, 44),
        pastelFont: Color(0xFFECDFCC),
        pastelFont2: Color.fromARGB(255, 165, 157, 144),
        pastelProgress: Color(0xFFECDFCC),
        pastelIcon: Colors.white,
        pastelBlock: Color.fromARGB(255, 90, 90, 90),
        participant: Color.fromARGB(255, 26, 26, 26),
        pastelColors: [
        Color(0xFF8E6C88), // สี Pastel 1 (โทนเข้ม)
        Color(0xFF577D91), // สี Pastel 2
        Color(0xFF6A5E4F), // สี Pastel 3
        Color(0xFF8C936D), // สี Pastel 4
        Color(0xFF725E7A), // สี Pastel 5
      ],
      ),
    ],
  );
}
