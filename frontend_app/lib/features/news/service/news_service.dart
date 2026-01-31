import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/news_article.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'YOUR_NEWS_API_KEY'; // Replace with your API key
  
  Future<List<NewsArticle>> getTopHeadlines({String country = 'us'}) async {
    final url = '$_baseUrl/top-headlines?country=$country&apiKey=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        return articles.map((article) => NewsArticle.fromJson(article)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<NewsArticle>> getTrendingNews({String category = 'general'}) async {
    final url = '$_baseUrl/top-headlines?category=$category&apiKey=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        return articles.map((article) => NewsArticle.fromJson(article)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<NewsArticle>> searchNews(String query) async {
    final url = '$_baseUrl/everything?q=$query&sortBy=popularity&apiKey=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        return articles.map((article) => NewsArticle.fromJson(article)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}