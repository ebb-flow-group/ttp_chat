import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Returns date as date string
  String toDateString() {
    var fmt = DateFormat('yyyy-MM-dd');
    return fmt.format(this);
  }

  /// Returns date as date time string
  String toDateTimeString() {
    var fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    return fmt.format(this);
  }

  String toTimeLongString() {
    var fmt = DateFormat('HH:mm:ss');
    return fmt.format(this);
  }

  String toTimeShortString() {
    var fmt = DateFormat('HH:mm');
    return fmt.format(this);
  }
}

extension StringExtensions on String {
  String replaceFirstSlash() {
    return replaceFirst('/', '');
  }

  String replaceFirstAuth() {
    return replaceFirst('/auth/', '');
  }

  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
