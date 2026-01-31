import 'package:flutter/foundation.dart';
import '../config/environment.dart';

/// Centralized logging system with environment-aware output
class Logger {
  /// Log general messages (only in development/staging)
  static void log(String message, {String? tag}) {
    if (EnvironmentConfig.enableLogging) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }
  
  /// Log error messages with optional error object and stack trace
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (EnvironmentConfig.enableLogging) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $prefix$message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null && EnvironmentConfig.enableVerboseLogging) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
    
    // In production, this would send to crash reporting service (Firebase Crashlytics)
    // Will be implemented in Phase 2
    if (EnvironmentConfig.isProduction && error != null) {
      // TODO: Send to Crashlytics
    }
  }
  
  /// Log informational messages
  static void info(String message, {String? tag}) {
    if (EnvironmentConfig.enableLogging) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️ $prefix$message');
    }
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag}) {
    if (EnvironmentConfig.enableLogging) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️ $prefix$message');
    }
  }
  
  /// Log debug messages (only in development with verbose logging)
  static void debug(String message, {String? tag}) {
    if (EnvironmentConfig.enableVerboseLogging) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('🐛 $prefix$message');
    }
  }
}