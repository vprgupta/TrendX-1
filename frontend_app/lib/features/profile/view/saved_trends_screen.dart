import 'package:flutter/material.dart';
import '../../../core/services/saved_trends_service.dart';
import '../../world/controller/world_controller.dart';
import '../../world/model/world_trend.dart';
import '../../world/view/widgets/world_trend_card.dart';

class SavedTrendsScreen extends StatefulWidget {
  const SavedTrendsScreen({super.key});

  @override
  State<SavedTrendsScreen> createState() => _SavedTrendsScreenState();
}

class _SavedTrendsScreenState extends State<SavedTrendsScreen> {
  final SavedTrendsService _savedService = SavedTrendsService();
  final WorldController _worldController = WorldController();
  List<WorldTrend> _allTrends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    await _savedService.loadSavedTrends();
    _allTrends = await _worldController.getTop50WorldTrends();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Saved Trends',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: _savedService,
              builder: (context, _) {
                final savedTrends = _allTrends
                    .where((trend) => _savedService.isTrendSaved(trend.id))
                    .toList();

                if (savedTrends.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved trends yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bookmark trends to save them here',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: savedTrends.length,
                  itemBuilder: (context, index) {
                    return WorldTrendCard(trend: savedTrends[index]);
                  },
                );
              },
            ),
    );
  }
}