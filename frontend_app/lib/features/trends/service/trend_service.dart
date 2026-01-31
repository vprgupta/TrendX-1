import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class TrendService {
  Future<List<dynamic>> fetchTrends({String? platform, String? country, int limit = 20}) async {
    try {
      var url = '${ApiConfig.trends}?limit=$limit';
      if (platform != null) url += '&platform=$platform';
      if (country != null) url += '&country=$country';
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['trends'] ?? [];
      }
    } catch (e) {
      print('Error fetching trends: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getTrendById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.trends}/$id'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching trend: $e');
    }
    return null;
  }

  Future<List<dynamic>> searchTrends(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.trends}/search?q=$query'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.timeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['trends'] ?? [];
      }
    } catch (e) {
      print('Error searching trends: $e');
    }
    return [];
  }
}