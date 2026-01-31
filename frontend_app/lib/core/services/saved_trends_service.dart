import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedTrendsService extends ChangeNotifier {
  static final SavedTrendsService _instance = SavedTrendsService._internal();
  factory SavedTrendsService() => _instance;
  SavedTrendsService._internal();

  final Set<String> _savedTrendIds = {};
  static const String _savedTrendsKey = 'saved_trends';
  static const String _savedTrendsDataKey = 'saved_trends_data';

  Set<String> get savedTrendIds => Set.unmodifiable(_savedTrendIds);
  List<Map<String, dynamic>> _savedTrendsData = [];
  List<Map<String, dynamic>> get savedTrendsData => List.unmodifiable(_savedTrendsData);

  Future<void> loadSavedTrends() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load IDs (legacy support + fast check)
    final savedList = prefs.getStringList(_savedTrendsKey) ?? [];
    _savedTrendIds.clear();
    _savedTrendIds.addAll(savedList);
    
    // Load Full Data
    final savedDataStrings = prefs.getStringList(_savedTrendsDataKey) ?? [];
    _savedTrendsData = savedDataStrings
        .map((str) => json.decode(str) as Map<String, dynamic>)
        .toList();
        
    notifyListeners();
  }

  Future<void> saveTrend(Map<String, dynamic> trendData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Generate a unique ID if not present
    final String id = trendData['id'] ?? '${trendData['platform']}_${trendData['title']}';
    
    if (_savedTrendIds.contains(id)) {
      // Already saved, maybe update? For now, do nothing or update
      // Remove existing to replace
      _savedTrendsData.removeWhere((t) => t['id'] == id);
      _savedTrendIds.remove(id);
    }
    
    _savedTrendIds.add(id);
    _savedTrendsData.add(trendData);
    
    await _persistData(prefs);
    notifyListeners();
  }

  Future<void> toggleSavedTrend(String trendId) async {
    // This is legacy method for just toggling ID. 
    // If we use this, we don't have the trend data, so we can't save the full object.
    // For now, we'll just toggle the ID.
    if (_savedTrendIds.contains(trendId)) {
      _savedTrendIds.remove(trendId);
      _savedTrendsData.removeWhere((t) => t['id'] == trendId);
    } else {
      _savedTrendIds.add(trendId);
      // We can't add to _savedTrendsData because we don't have the data!
    }
    
    final prefs = await SharedPreferences.getInstance();
    await _persistData(prefs);
    notifyListeners();
  }
  
  Future<void> _persistData(SharedPreferences prefs) async {
    await prefs.setStringList(_savedTrendsKey, _savedTrendIds.toList());
    
    final dataStrings = _savedTrendsData.map((map) => json.encode(map)).toList();
    await prefs.setStringList(_savedTrendsDataKey, dataStrings);
  }

  bool isTrendSaved(String trendId) => _savedTrendIds.contains(trendId);
}