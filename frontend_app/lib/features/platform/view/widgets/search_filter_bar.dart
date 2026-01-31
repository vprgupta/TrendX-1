import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/preferences_service.dart';

class SearchFilterBar extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final String sortBy;
  final String filterBy;
  final Function(String) onSortChanged;
  final Function(String) onFilterChanged;
  final PreferencesService prefsService;

  const SearchFilterBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onSearchChanged,
    required this.sortBy,
    required this.filterBy,
    required this.onSortChanged,
    required this.onFilterChanged,
    required this.prefsService,
  });

  final Map<String, String> _countries = const {
    'Worldwide': '🌍 Worldwide',
    'US': '🇺🇸 United States',
    'IN': '🇮🇳 India',
    'PK': '🇵🇰 Pakistan',
    'BD': '🇧🇩 Bangladesh',
    'LK': '🇱🇰 Sri Lanka',
    'NP': '🇳🇵 Nepal',
    'BT': '🇧🇹 Bhutan',
    'MV': '🇲🇻 Maldives',
    'AF': '🇦🇫 Afghanistan',
    'GB': '🇬🇧 United Kingdom',
    'CA': '🇨🇦 Canada',
    'AU': '🇦🇺 Australia',
    'DE': '🇩🇪 Germany',
    'FR': '🇫🇷 France',
    'JP': '🇯🇵 Japan',
    'KR': '🇰🇷 South Korea',
    'BR': '🇧🇷 Brazil',
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isSearching ? 140 : 60,
      child: Column(
        children: [
          // Search Bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isSearching ? 60 : 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search trends, creators...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ),
          // Filter Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Country Filter
                Expanded(
                  child: _buildFilterChip(
                    context,
                    icon: Icons.public,
                    label: _countries[prefsService.selectedCountryFilter]?.split(' ')[0] ?? '🌍',
                    onTap: () => _showCountryPicker(context),
                  ),
                ),
                const SizedBox(width: 8),
                // Sort Filter
                Expanded(
                  child: _buildFilterChip(
                    context,
                    icon: Icons.sort,
                    label: _getSortLabel(sortBy),
                    onTap: () => _showSortPicker(context),
                  ),
                ),
                const SizedBox(width: 8),
                // Content Filter
                Expanded(
                  child: _buildFilterChip(
                    context,
                    icon: Icons.filter_list,
                    label: _getFilterLabel(filterBy),
                    onTap: () => _showFilterPicker(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Country',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _countries.entries.map((entry) {
                  final isSelected = prefsService.selectedCountryFilter == entry.key;
                  return ListTile(
                    leading: Text(entry.value.split(' ')[0], style: const TextStyle(fontSize: 20)),
                    title: Text(entry.value.substring(2)),
                    trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                    onTap: () {
                      prefsService.updateCountryFilter(entry.key);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortPicker(BuildContext context) {
    final sortOptions = {
      'trending': 'Trending',
      'likes': 'Most Liked',
      'recent': 'Most Recent',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortOptions.entries.map((entry) {
              final isSelected = sortBy == entry.key;
              return ListTile(
                title: Text(entry.value),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  onSortChanged(entry.key);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFilterPicker(BuildContext context) {
    final filterOptions = {
      'all': 'All Content',
      'videos': 'Videos Only',
      'images': 'Images Only',
      'trending': 'Trending Only',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...filterOptions.entries.map((entry) {
              final isSelected = filterBy == entry.key;
              return ListTile(
                title: Text(entry.value),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  onFilterChanged(entry.key);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'trending': return 'Trending';
      case 'likes': return 'Likes';
      case 'recent': return 'Recent';
      default: return 'Sort';
    }
  }

  String _getFilterLabel(String filterBy) {
    switch (filterBy) {
      case 'all': return 'All';
      case 'videos': return 'Videos';
      case 'images': return 'Images';
      case 'trending': return 'Hot';
      default: return 'Filter';
    }
  }
}