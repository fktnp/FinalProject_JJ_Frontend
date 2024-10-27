import 'package:flutter/material.dart';

class Pastel extends ThemeExtension<Pastel> {
  const Pastel({
    required this.pastel1,
    required this.pastel2,
  });

  final Color? pastel1;
  final Color? pastel2;

  @override
  Pastel copyWith({
    Color? pastel1,
    Color? pastel2,
  }) {
    return Pastel(
      pastel1: pastel1 ?? this.pastel1,
      pastel2: pastel2 ?? this.pastel2,
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
        pastel1: Color(0xFF90CAF9),
        pastel2: Color.fromARGB(255, 181, 212, 236),
      ),
      const Dark(
        dark1: Color(0xFFEF9A9A),
        dark2: Color.fromARGB(255, 243, 199, 199),
      ),
    ],
  );
}
