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

  // Cores de status
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;
  static const Color secondary = Colors.purple;
  static const Color danger = Colors.red;
  static const Color statusPlanejado2 = Colors.purple;
  static const Color statusAtivo = Colors.blue;
  static const Color statusAtingido = Colors.green;
  static const Color statusNaoAtingido = Colors.red;

  // Cores de erro e feedback
  static const Color error = Color(0xFFFF5031);
  static const Color errorLight = Color(0xFFFFEBEE); // Colors.red.shade50
  static const Color errorBorder = Color(0xFFEF9A9A); // Colors.red.shade200
  static const Color errorText = Color(0xFFC62828); // Colors.red.shade700

  // Cores de fundo e superfície
  static const Color darkTeal = Color(0xFF004D61);
  static const Color teaGreen = Color(0xFFE4EDE3);
  static const Color grey = Color(0xFFDEE9EA);
  static const Color greyLight = Color(0xFFF5F5F5); // Colors.grey.shade200
  static const Color greyMedium = Color(0xFF757575); // Colors.grey.shade600
  static const Color greyPlaceholder = Color(0xFF8B8B8B);
  static const Color white = Colors.white;
  static const Color shadow = Colors.black12;
  static const Color black = Colors.black;
  static const Color gray = Color(0xFFCBCBCB);

  // Cores de texto
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF757575); // Colors.grey.shade600
  static const Color textLight = Color(0xFF9E9E9E); // Colors.grey
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Color(0xB3FFFFFF); // Colors.white70

  // Cores de status específicas para produção
  static const Color statusPlanejado = Colors.blue;
  static const Color statusAguardando = Colors.orange;
  static const Color statusEmProducao = Colors.green;
  static const Color statusColhido = Colors.purple;
  static const Color statusCancelado = Colors.red;
}
