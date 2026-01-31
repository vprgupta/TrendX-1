import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import 'youtube_player_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ReelsScreen extends StatefulWidget {
  final bool isActive;
  
  const ReelsScreen({
    super.key,
    this.isActive = true,
  });

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  final YoutubeService _youtubeService = YoutubeService();
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _shorts = [];
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;
  bool _isScreenActive = false;

  @override
  void initState() {
    super.initState();
    _isScreenActive = widget.isActive;
    WidgetsBinding.instance.addObserver(this);
    _loadTrendingShorts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ReelsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect tab changes
    if (widget.isActive != oldWidget.isActive) {
      setState(() {
        _isScreenActive = widget.isActive;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause videos when app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        _isScreenActive = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        _isScreenActive = widget.isActive; // Use widget.isActive instead of true
      });
    }
  }

  Future<void> _loadTrendingShorts() async {
    try {
      final shorts = await _youtubeService.getTrendingShorts();
      setState(() {
        _shorts = shorts;
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
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  physics: const PageScrollPhysics(), // Responsive page scrolling
                  pageSnapping: true,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: _shorts.length,
                  itemBuilder: (context, index) {
                    // Only initialize player for current and adjacent videos
                    final shouldInitialize = (index - _currentIndex).abs() <= 1;
                    
                    return ReelItem(
                      short: _shorts[index],
                      isActive: index == _currentIndex && _isScreenActive,
                      shouldInitialize: shouldInitialize,
                      onVideoEnd: () {
                        // Auto-scroll to next video when current ends
                        if (index < _shorts.length - 1) {
                          _pageController.animateToPage(
                            index + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class ReelItem extends StatefulWidget {
  final Map<String, dynamic> short;
  final bool isActive;
  final bool shouldInitialize;
  final VoidCallback? onVideoEnd;

  const ReelItem({
    super.key,
    required this.short,
    required this.isActive,
    this.shouldInitialize = true,
    this.onVideoEnd,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isInitialized = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    if (widget.shouldInitialize) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    if (_isInitialized) return;
    
    _controller = YoutubePlayerController(
      initialVideoId: widget.short['id'],
      flags: YoutubePlayerFlags(
        autoPlay: widget.isActive,
        mute: false,
        loop: false, // Don't loop to enable auto-scroll
        hideControls: false,
        controlsVisibleAtStart: false,
        forceHD: false, // Use lower quality for faster loading
        enableCaption: false,
      ),
    )..addListener(_playerListener);
    
    _isInitialized = true;
  }

  void _playerListener() {
    if (_controller == null || !mounted) return;
    
    // Check if player is ready
    if (_controller!.value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }
    
    // Check if video ended
    if (_controller!.value.playerState == PlayerState.ended) {
      widget.onVideoEnd?.call();
    }
  }

  @override
  void didUpdateWidget(ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Initialize player if it should be initialized now
    if (widget.shouldInitialize && !_isInitialized) {
      _initializePlayer();
    }
    
    // Handle play/pause based on scroll position
    if (_controller != null && widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        // Force play when becoming active
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _controller != null && _isPlayerReady) {
            _controller!.play();
          }
        });
      } else {
        _controller!.pause();
      }
    }
    
    // Dispose controller if too far from view
    if (!widget.shouldInitialize && _isInitialized) {
      _disposePlayer();
    }
  }

  void _disposePlayer() {
    if (_controller != null) {
      _controller!.removeListener(_playerListener);
      _controller!.dispose();
      _controller = null;
      _isInitialized = false;
      _isPlayerReady = false;
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Show thumbnail or YouTube Player
        if (_controller != null && _isInitialized)
          YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: false,
            progressIndicatorColor: Colors.white,
            aspectRatio: 9 / 16,
            bottomActions: const [],
            topActions: const [],
          )
        else
          // Show thumbnail while not initialized
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.short['thumbnail']),
                fit: BoxFit.cover,
              ),
            ),
          ),
        
        // Loading indicator
        if (!_isPlayerReady)
          Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        
        // Progress bar at top (like Instagram Reels)
        if (_controller != null && _isPlayerReady)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: ValueListenableBuilder(
                valueListenable: _controller!,
                builder: (context, value, child) {
                  final duration = value.metaData.duration.inMilliseconds;
                  final position = value.position.inMilliseconds;
                  final progress = duration > 0 ? position / duration : 0.0;
                  
                  return LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3,
                  );
                },
              ),
            ),
          ),
        
        // Gradient overlay at bottom for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        
        // Content overlay (user info and actions)
        Positioned(
          left: 16,
          right: 80,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.short['channelTitle'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.short['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // Side actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              if (_controller != null)
                _ActionButton(
                  icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                  onTap: () {
                    if (_controller != null && mounted) {
                      setState(() {
                        _isMuted = !_isMuted;
                        _controller!.setVolume(_isMuted ? 0 : 100);
                      });
                    }
                  },
                ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.favorite_border,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.comment_outlined,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.share_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
        
        // Top safe area with title
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Placeholder for alignment
                  const Text(
                    'Shorts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
