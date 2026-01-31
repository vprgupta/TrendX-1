import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TikTokPlayerScreen extends StatefulWidget {
  final String title;
  final String username;
  final String description;
  final String? videoId;

  const TikTokPlayerScreen({
    super.key,
    required this.title,
    required this.username,
    required this.description,
    this.videoId,
  });

  @override
  State<TikTokPlayerScreen> createState() => _TikTokPlayerScreenState();
}

class _TikTokPlayerScreenState extends State<TikTokPlayerScreen> {
  late final WebViewController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.videoId != null 
          ? 'https://www.tiktok.com/@${widget.username}/video/${widget.videoId}'
          : 'https://www.tiktok.com/foryou'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // WebView for TikTok content
          WebViewWidget(controller: controller),
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }


}