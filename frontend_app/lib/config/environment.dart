/// Environment types for the application
enum Environment { development, staging, production }

/// Environment configuration for different deployment stages
class EnvironmentConfig {
  static Environment _current = Environment.development;
  
  /// Set the current environment
  static void setEnvironment(Environment env) {
    _current = env;
  }
  
  /// Get the current environment
  static Environment get current => _current;
  
  /// Get the API base URL based on current environment
  static String get apiBaseUrl {
    switch (_current) {
      case Environment.development:
        return 'http://10.22.31.214:3000';  // Local development server
      case Environment.staging:
        return const String.fromEnvironment('STAGING_API_URL', 
               defaultValue: 'https://staging-api.trendx.app');
      case Environment.production:
        return const String.fromEnvironment('PROD_API_URL',
               defaultValue: 'https://api.trendx.app');
    }
  }
  
  /// Check if running in production
  static bool get isProduction => _current == Environment.production;
  
  /// Check if running in development
  static bool get isDevelopment => _current == Environment.development;
  
  /// Check if running in staging
  static bool get isStaging => _current == Environment.staging;
  
  /// Enable logging based on environment
  static bool get enableLogging => !isProduction;
  
  /// Enable verbose logging (development only)
  static bool get enableVerboseLogging => isDevelopment;
}
