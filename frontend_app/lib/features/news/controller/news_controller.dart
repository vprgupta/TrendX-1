import 'package:flutter/material.dart';
import '../model/news_article.dart';
import '../service/news_service.dart';

class NewsController extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrendingNews() async {
    _setLoading(true);
    _clearError();
    
    try {
      _articles = await _newsService.getTrendingNews();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load trending news');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTopHeadlines(String country) async {
    _setLoading(true);
    _clearError();
    
    try {
      _articles = await _newsService.getTopHeadlines(country: country);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load headlines');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchNews(String query) async {
    _setLoading(true);
    _clearError();
    
    try {
      _articles = await _newsService.searchNews(query);
      notifyListeners();
    } catch (e) {
      _setError('Failed to search news');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}