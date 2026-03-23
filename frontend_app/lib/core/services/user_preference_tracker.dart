import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks how many times the user has tapped each category.
/// Used by the trending provider to boost scores for preferred categories.
class UserPreferenceTracker {
  static const String _key = 'category_click_counts';

  static Future<Map<String, int>> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    try {
      return Map<String, int>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  static Future<void> recordCategoryClick(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = await _loadCounts();
    counts[category.toLowerCase()] = (counts[category.toLowerCase()] ?? 0) + 1;
    await prefs.setString(_key, jsonEncode(counts));
  }

  /// Returns a boost multiplier (1.0–1.3) for a given category
  /// based on the user's click history.
  static Future<Map<String, double>> getPersonalizationBoosts() async {
    final counts = await _loadCounts();
    if (counts.isEmpty) return {};

    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return {};

    return counts.map((category, clicks) {
      // Max 30% boost for the most-clicked category
      final boost = (clicks / total) * 0.3;
      return MapEntry(category, 1.0 + boost);
    });
  }
}
