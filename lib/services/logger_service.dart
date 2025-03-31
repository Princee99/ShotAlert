import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// A simple logging service that outputs formatted logs to the console
class Logger {
  // Log categories
  static const String AUTH = "AUTH";
  static const String NAVIGATION = "NAV";
  static const String FILE = "FILE";
  static const String USER = "USER";
  static const String NETWORK = "NET";
  static const String SYSTEM = "SYS";
  static const String ERROR = "ERROR";

  // Log level colors (ANSI color codes for terminal)
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  /// Format a timestamp for the log
  static String _getTimestamp() {
    return DateFormat('HH:mm:ss.SSS').format(DateTime.now());
  }

  /// Log informational message
  static void info(String category, String message,
      [Map<String, dynamic>? data]) {
    _log(_green, category, message, data);
  }

  /// Log debug message
  static void debug(String category, String message,
      [Map<String, dynamic>? data]) {
    _log(_blue, category, message, data);
  }

  /// Log warning message
  static void warning(String category, String message,
      [Map<String, dynamic>? data]) {
    _log(_yellow, category, message, data);
  }

  /// Log error message
  static void error(String category, String message,
      [dynamic error, Map<String, dynamic>? data]) {
    final Map<String, dynamic> errorData = data ?? {};
    if (error != null) {
      errorData['error'] = error.toString();
    }
    _log(_red, category, message, errorData);
  }

  /// Format and print a log message
  static void _log(String color, String category, String message,
      [Map<String, dynamic>? data]) {
    final timestamp = _getTimestamp();
    final dataString = data != null ? ' - Data: $data' : '';

    // Use color in debug mode, plain in release
    debugPrint('$color[$timestamp][$category] $message$dataString$_reset');
  }

  // Convenience methods for common logging scenarios

  /// Log authentication events
  static void logAuth(String message, [Map<String, dynamic>? data]) {
    info(AUTH, message, data);
  }

  /// Log navigation events
  static void logNavigation(String from, String to,
      [Map<String, dynamic>? data]) {
    info(NAVIGATION, "From $from to $to", data);
  }

  /// Log user actions
  static void logUserAction(String action, [Map<String, dynamic>? data]) {
    info(USER, action, data);
  }

  /// Log file operations
  static void logFile(String operation, [Map<String, dynamic>? data]) {
    info(FILE, operation, data);
  }

  /// Log system events
  static void logSystem(String message, [Map<String, dynamic>? data]) {
    info(SYSTEM, message, data);
  }
}
