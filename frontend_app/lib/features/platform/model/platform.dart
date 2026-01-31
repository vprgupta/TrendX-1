class PlatformTrend {
  final String platformName;
  final int rank;
  final String title;
  final String userName;
  final String userAvatarUrl;
  final String? mediaUrl;
  final String caption;
  final int likes;
  final int comments;
  final int shares;
  final DateTime timestamp;
  final String? videoId;
  final String? videoUrl;
  final double? trendingScore; // Backend-calculated trending score (0-100)

  PlatformTrend({
    required this.platformName,
    required this.rank,
    required this.title,
    required this.userName,
    required this.userAvatarUrl,
    this.mediaUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.timestamp,
    this.videoId,
    this.videoUrl,
    this.trendingScore,
  });
}