import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = 'AbayEqub';

  static void info(String message) {
    _log('ℹ️ [INFO]', message);
  }

  static void success(String message) {
    _log('✅ [SUCCESS]', message);
  }

  static void warning(String message) {
    _log('⚠️ [WARNING]', message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('❌ [ERROR]', '$message ${error ?? ''}', stackTrace);
  }

  static void debug(String message) {
    if (kDebugMode) {
      _log('🔍 [DEBUG]', message);
    }
  }

  static void network(String message) {
    _log('🌐 [NETWORK]', message);
  }

  static void _log(String prefix, String message, [StackTrace? stackTrace]) {
    final formattedMessage = '$prefix: $message';
    if (kDebugMode) {
      print(formattedMessage);
    }
    developer.log(
      message,
      name: _tag,
      error: prefix,
      stackTrace: stackTrace,
    );
  }
}
