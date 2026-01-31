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
}