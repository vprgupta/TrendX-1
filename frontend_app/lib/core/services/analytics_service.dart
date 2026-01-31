class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  void trackPlatformView(String platform) {
    print('Analytics: Platform viewed - $platform');
  }

  void trackTrendClick(String platform, String trendTitle) {
    print('Analytics: Trend clicked - $platform: $trendTitle');
  }

  void trackSearch(String query, String platform) {
    print('Analytics: Search performed - $query on $platform');
  }

  void trackFilter(String filterType, String value) {
    print('Analytics: Filter applied - $filterType: $value');
  }

  void trackVideoPlay(String platform, String videoId) {
    print('Analytics: Video played - $platform: $videoId');
  }
}