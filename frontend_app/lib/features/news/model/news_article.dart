class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String source;
  final DateTime publishedAt;
  final String? author;
  final String? content;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.source,
    required this.publishedAt,
    this.author,
    this.content,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      source: json['source']['name'] ?? '',
      publishedAt: DateTime.parse(json['publishedAt']),
      author: json['author'],
      content: json['content'],
    );
  }
}