class CountryTrend {
  final String countryName;
  final String countryFlag;
  final int rank;
  final String title;
  final String description;
  final String category;
  final int popularity;
  final DateTime timestamp;
  final String? imageUrl;

  CountryTrend({
    required this.countryName,
    required this.countryFlag,
    required this.rank,
    required this.title,
    required this.description,
    required this.category,
    required this.popularity,
    required this.timestamp,
    this.imageUrl,
  });
}