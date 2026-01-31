class WorldTrend {
  final int rank;
  final String title;
  final String description;
  final String category;
  final String source;
  final String region;
  final int engagement;
  final DateTime timestamp;
  final String? imageUrl;
  final String? countryFlag;

  WorldTrend({
    required this.rank,
    required this.title,
    required this.description,
    required this.category,
    required this.source,
    required this.region,
    required this.engagement,
    required this.timestamp,
    this.imageUrl,
    this.countryFlag,
  });

  String get id => '${title}_${timestamp.millisecondsSinceEpoch}';
}