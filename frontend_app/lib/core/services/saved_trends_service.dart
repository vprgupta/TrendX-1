import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedTrendsService extends ChangeNotifier {
  static final SavedTrendsService _instance = SavedTrendsService._internal();
  factory SavedTrendsService() => _instance;
  SavedTrendsService._internal();

  final Set<String> _savedTrendIds = {};
  static const String _savedTrendsKey = 'saved_trends';

  Set<String> get savedTrendIds => Set.unmodifiable(_savedTrendIds);

  Future<void> loadSavedTrends() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_savedTrendsKey) ?? [];
    _savedTrendIds.clear();
    _savedTrendIds.addAll(savedList);
    notifyListeners();
  }

  Future<void> toggleSavedTrend(String trendId) async {
    if (_savedTrendIds.contains(trendId)) {
      _savedTrendIds.remove(trendId);
    } else {
      _savedTrendIds.add(trendId);
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedTrendsKey, _savedTrendIds.toList());
    notifyListeners();
  }

  bool isTrendSaved(String trendId) => _savedTrendIds.contains(trendId);
}