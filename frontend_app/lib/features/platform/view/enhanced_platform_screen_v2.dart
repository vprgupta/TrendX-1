import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/shimmer_card.dart';
import '../../../core/services/preferences_service.dart';
import '../controller/platform_controller.dart';
import '../model/platform.dart';
import 'widgets/enhanced_trend_card_v2.dart';
import 'widgets/platform_header_v2.dart';
import 'widgets/quick_actions_bar.dart';
import 'widgets/search_filter_bar.dart';
import '../../../screens/trending_shorts_screen.dart';

class EnhancedPlatformScreenV2 extends StatefulWidget {
  const EnhancedPlatformScreenV2({super.key});

  @override
  State<EnhancedPlatformScreenV2> createState() => _EnhancedPlatformScreenV2State();
}

class _EnhancedPlatformScreenV2State extends State<EnhancedPlatformScreenV2>
    with TickerProviderStateMixin {
  final PlatformController _controller = PlatformController();
  final PreferencesService _prefsService = PreferencesService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _headerSlideAnimation;
  
  bool _showFab = false;
  bool _isSearching = false;
  bool _isGridView = false;
  String _searchQuery = '';
  String _sortBy = 'trending';
  String _filterBy = 'all';

  @override
  void initState() {
    super.initState();
    _prefsService.addListener(_onPreferencesChanged);
    _prefsService.loadCountryFilter();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _scrollController.addListener(_onScroll);
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _prefsService.removeListener(_onPreferencesChanged);
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onPreferencesChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showFab) {
      setState(() => _showFab = true);
      _fabAnimationController.forward();
    } else if (_scrollController.offset <= 100 && _showFab) {
      setState(() => _showFab = false);
      _fabAnimationController.reverse();
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            _buildSearchFilterBar(),
            _buildQuickActions(),
            _buildPlatformsList(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: SlideTransition(
          position: _headerSlideAnimation,
          child: PlatformHeaderV2(),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _isGridView = !_isGridView);
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _isSearching = !_isSearching);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchFilterBar() {
    return SliverToBoxAdapter(
      child: SearchFilterBar(
        isSearching: _isSearching,
        searchController: _searchController,
        onSearchChanged: (value) => setState(() => _searchQuery = value),
        sortBy: _sortBy,
        filterBy: _filterBy,
        onSortChanged: (value) => setState(() => _sortBy = value),
        onFilterChanged: (value) => setState(() => _filterBy = value),
        prefsService: _prefsService,
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: QuickActionsBar(
        onShortsPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrendingShortsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildPlatformsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final platform = _prefsService.selectedPlatforms.elementAt(index);
          final countryCode = _prefsService.selectedCountryFilter == 'Worldwide' 
              ? 'US' 
              : _prefsService.selectedCountryFilter;
          
          return FutureBuilder<List<PlatformTrend>>(
            future: _controller.getPlatformTrends(platform, countryCode),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (snapshot.hasError) {
                return _buildErrorState(platform);
              }
              
              final trends = _filterAndSortTrends(snapshot.data ?? []);
              
              return _isGridView 
                  ? _buildGridView(platform, trends, index)
                  : _buildListView(platform, trends, index);
            },
          );
        },
        childCount: _prefsService.selectedPlatforms.length,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) => const ShimmerCard()),
    );
  }

  Widget _buildErrorState(String platform) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load $platform trends',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Pull to refresh or try again later',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(String platform, List<PlatformTrend> trends, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlatformHeader(platform),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: trends.length,
            itemBuilder: (context, trendIndex) {
              return EnhancedTrendCardV2(
                trend: trends[trendIndex],
                isGridView: true,
                animationDelay: (index * 100) + (trendIndex * 50),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListView(String platform, List<PlatformTrend> trends, int index) {
    return Column(
      children: [
        _buildPlatformHeader(platform),
        ...trends.asMap().entries.map((entry) {
          return EnhancedTrendCardV2(
            trend: entry.value,
            isGridView: false,
            animationDelay: (index * 100) + (entry.key * 50),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlatformHeader(String platform) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getPlatformColor(platform).withOpacity(0.8),
            _getPlatformColor(platform).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getPlatformColor(platform).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              _getPlatformIcon(platform),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                Text(
                  'Trending now',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LIVE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        icon: const Icon(Icons.keyboard_arrow_up),
        label: const Text('Top'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  List<PlatformTrend> _filterAndSortTrends(List<PlatformTrend> trends) {
    var filteredTrends = trends;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredTrends = filteredTrends.where((trend) =>
          trend.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          trend.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          trend.caption.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply content filter
    if (_filterBy != 'all') {
      // Add filtering logic based on content type
    }

    // Apply sorting
    switch (_sortBy) {
      case 'trending':
        filteredTrends.sort((a, b) => a.rank.compareTo(b.rank));
        break;
      case 'likes':
        filteredTrends.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'recent':
        filteredTrends.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
    }

    return filteredTrends;
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'reddit':
        return const Color(0xFFFF4500);
      case 'snapchat':
        return const Color(0xFFFFFC00);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email;
      case 'youtube':
        return Icons.play_circle;
      case 'tiktok':
        return Icons.music_note;
      case 'linkedin':
        return Icons.business;
      case 'reddit':
        return Icons.forum;
      case 'snapchat':
        return Icons.camera;
      default:
        return Icons.public;
    }
  }
}