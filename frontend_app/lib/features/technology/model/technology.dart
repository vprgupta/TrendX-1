class TechTrend {
  final String category;
  final int rank;
  final String title;
  final String description;
  final String company;
  final int impact;
  final DateTime timestamp;
  final String? imageUrl;

  TechTrend({
    required this.category,
    required this.rank,
    required this.title,
    required this.description,
    required this.company,
    required this.impact,
    required this.timestamp,
    this.imageUrl,
  });
}