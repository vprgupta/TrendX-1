import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/news_card.dart';
import '../../../core/widgets/pull_to_refresh.dart';
import '../../news/providers/news_provider.dart';

// ─── Domain Metadata ─────────────────────────────────────────────────────────

class _DomainMeta {
  final String label;
  final IconData icon;
  final Color color;
  const _DomainMeta(this.label, this.icon, this.color);
}

const _domainOrder = [
  _DomainMeta('Science',          LucideIcons.microscope,  Color(0xFF00B4D8)),
  _DomainMeta('AI & Technology',  LucideIcons.cpu,         Color(0xFF7C3AED)),
  _DomainMeta('Health & Medicine',LucideIcons.heartPulse,  Color(0xFFE91E8C)),
  _DomainMeta('Space & Astronomy',LucideIcons.satellite,   Color(0xFF1A237E)),
  _DomainMeta('Energy & Climate', LucideIcons.leaf,        Color(0xFF2E7D32)),
  _DomainMeta('Biology & Life',   LucideIcons.dna,         Color(0xFFFF6F00)),
];

_DomainMeta _metaFor(String label) {
  try {
    return _domainOrder.firstWhere((d) => d.label == label);
  } catch (_) {
    return _DomainMeta(label, LucideIcons.sparkles, const Color(0xFF607D8B));
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class BreakthroughScreen extends ConsumerStatefulWidget {
  const BreakthroughScreen({super.key});
  @override
  ConsumerState<BreakthroughScreen> createState() => _BreakthroughScreenState();
}

class _BreakthroughScreenState extends ConsumerState<BreakthroughScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  /// null = All domains
  String? _selectedDomain;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF607D8B);
    }
  }

  String _timeAgo(String pubDate) {
    try {
      final dt = DateTime.parse(pubDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final async = ref.watch(breakthroughProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, isDark),
            _buildDomainChips(theme, isDark),
            Expanded(
              child: async.when(
                loading: () => _buildLoading(theme),
                error: (e, _) => _buildError(theme),
                data: (grouped) => _buildContent(grouped, theme, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.sparkles,
                    color: Colors.white, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discoveries',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Latest breakthroughs from around the world',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {}); // reset filter on refresh
              ref.invalidate(breakthroughProvider);
            },
            icon: Icon(Icons.refresh_rounded,
                color: theme.colorScheme.primary),
            tooltip: 'Refresh',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.08, end: 0);
  }

  // ── Domain filter chips ────────────────────────────────────────────────────

  Widget _buildDomainChips(ThemeData theme, bool isDark) {
    final chips = [null, ..._domainOrder.map((d) => d.label)];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label = chips[i];
          final isAll = label == null;
          final selected = isAll
              ? _selectedDomain == null
              : _selectedDomain == label;
          final meta = isAll
              ? null
              : _metaFor(label!);
          final color = meta?.color ?? theme.colorScheme.primary;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: FilterChip(
              selected: selected,
              showCheckmark: false,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (meta != null) ...[
                    Icon(meta.icon, size: 13, color: selected ? Colors.white : color),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    isAll ? '✦ All' : label!,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : (isAll ? theme.colorScheme.onSurface : color),
                    ),
                  ),
                ],
              ),
              backgroundColor: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerLow,
              selectedColor: isAll ? const Color(0xFF7C3AED) : color,
              side: BorderSide(
                color: selected ? Colors.transparent : color.withOpacity(0.3),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              onSelected: (_) => setState(() =>
                  _selectedDomain = isAll ? null : label),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  // ── Loading / Error ────────────────────────────────────────────────────────

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Scanning for discoveries...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fetching from ScienceDaily, NASA, Nature & more',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff,
              size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Could not load discoveries',
              style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => ref.invalidate(breakthroughProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent(
      Map<String, List<BreakthroughItem>> grouped,
      ThemeData theme,
      bool isDark) {
    if (grouped.isEmpty) return _buildEmpty(theme);

    // Filter by selected domain
    final Map<String, List<BreakthroughItem>> filtered = _selectedDomain == null
        ? grouped
        : {if (grouped.containsKey(_selectedDomain)) _selectedDomain!: grouped[_selectedDomain!]!};

    if (filtered.isEmpty) return _buildEmpty(theme);

    // Sort domains by our predefined order
    final orderedDomains = [
      ..._domainOrder.map((d) => d.label).where(filtered.containsKey),
      ...filtered.keys.where((k) => !_domainOrder.any((d) => d.label == k)),
    ];

    // Find the freshest item across all filtered domains for the hero card
    BreakthroughItem? hero;
    for (final items in filtered.values) {
      if (items.isNotEmpty) {
        final candidate = items.first; // already sorted newest-first
        if (hero == null) {
          hero = candidate;
        } else {
          final cx = DateTime.tryParse(candidate.pubDate);
          final hx = DateTime.tryParse(hero.pubDate);
          if (cx != null && hx != null && cx.isAfter(hx)) hero = candidate;
        }
      }
    }

    return TrendXRefreshIndicator(
      onRefresh: () async => ref.invalidate(breakthroughProvider),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: orderedDomains.length + (hero != null && _selectedDomain == null ? 1 : 0),
        itemBuilder: (ctx, i) {
          // Index 0 when showing all → hero card
          if (_selectedDomain == null && hero != null) {
            if (i == 0) {
              return _buildHeroCard(hero!, theme, isDark)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.04, end: 0);
            }
            i -= 1; // shift domain list index
          }
          final domain = orderedDomains[i];
          final items = filtered[domain]!;
          return _buildDomainSection(domain, items, theme, isDark, i)
              .animate()
              .fadeIn(delay: Duration(milliseconds: (i + 1) * 70), duration: 350.ms)
              .slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }

  // ── Hero card ──────────────────────────────────────────────────────────────

  Widget _buildHeroCard(BreakthroughItem item, ThemeData theme, bool isDark) {
    final meta = _metaFor(item.domain);
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(item.link);
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              meta.color.withOpacity(isDark ? 0.8 : 0.9),
              meta.color.withOpacity(isDark ? 0.5 : 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: meta.color.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _gradientPlaceholder(meta.color),
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: _gradientPlaceholder(meta.color),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain badge + time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(meta.icon, size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              item.domain,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.zap, size: 10, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Latest',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeAgo(item.pubDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.snippet.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.snippet,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Source + read more
                  Row(
                    children: [
                      Icon(LucideIcons.newspaper, size: 13, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          item.source,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Read more',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.arrowRight, size: 13, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradientPlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.6), color.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(LucideIcons.sparkles,
            size: 40, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }

  // ── Domain section ─────────────────────────────────────────────────────────

  Widget _buildDomainSection(String domain, List<BreakthroughItem> items,
      ThemeData theme, bool isDark, int idx) {
    final meta = _metaFor(domain);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      meta.color.withOpacity(0.18),
                      meta.color.withOpacity(0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: meta.color.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(meta.icon, color: meta.color, size: 15),
                    const SizedBox(width: 7),
                    Text(
                      domain,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: meta.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: meta.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${items.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: meta.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Articles
        ...items.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final item = entry.value;
          return NewsCard(
            news: item.toNewsItem(rank),
            rank: rank,
          );
        }),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Divider(
            color: theme.colorScheme.outlineVariant.withOpacity(0.4),
            height: 1,
          ),
        ),
      ],
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.sparkles,
                size: 48, color: Color(0xFF7C3AED)),
          ),
          const SizedBox(height: 20),
          Text(
            _selectedDomain == null
                ? 'No Discoveries Yet'
                : 'No $_selectedDomain discoveries yet',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh — science never stops.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => ref.invalidate(breakthroughProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
