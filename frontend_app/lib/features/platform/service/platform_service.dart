import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/platform.dart';
import '../../../services/youtube_service.dart';
import '../../../services/web_scraper_service.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../config/api_config.dart';

class PlatformService {
  final AnalyticsService _analytics = AnalyticsService();

  Future<List<PlatformTrend>> getPlatformTrends(String platform, [String? countryCode]) async {
    _analytics.trackPlatformView(platform);
    
    // Skip cache for now to ensure fresh data
    // final cached = await CacheService.getCachedTrends(platform, countryCode ?? 'US');
    // if (cached != null) {
    //   return cached;
    // }

    switch (platform.toLowerCase()) {
      case 'instagram':
        return await _getInstagramTrends();
      case 'facebook':
        await Future.delayed(const Duration(milliseconds: 500));
        return _getFacebookTrends();
      case 'twitter':
        return await _getTwitterTrends();
      case 'youtube':
        return await _getYoutubeTrends(countryCode ?? 'US');
      case 'tiktok':
        return await _getTiktokTrends();
      case 'linkedin':
        await Future.delayed(const Duration(milliseconds: 500));
        return _getLinkedinTrends();
      case 'reddit':
        return await _getRedditTrends();
      case 'snapchat':
        await Future.delayed(const Duration(milliseconds: 500));
        return _getSnapchatTrends();
      default:
        return [];
    }
  }

  Future<List<PlatformTrend>> _getInstagramTrends() async {
    try {
      final scraperService = WebScraperService();
      final trends = await scraperService.getInstagramTrends();
      print('Instagram scraping result: ${trends.length} trends found');
      
      final usernames = ['@insta_viral', '@trend_setter', '@social_buzz', '@viral_content', '@hashtag_hero', '@content_king', '@trend_master', '@viral_queen', '@social_star', '@insta_famous'];
      
      final platformTrends = trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        return PlatformTrend(
          platformName: 'Instagram',
          rank: index + 1,
          title: trend['name'],
          userName: usernames[index % usernames.length],
          userAvatarUrl: 'https://i.pravatar.cc/150?img=${index + 1}',
          mediaUrl: 'https://picsum.photos/400/300?random=${index + 1}',
          caption: trend['description'],
          likes: trend['posts'] ?? 100000,
          comments: (trend['posts'] ?? 100000) ~/ 20,
          shares: (trend['posts'] ?? 100000) ~/ 50,
          timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
        );
      }).toList();
      
      return platformTrends.isNotEmpty ? platformTrends : _getFallbackInstagramTrends();
    } catch (e) {
      return _getFallbackInstagramTrends();
    }
  }

  List<PlatformTrend> _getFallbackInstagramTrends() {
    final now = DateTime.now();
    return [
      PlatformTrend(platformName: 'Instagram', rank: 1, title: 'Exploring Bali 🌴', userName: '@travelbuddy', userAvatarUrl: 'https://i.pravatar.cc/150?img=1', mediaUrl: 'https://picsum.photos/400/300?random=1', caption: 'Just witnessed the most incredible sunset at Uluwatu Temple! 🌅', likes: 4200, comments: 300, shares: 85, timestamp: now.subtract(const Duration(hours: 2))),
      PlatformTrend(platformName: 'Instagram', rank: 2, title: 'New AI filter going viral', userName: '@aiartist', userAvatarUrl: 'https://i.pravatar.cc/150?img=2', mediaUrl: 'https://picsum.photos/400/300?random=2', caption: 'OMG this new AI filter is absolutely MIND-BLOWING! 🤯', likes: 5100, comments: 420, shares: 150, timestamp: now.subtract(const Duration(hours: 4))),
      PlatformTrend(platformName: 'Instagram', rank: 3, title: 'Food styling challenge', userName: '@foodiegram', userAvatarUrl: 'https://i.pravatar.cc/150?img=3', mediaUrl: 'https://picsum.photos/400/300?random=3', caption: 'Homemade pasta perfection 🍝 #FoodStyling', likes: 3800, comments: 250, shares: 90, timestamp: now.subtract(const Duration(hours: 6))),
      PlatformTrend(platformName: 'Instagram', rank: 4, title: 'Fitness transformation', userName: '@fitlife', userAvatarUrl: 'https://i.pravatar.cc/150?img=4', caption: '6 months progress! Consistency is key 💪', likes: 2900, comments: 180, shares: 65, timestamp: now.subtract(const Duration(hours: 8))),
      PlatformTrend(platformName: 'Instagram', rank: 5, title: 'Pet costume party', userName: '@petlover', userAvatarUrl: 'https://i.pravatar.cc/150?img=5', mediaUrl: 'https://picsum.photos/400/300?random=5', caption: 'My dog as a superhero! 🦸♂️🐕', likes: 6700, comments: 450, shares: 200, timestamp: now.subtract(const Duration(hours: 10))),
      PlatformTrend(platformName: 'Instagram', rank: 6, title: 'Street art discovery', userName: '@urbanexplorer', userAvatarUrl: 'https://i.pravatar.cc/150?img=6', mediaUrl: 'https://picsum.photos/400/300?random=6', caption: 'Found this amazing mural in downtown! 🎨', likes: 2100, comments: 150, shares: 45, timestamp: now.subtract(const Duration(hours: 12))),
      PlatformTrend(platformName: 'Instagram', rank: 7, title: 'Fashion week highlights', userName: '@fashionista', userAvatarUrl: 'https://i.pravatar.cc/150?img=7', mediaUrl: 'https://picsum.photos/400/300?random=7', caption: 'Paris Fashion Week was incredible! ✨', likes: 8900, comments: 670, shares: 320, timestamp: now.subtract(const Duration(hours: 14))),
      PlatformTrend(platformName: 'Instagram', rank: 8, title: 'Coffee art mastery', userName: '@barista_pro', userAvatarUrl: 'https://i.pravatar.cc/150?img=8', mediaUrl: 'https://picsum.photos/400/300?random=8', caption: 'Latte art level: Expert ☕', likes: 1800, comments: 120, shares: 35, timestamp: now.subtract(const Duration(hours: 16))),
      PlatformTrend(platformName: 'Instagram', rank: 9, title: 'Gaming setup reveal', userName: '@gamer_elite', userAvatarUrl: 'https://i.pravatar.cc/150?img=9', mediaUrl: 'https://picsum.photos/400/300?random=9', caption: 'Finally completed my dream setup! 🎮', likes: 5600, comments: 890, shares: 210, timestamp: now.subtract(const Duration(hours: 18))),
      PlatformTrend(platformName: 'Instagram', rank: 10, title: 'Nature photography', userName: '@wildlifecapture', userAvatarUrl: 'https://i.pravatar.cc/150?img=10', mediaUrl: 'https://picsum.photos/400/300?random=10', caption: 'Captured this rare bird in the wild 📸', likes: 3400, comments: 280, shares: 95, timestamp: now.subtract(const Duration(hours: 20))),
    ];
  }

  List<PlatformTrend> _getFacebookTrends() {
    final now = DateTime.now();
    return [
      PlatformTrend(platformName: 'Facebook', rank: 1, title: 'Local election results', userName: 'City News', userAvatarUrl: 'https://i.pravatar.cc/150?img=6', caption: 'Breaking: Election results are in! Record turnout in our city.', likes: 1200, comments: 89, shares: 45, timestamp: now.subtract(const Duration(hours: 1))),
      PlatformTrend(platformName: 'Facebook', rank: 2, title: 'Community fundraiser', userName: 'Help Center', userAvatarUrl: 'https://i.pravatar.cc/150?img=7', caption: 'Help us reach our goal for the local animal shelter! Every donation counts.', likes: 890, comments: 67, shares: 120, timestamp: now.subtract(const Duration(hours: 3))),
      PlatformTrend(platformName: 'Facebook', rank: 3, title: 'Recipe sharing group', userName: 'Grandma\'s Kitchen', userAvatarUrl: 'https://i.pravatar.cc/150?img=8', mediaUrl: 'https://picsum.photos/400/300?random=8', caption: 'Secret family recipe for chocolate chip cookies! 🍪', likes: 2100, comments: 156, shares: 78, timestamp: now.subtract(const Duration(hours: 5))),
      PlatformTrend(platformName: 'Facebook', rank: 4, title: 'Local business spotlight', userName: 'Downtown Coffee', userAvatarUrl: 'https://i.pravatar.cc/150?img=9', caption: 'New seasonal menu is here! Come try our pumpkin spice everything ☕', likes: 567, comments: 34, shares: 23, timestamp: now.subtract(const Duration(hours: 7))),
      PlatformTrend(platformName: 'Facebook', rank: 5, title: 'Book club discussion', userName: 'Page Turners', userAvatarUrl: 'https://i.pravatar.cc/150?img=10', caption: 'This month\'s book discussion was amazing! Next up: sci-fi thriller 📚', likes: 234, comments: 45, shares: 12, timestamp: now.subtract(const Duration(hours: 9))),
    ];
  }

  Future<List<PlatformTrend>> _getTwitterTrends() async {
    try {
      final scraperService = WebScraperService();
      final trends = await scraperService.getTwitterTrends();
      print('Twitter scraping result: ${trends.length} trends found');
      
      final usernames = ['@news_break', '@viral_tweets', '@trend_alert', '@twitter_buzz', '@social_pulse', '@tweet_storm', '@viral_now', '@trend_watch', '@twitter_viral', '@social_trends'];
      
      final platformTrends = trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        return PlatformTrend(
          platformName: 'Twitter',
          rank: index + 1,
          title: trend['name'],
          userName: usernames[index % usernames.length],
          userAvatarUrl: 'https://i.pravatar.cc/150?img=${index + 11}',
          caption: trend['description'],
          likes: trend['tweet_volume'] ?? 50000,
          comments: (trend['tweet_volume'] ?? 50000) ~/ 10,
          shares: (trend['tweet_volume'] ?? 50000) ~/ 20,
          timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
        );
      }).toList();
      
      return platformTrends.isNotEmpty ? platformTrends : _getFallbackTwitterTrends();
    } catch (e) {
      return _getFallbackTwitterTrends();
    }
  }

  List<PlatformTrend> _getFallbackTwitterTrends() {
    final now = DateTime.now();
    return [
      PlatformTrend(platformName: 'Twitter', rank: 1, title: 'Breaking: Major tech announcement', userName: '@TechNews', userAvatarUrl: 'https://i.pravatar.cc/150?img=11', caption: 'JUST IN: Revolutionary AI breakthrough announced at tech conference 🧵', likes: 125000, comments: 12500, shares: 6250, timestamp: now.subtract(const Duration(minutes: 30))),
      PlatformTrend(platformName: 'Twitter', rank: 2, title: 'Climate summit reaches historic deal', userName: '@WorldNews', userAvatarUrl: 'https://i.pravatar.cc/150?img=12', caption: '🌍 BREAKING: 195 countries agree on landmark climate action plan', likes: 98000, comments: 9800, shares: 4900, timestamp: now.subtract(const Duration(hours: 1))),
      PlatformTrend(platformName: 'Twitter', rank: 3, title: 'Viral dance challenge takes over', userName: '@TrendAlert', userAvatarUrl: 'https://i.pravatar.cc/150?img=13', caption: 'The #NewDanceChallenge is everywhere! 🕺💃', likes: 76000, comments: 7600, shares: 3800, timestamp: now.subtract(const Duration(hours: 2))),
      PlatformTrend(platformName: 'Twitter', rank: 4, title: 'Space mission success', userName: '@SpaceUpdates', userAvatarUrl: 'https://i.pravatar.cc/150?img=14', caption: '🚀 Mars rover discovers water evidence!', likes: 89000, comments: 5600, shares: 2800, timestamp: now.subtract(const Duration(hours: 3))),
      PlatformTrend(platformName: 'Twitter', rank: 5, title: 'Celebrity announcement', userName: '@EntertainmentNow', userAvatarUrl: 'https://i.pravatar.cc/150?img=15', caption: 'SURPRISE! New album dropping tonight 🎵', likes: 156000, comments: 23000, shares: 8900, timestamp: now.subtract(const Duration(hours: 4))),
      PlatformTrend(platformName: 'Twitter', rank: 6, title: 'Sports upset victory', userName: '@SportsCenter', userAvatarUrl: 'https://i.pravatar.cc/150?img=16', caption: 'UPSET OF THE CENTURY! Underdog wins championship 🏆', likes: 67000, comments: 8900, shares: 3400, timestamp: now.subtract(const Duration(hours: 5))),
      PlatformTrend(platformName: 'Twitter', rank: 7, title: 'Crypto market surge', userName: '@CryptoNews', userAvatarUrl: 'https://i.pravatar.cc/150?img=17', caption: '📈 Bitcoin hits new all-time high!', likes: 45000, comments: 6700, shares: 2300, timestamp: now.subtract(const Duration(hours: 6))),
      PlatformTrend(platformName: 'Twitter', rank: 8, title: 'Movie trailer drops', userName: '@MovieBuzz', userAvatarUrl: 'https://i.pravatar.cc/150?img=18', caption: '🎬 Most anticipated movie trailer is here!', likes: 78000, comments: 12000, shares: 4500, timestamp: now.subtract(const Duration(hours: 7))),
    ];
  }

  Future<List<PlatformTrend>> _getYoutubeTrends([String countryCode = 'US']) async {
    try {
      final youtubeService = YoutubeService();
      final videos = await youtubeService.getTrendingVideos(countryCode);
      
      return videos.asMap().entries.map((entry) {
        final index = entry.key;
        final video = entry.value;
        return PlatformTrend(
          platformName: 'YouTube',
          rank: index + 1,
          title: video['title'],
          userName: video['channelTitle'],
          userAvatarUrl: 'https://i.pravatar.cc/150?img=${16 + index}',
          mediaUrl: video['thumbnail'],
          caption: video['title'],
          likes: 10000 + (index * 5000),
          comments: 500 + (index * 200),
          shares: 100 + (index * 50),
          timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
          videoId: video['id'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching YouTube trends: $e');
      return [];
    }
  }

  Future<List<PlatformTrend>> _getTiktokTrends() async {
    try {
      final scraperService = WebScraperService();
      final trends = await scraperService.getTikTokTrends();
      
      return trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        return PlatformTrend(
          platformName: 'TikTok',
          rank: index + 1,
          title: trend['name'],
          userName: '@tiktok',
          userAvatarUrl: 'https://i.pravatar.cc/150?img=${18 + index}',
          mediaUrl: 'https://picsum.photos/400/300?random=${18 + index}',
          caption: trend['description'],
          likes: trend['views'] ?? 1000000,
          comments: (trend['views'] ?? 1000000) ~/ 100,
          shares: (trend['views'] ?? 1000000) ~/ 50,
          timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
          videoId: 'trending_${index + 1}',
        );
      }).toList();
    } catch (e) {
      // Always return fallback data for TikTok
    }
    return _getFallbackTiktokTrends();
  }

  List<PlatformTrend> _getFallbackTiktokTrends() {
    final now = DateTime.now();
    return [
      PlatformTrend(platformName: 'TikTok', rank: 1, title: 'Viral dance challenge breaks internet', userName: '@dancer_pro', userAvatarUrl: 'https://i.pravatar.cc/150?img=18', mediaUrl: 'https://picsum.photos/400/300?random=18', caption: 'This dance is EVERYWHERE! 🔥💃 Started as a joke but now EVERYONE is doing it - celebrities, athletes, even my grandma! The beat is so catchy and the moves are surprisingly easy to learn. Who\'s joining the challenge? 🙋‍♀️', likes: 89000, comments: 5600, shares: 12000, timestamp: now.subtract(const Duration(hours: 6)), videoId: '7234567890123456789'),
      PlatformTrend(platformName: 'TikTok', rank: 2, title: 'Mind-blowing life hack goes viral', userName: '@lifehacks', userAvatarUrl: 'https://i.pravatar.cc/150?img=19', mediaUrl: 'https://picsum.photos/400/300?random=19', caption: 'I can\'t believe I\'ve been doing this wrong my whole life! 🤯 This simple trick will save you HOURS every week. My productivity has literally doubled since I started doing this. You NEED to try it!', likes: 67000, comments: 3400, shares: 8900, timestamp: now.subtract(const Duration(hours: 8)), videoId: '7234567890123456790'),
    ];
  }

  List<PlatformTrend> _getLinkedinTrends() {
    final now = DateTime.now();
    return [
      PlatformTrend(platformName: 'LinkedIn', rank: 1, title: 'Career Growth Tips', userName: 'Career Coach', userAvatarUrl: 'https://i.pravatar.cc/150?img=20', caption: '5 strategies that helped me land my dream job 💼', likes: 1200, comments: 89, shares: 234, timestamp: now.subtract(const Duration(hours: 24))),
      PlatformTrend(platformName: 'LinkedIn', rank: 2, title: 'Industry Insights', userName: 'Tech Leader', userAvatarUrl: 'https://i.pravatar.cc/150?img=21', caption: 'The future of AI in business: key trends to watch 🤖', likes: 890, comments: 67, shares: 156, timestamp: now.subtract(const Duration(hours: 36))),
    ];
  }

  Future<List<PlatformTrend>> _getRedditTrends() async {
    try {
      final scraperService = WebScraperService();
      final trends = await scraperService.getRedditTrends();
      
      return trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        return PlatformTrend(
          platformName: 'Reddit',
          rank: index + 1,
          title: trend['title'],
          userName: 'u/${trend['author']}',
          userAvatarUrl: 'https://i.pravatar.cc/150?img=${22 + index}',
          mediaUrl: trend['thumbnail'] != null && trend['thumbnail'].startsWith('http') ? trend['thumbnail'] : null,
          caption: trend['content'] ?? 'r/${trend['subreddit']} • ${trend['score']} upvotes',
          likes: trend['score'] ?? 1000,
          comments: trend['comments'] ?? 100,
          shares: (trend['score'] ?? 1000) ~/ 10,
          timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
        );
      }).toList();
    } catch (e) {
      return _getFallbackRedditTrends();
    }
  }

  List<PlatformTrend> _getFallbackRedditTrends() {
    final now = DateTime.now();
    return [
      PlatformTrend(platformName: 'Reddit', rank: 1, title: 'AMA with Celebrity', userName: 'u/celebrity_official', userAvatarUrl: 'https://i.pravatar.cc/150?img=22', caption: 'Ask me anything! Here for the next 2 hours 🎬', likes: 23000, comments: 4500, shares: 890, timestamp: now.subtract(const Duration(hours: 4))),
      PlatformTrend(platformName: 'Reddit', rank: 2, title: 'Wholesome Story', userName: 'u/goodvibes', userAvatarUrl: 'https://i.pravatar.cc/150?img=23', caption: 'Stranger helped me when I was lost. Faith in humanity restored! ❤️', likes: 15600, comments: 1200, shares: 567, timestamp: now.subtract(const Duration(hours: 8))),
    ];
  }

  List<PlatformTrend> _getSnapchatTrends() {
    final now = DateTime.now();
    return [
      PlatformTrend(platformName: 'Snapchat', rank: 1, title: 'Mind-blowing AR filter goes viral', userName: '@snapfilters', userAvatarUrl: 'https://i.pravatar.cc/150?img=24', mediaUrl: 'https://picsum.photos/400/300?random=24', caption: 'OMG this new AR filter is INSANE! 🤯 It literally transforms your face into a cartoon character and the tracking is so smooth. Everyone needs to try this RIGHT NOW! 👻✨', likes: 34000, comments: 2100, shares: 5600, timestamp: now.subtract(const Duration(hours: 2))),
      PlatformTrend(platformName: 'Snapchat', rank: 2, title: 'Exclusive movie set footage', userName: '@moviestar', userAvatarUrl: 'https://i.pravatar.cc/150?img=25', mediaUrl: 'https://picsum.photos/400/300?random=25', caption: 'Taking you behind the scenes of my upcoming blockbuster! 🎦✨ The stunts, the drama, the amazing cast - this is going to be EPIC! Can\'t reveal too much but... get ready!', likes: 45000, comments: 3400, shares: 7800, timestamp: now.subtract(const Duration(hours: 6))),
    ];
  }
}