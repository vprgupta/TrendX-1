import '../model/country.dart';

class CountryService {
  Future<List<CountryTrend>> getCountryTrends(String country) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (country.toLowerCase()) {
      case 'usa':
        return _getUSATrends();
      case 'india':
        return _getIndiaTrends();
      case 'uk':
        return _getUKTrends();
      case 'japan':
        return _getJapanTrends();
      default:
        return [];
    }
  }

  List<CountryTrend> _getUSATrends() {
    final now = DateTime.now();
    return [
      CountryTrend(countryName: 'USA', countryFlag: '🇺🇸', rank: 1, title: 'Election Updates', description: 'Latest political developments and voting trends', category: 'Politics', popularity: 95, timestamp: now.subtract(const Duration(hours: 2)), imageUrl: 'https://picsum.photos/400/300?random=30'),
      CountryTrend(countryName: 'USA', countryFlag: '🇺🇸', rank: 2, title: 'Tech Innovation', description: 'Silicon Valley breakthrough in AI technology', category: 'Technology', popularity: 88, timestamp: now.subtract(const Duration(hours: 4))),
      CountryTrend(countryName: 'USA', countryFlag: '🇺🇸', rank: 3, title: 'Sports Championship', description: 'NFL playoffs heating up with record viewership', category: 'Sports', popularity: 82, timestamp: now.subtract(const Duration(hours: 6))),
    ];
  }

  List<CountryTrend> _getIndiaTrends() {
    final now = DateTime.now();
    return [
      CountryTrend(countryName: 'India', countryFlag: '🇮🇳', rank: 1, title: 'Bollywood News', description: 'Major film release breaks box office records', category: 'Entertainment', popularity: 92, timestamp: now.subtract(const Duration(hours: 1))),
      CountryTrend(countryName: 'India', countryFlag: '🇮🇳', rank: 2, title: 'Cricket Fever', description: 'India vs Australia series creates nationwide excitement', category: 'Sports', popularity: 89, timestamp: now.subtract(const Duration(hours: 3))),
    ];
  }

  List<CountryTrend> _getUKTrends() {
    final now = DateTime.now();
    return [
      CountryTrend(countryName: 'UK', countryFlag: '🇬🇧', rank: 1, title: 'Royal Family Update', description: 'Latest news from Buckingham Palace', category: 'Royal', popularity: 85, timestamp: now.subtract(const Duration(hours: 2))),
      CountryTrend(countryName: 'UK', countryFlag: '🇬🇧', rank: 2, title: 'Premier League', description: 'Manchester United vs Liverpool match highlights', category: 'Sports', popularity: 90, timestamp: now.subtract(const Duration(hours: 5))),
    ];
  }

  List<CountryTrend> _getJapanTrends() {
    final now = DateTime.now();
    return [
      CountryTrend(countryName: 'Japan', countryFlag: '🇯🇵', rank: 1, title: 'Anime Release', description: 'New Studio Ghibli film announcement', category: 'Entertainment', popularity: 94, timestamp: now.subtract(const Duration(hours: 1))),
      CountryTrend(countryName: 'Japan', countryFlag: '🇯🇵', rank: 2, title: 'Tech Innovation', description: 'Revolutionary robotics breakthrough in Tokyo', category: 'Technology', popularity: 87, timestamp: now.subtract(const Duration(hours: 4))),
    ];
  }
}