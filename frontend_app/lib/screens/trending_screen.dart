import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import 'youtube_player_screen.dart';

class TrendingScreen extends StatefulWidget {
  final String apiKey;

  const TrendingScreen({super.key, required this.apiKey});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final YoutubeService _youtubeService = YoutubeService();
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrendingVideos();
  }

  Future<void> _loadTrendingVideos() async {
    try {
      final videos = await _youtubeService.getTrendingVideos();
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Trending'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    final video = _videos[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.network(
                          video['thumbnail'],
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          video['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(video['channelTitle']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => YoutubePlayerScreen(
                                videoId: video['id'],
                                title: video['title'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}