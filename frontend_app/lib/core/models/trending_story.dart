class TrendingStory {
  final String id;
  final String title;
  final String link;
  final List<String> sources;
  final String category;
  final String sentiment; // 'positive' | 'controversial' | 'alarming' | 'neutral'
  final double velocityScore;
  final int points;
  final String pubDate;
  final String? imageUrl;
  final String? author;

  const TrendingStory({
    required this.id,
    required this.title,
    required this.link,
    required this.sources,
    required this.category,
    required this.sentiment,
    required this.velocityScore,
    required this.points,
    required this.pubDate,
    this.imageUrl,
    this.author,
  });

  factory TrendingStory.fromJson(Map<String, dynamic> json) {
    return TrendingStory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'No title',
      link: json['link'] as String? ?? '#',
      sources: List<String>.from(json['sources'] as List? ?? []),
      category: json['category'] as String? ?? 'General',
      sentiment: json['sentiment'] as String? ?? 'neutral',
      velocityScore: (json['velocityScore'] as num?)?.toDouble() ?? 0.0,
      points: json['points'] as int? ?? 0,
      pubDate: json['pubDate'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      author: json['author'] as String?,
    );
  }
}
