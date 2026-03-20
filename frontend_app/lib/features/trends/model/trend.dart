class Trend {
  final String id;
  final String title;
  final String description;
  final int rank;
  final int popularity;
  final Duration duration;
  final String region;

  Trend({
    required this.id,
    required this.title,
    required this.description,
    required this.rank,
    required this.popularity,
    required this.duration,
    required this.region,
  });

  factory Trend.fromJson(Map<String, dynamic> json) {
    return Trend(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown Trend',
      description: json['description'] ?? json['content'] ?? '',
      rank: json['rank'] ?? 0,
      popularity: (json['trendingScore'] ?? json['globalScore'] ?? 0).toInt(),
      duration: const Duration(hours: 1),
      region: json['country'] ?? json['region'] ?? 'Global',
    );
  }
}