import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/logger.dart';
import '../../config/environment.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? get _analytics {
    if (Firebase.apps.isNotEmpty) {
      return FirebaseAnalytics.instance;
    }
    return null;
  }

  void trackPlatformView(String platform) {
    Logger.log('Analytics: Platform viewed - $platform', tag: 'Analytics');
    if (!EnvironmentConfig.isDevelopment) {
      _analytics?.logEvent(
        name: 'platform_view',
        parameters: {'platform': platform},
      );
    }
  }

  void trackTrendClick(String platform, String trendTitle) {
    Logger.log('Analytics: Trend clicked - $platform: $trendTitle', tag: 'Analytics');
    if (!EnvironmentConfig.isDevelopment) {
      _analytics?.logEvent(
        name: 'trend_click',
        parameters: {
          'platform': platform,
          'trend': trendTitle,
        },
      );
    }
  }

  void trackSearch(String query, String platform) {
    Logger.log('Analytics: Search - $query on $platform', tag: 'Analytics');
    if (!EnvironmentConfig.isDevelopment) {
      _analytics?.logEvent(
        name: 'search',
        parameters: {
          'query': query,
          'platform': platform,
        },
      );
    }
  }

  void trackFilter(String filterType, String value) {
    Logger.log('Analytics: Filter - $filterType: $value', tag: 'Analytics');
    if (!EnvironmentConfig.isDevelopment) {
      _analytics?.logEvent(
        name: 'filter_applied',
        parameters: {
          'type': filterType,
          'value': value,
        },
      );
    }
  }

  void trackVideoPlay(String platform, String videoId) {
    Logger.log('Analytics: Video play - $platform: $videoId', tag: 'Analytics');
    if (!EnvironmentConfig.isDevelopment) {
      _analytics?.logEvent(
        name: 'video_play',
        parameters: {
          'platform': platform,
          'video_id': videoId,
        },
      );
    }
  }
}