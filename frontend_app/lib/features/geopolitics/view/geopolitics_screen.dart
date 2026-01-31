import 'package:flutter/material.dart';
import '../../../core/widgets/news_feed.dart';

class GeopoliticsScreen extends StatelessWidget {
  const GeopoliticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Geopolitics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: 1, 
        itemBuilder: (context, index) {
          return const NewsFeed(
            categoryName: 'geopolitics', // Map to correct provider key
          );
        },
      ),
    );
  }
}
