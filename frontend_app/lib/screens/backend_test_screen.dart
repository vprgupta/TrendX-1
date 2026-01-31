import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({Key? key}) : super(key: key);

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  List<dynamic> trends = [];
  bool isLoading = true;
  String error = '';
  String selectedPlatform = 'youtube';

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      // Fetch trends from backend (NO AUTH REQUIRED NOW!)
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/trends/trending/platform/$selectedPlatform'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          trends = data['trends'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Data Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrends,
          ),
        ],
      ),
      body: Column(
        children: [
          // Platform selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'youtube', label: Text('YouTube')),
                ButtonSegment(value: 'twitter', label: Text('Twitter')),
                ButtonSegment(value: 'news', label: Text('News')),
              ],
              selected: {selectedPlatform},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  selectedPlatform = newSelection.first;
                });
                _loadTrends();
              },
            ),
          ),
          // Status info
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  trends.isEmpty ? Icons.error_outline : Icons.check_circle,
                  color: trends.isEmpty ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  trends.isEmpty 
                      ? 'No data yet' 
                      : '${trends.length} items loaded from backend',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(),
          // Trend list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(error),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTrends,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : trends.isEmpty
                        ? const Center(child: Text('No trends available'))
                        : ListView.builder(
                            itemCount: trends.length,
                            itemBuilder: (context, index) {
                              final trend = trends[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 80,
                                    child: trend['imageUrl'] != null
                                        ? Image.network(
                                            trend['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) {
                                              return const Icon(Icons.image_not_supported);
                                            },
                                          )
                                        : const Icon(Icons.article, size: 40),
                                  ),
                                  title: Text(
                                    trend['title'] ?? 'No title',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.remove_red_eye, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_formatNumber(trend['metrics']?['views'] ?? 0)} views',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.trending_up, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Score: ${(trend['trendingScore'] ?? 0).toStringAsFixed(1)}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Platform: ${trend['platform'] ?? 'unknown'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: _buildTrendBadge(
                                    trend['trendingScore']?.toDouble() ?? 0,
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBadge(double score) {
    String emoji = '📊';
    String label = 'TRENDING';
    Color color = Colors.blue;

    if (score >= 80) {
      emoji = '🔥';
      label = 'VIRAL';
      color = Colors.red;
    } else if (score >= 60) {
      emoji = '⭐';
      label = 'HOT';
      color = Colors.orange;
    } else if (score >= 40) {
      emoji = '📈';
      label = 'RISING';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        '$emoji\n$label',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatNumber(dynamic num) {
    if (num == null) return '0';
    int number = num is int ? num : int.tryParse(num.toString()) ?? 0;
    
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
