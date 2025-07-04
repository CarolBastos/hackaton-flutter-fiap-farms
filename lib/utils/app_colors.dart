import 'package:flutter/material.dart';

class AppColors {
  static const int _greenPrimaryValue = 0xFF47A138;

  static const MaterialColor primary =
      MaterialColor(_greenPrimaryValue, <int, Color>{
        50: Color(0xFFE8F5E9),
        100: Color(0xFFC8E6C9),
        200: Color(0xFFA5D6A7),
        300: Color(0xFF81C784),
        400: Color(0xFF66BB6A),
        500: Color(_greenPrimaryValue),
        600: Color(0xFF388E3C),
        700: Color(0xFF2E7D32),
        800: Color(0xFF1B5E20),
        900: Color(0xFF0D470E),
      });

  static const Color error = Color(0xFFFF5031);
  static const Color darkTeal = Color(0xFF004D61);
  static const Color teaGreen = Color(0xFFE4EDE3);
  static const Color grey = Color(0xFFDEE9EA);
  static const Color greyPlaceholder = Color(0xFF8B8B8B);
  static const Color white = Colors.white;
  static const Color shadow = Colors.black12;
  static const Color black = Colors.black;
  static const Color gray = Color(0xFFCBCBCB);
}
