import 'package:intl/intl.dart';

/// Utilitário para formatação de datas no padrão brasileiro
class DateFormatter {
  /// Formata uma data para o padrão dd/mm/YYYY hh:mm
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final dataFormatada = DateFormatter.formatDateTime(DateTime.now());
  /// // Resultado: "25/12/2024 14:30"
  /// ```
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Formata uma data para o padrão dd/mm/YYYY (apenas data)
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final dataFormatada = DateFormatter.formatDate(DateTime.now());
  /// // Resultado: "25/12/2024"
  /// ```
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Formata uma data para o padrão hh:mm (apenas hora)
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final horaFormatada = DateFormatter.formatTime(DateTime.now());
  /// // Resultado: "14:30"
  /// ```
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Formata uma data para o padrão dd/mm/YYYY hh:mm:ss (com segundos)
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final dataCompleta = DateFormatter.formatDateTimeWithSeconds(DateTime.now());
  /// // Resultado: "25/12/2024 14:30:45"
  /// ```
  static String formatDateTimeWithSeconds(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  /// Formata uma data para exibição relativa (hoje, ontem, etc.)
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final dataRelativa = DateFormatter.formatRelative(DateTime.now());
  /// // Resultado: "Hoje às 14:30" ou "Ontem às 14:30"
  /// ```
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Hoje às ${formatTime(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'Ontem às ${formatTime(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }
}
