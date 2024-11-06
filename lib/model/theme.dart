import 'package:flutter/material.dart';

class Pastel extends ThemeExtension<Pastel> {
  const Pastel({
    required this.pastel1,
    required this.pastel2,
    required this.pastelFont,
    required this.pastelFont2,
    required this.pastelProgress,
    required this.pastelIcon,
  });

  final Color? pastel1;
  final Color? pastel2;
  final Color? pastelFont;
  final Color? pastelFont2;
  final Color? pastelProgress;
  final Color? pastelIcon;

  @override
  Pastel copyWith({
    Color? pastel1,
    Color? pastel2,
    Color? pastelFont,
    Color? pastelFont2,
    Color? pastelProgress,
    Color? pastelIcon,
  }) {
    return Pastel(
      pastel1: pastel1 ?? this.pastel1,
      pastel2: pastel2 ?? this.pastel2,
      pastelFont: pastelFont ?? this.pastelFont,
      pastelFont2: pastelFont2 ?? this.pastelFont2,
      pastelProgress: pastelProgress ?? this.pastelProgress,
      pastelIcon: pastelIcon ?? this.pastelIcon,
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
    );
  }

  // Optional
  // @override
  // String toString() => 'Pastel(brandColor: $pastel1, danger: $dark2)';
}

class Dark extends ThemeExtension<Dark> {
  const Dark({
    required this.dark1,
    required this.dark2,
  });

  final Color? dark1;
  final Color? dark2;

  @override
  Dark copyWith({Color? dark1, Color? dark2}) {
    return Dark(
      dark1: dark1 ?? this.dark1,
      dark2: dark2 ?? this.dark2,
    );
  }

  @override
  Dark lerp(Dark? other, double t) {
    if (other is! Dark) {
      return this;
    }
    return Dark(
      dark1: Color.lerp(dark1, other.dark1, t),
      dark2: Color.lerp(dark2, other.dark2, t),
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  bool isLightTheme = true;

  void toggleTheme() {
    isLightTheme = !isLightTheme;
    notifyListeners();
  }

  ThemeData get themeData {
    return isLightTheme ? _lightTheme : _darkTheme;
  }

  static final ThemeData _lightTheme = ThemeData.light().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const Pastel(
        pastel1: Color(0xFFFFDCBC),
        pastel2: Color(0xFFFFECDB),
        pastelFont: Color.fromARGB(255, 41, 41, 41),
        pastelFont2: Color.fromARGB(255, 150, 150, 150),
        pastelProgress: Color.fromARGB(255, 92, 216, 97),
        pastelIcon: Colors.black,
      ),
      const Dark(
        dark1: Color(0xFFE53935),
        dark2: Color.fromARGB(255, 223, 97, 95),
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
      ),
      const Dark(
        dark1: Color(0xFFEF9A9A),
        dark2: Color.fromARGB(255, 243, 199, 199),
      ),
    ],
  );
}
