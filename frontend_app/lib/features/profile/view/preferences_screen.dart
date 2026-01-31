import 'package:flutter/material.dart';
import '../../../core/services/preferences_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final PreferencesService _prefsService = PreferencesService();
  bool _isLoading = true;
  
  final List<String> _platforms = ['Instagram', 'Facebook', 'Twitter', 'YouTube', 'TikTok', 'LinkedIn', 'Reddit', 'Snapchat'];
  final List<String> _countries = ['USA', 'India', 'UK', 'Japan', 'Germany', 'France', 'Brazil', 'Canada'];
  final List<String> _worldCategories = ['Science', 'Agriculture', 'Space', 'Art', 'Environment', 'Health', 'Politics', 'Sports', 'Entertainment'];
  final List<String> _techCategories = ['AI', 'Mobile', 'Web', 'Blockchain', 'IoT', 'Robotics', 'Cloud', 'Cybersecurity'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _prefsService.loadFromBackend();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Preferences',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: _prefsService,
              builder: (context, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        'Platform Preferences',
                        'Choose your favorite social media platforms',
                        Icons.apps,
                        Colors.blue,
                        _platforms,
                        _prefsService.selectedPlatforms,
                        _prefsService.updatePlatforms,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        'Country Preferences',
                        'Select countries you want to follow',
                        Icons.flag,
                        Colors.green,
                        _countries,
                        _prefsService.selectedCountries,
                        _prefsService.updateCountries,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        'World Categories',
                        'Pick global topics that interest you',
                        Icons.public,
                        Colors.purple,
                        _worldCategories,
                        _prefsService.selectedWorldCategories,
                        _prefsService.updateWorldCategories,
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        'Technology Categories',
                        'Choose your tech interests',
                        Icons.computer,
                        Colors.orange,
                        _techCategories,
                        _prefsService.selectedTechCategories,
                        _prefsService.updateTechCategories,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<String> options,
    Set<String> selected,
    Function(Set<String>) onUpdate,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selected.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (bool value) {
                    setState(() {
                      if (value) {
                        selected.add(option);
                      } else {
                        selected.remove(option);
                      }
                      onUpdate(Set.from(selected));
                    });
                  },
                  selectedColor: color.withOpacity(0.2),
                  checkmarkColor: color,
                  labelStyle: TextStyle(
                    color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}