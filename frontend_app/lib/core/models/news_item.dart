class NewsItem {
  final String title;
  final String link;
  final String pubDate;
  final String content;
  final String contentSnippet;
  final String source;
  final String? imageUrl;
  final String? author;
  final String? authorAvatarUrl;
  final int likes;
  final int comments;
  final int shares;
  final int? rank;

  NewsItem({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.content,
    required this.contentSnippet,
    required this.source,
    this.imageUrl,
    this.author,
    this.authorAvatarUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.rank,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      pubDate: json['pubDate'] ?? '',
      content: json['content'] ?? '',
      contentSnippet: json['contentSnippet'] ?? '',
      source: json['source'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      author: json['author'],
      authorAvatarUrl: json['authorAvatarUrl'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      rank: json['rank'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
      'pubDate': pubDate,
      'content': content,
      'contentSnippet': contentSnippet,
      'source': source,
      'imageUrl': imageUrl,
      'author': author,
      'authorAvatarUrl': authorAvatarUrl,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'rank': rank,
    };
  }
}
