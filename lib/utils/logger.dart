import 'dart:developer' as developer;

class Logger {
  static void info(String message, [String? name]) {
    developer.log(message, name: name ?? 'INFO');
  }
  
  static void error(String message, [String? name, Object? error]) {
    developer.log(message, name: name ?? 'ERROR', error: error);
  }
  
  static void debug(String message, [String? name]) {
    developer.log(message, name: name ?? 'DEBUG');
  }
  
  static void warning(String message, [String? name]) {
    developer.log(message, name: name ?? 'WARNING');
  }
}