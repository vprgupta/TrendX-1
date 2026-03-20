import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../config/environment.dart';

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
    
    // Send to Crashlytics in all environments except development
    if (error != null && Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: false, // Non-fatal by default
      );
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