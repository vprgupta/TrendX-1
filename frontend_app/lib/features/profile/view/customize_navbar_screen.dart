import 'package:flutter/material.dart';
import '../../../../core/services/preferences_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomizeNavbarScreen extends StatefulWidget {
  const CustomizeNavbarScreen({super.key});

  @override
  State<CustomizeNavbarScreen> createState() => _CustomizeNavbarScreenState();
}

class _CustomizeNavbarScreenState extends State<CustomizeNavbarScreen> {
  final PreferencesService _prefsService = PreferencesService();
  late List<String> _currentOrder;
  
  // Available modules map for display
  final Map<String, Map<String, dynamic>> _moduleInfo = {
    'platform': {'label': 'Platform', 'icon': LucideIcons.layoutGrid},
    'shorts': {'label': 'Shorts', 'icon': LucideIcons.play},
    'country': {'label': 'Country', 'icon': LucideIcons.flag},
    'tech': {'label': 'Tech', 'icon': LucideIcons.monitor},
    'politics': {'label': 'Politics', 'icon': LucideIcons.landmark},
    'geopolitics': {'label': 'Geopolitics', 'icon': LucideIcons.globe},
    'local': {'label': 'Local News', 'icon': LucideIcons.mapPin},
    'profile': {'label': 'Profile', 'icon': LucideIcons.user},
  };

  // Profile should typically stay reachable, but for full customization we allow moving it? 
  // Let's enforce that at least 2 items must be selected.

  @override
  void initState() {
    super.initState();
    // Copy the list to avoid modifying the service directly before saving
    _currentOrder = List.from(_prefsService.navbarOrder);
    
    // Remove profile from the order list as it should be fixed
    _currentOrder.remove('profile');
    
    // Filter out profile from available keys check too
    // We need a list of ALL key options.
    final allKeys = _moduleInfo.keys.toList();
    for (var key in allKeys) {
      if (!_currentOrder.contains(key) && key != 'profile') {
        // Decide if we append them as "disabled" (not in list) or just keep track separately.
      }
    }
  }

  void _save() {
    // Add profile back at the end
    final List<String> finalOrder = List.from(_currentOrder)..add('profile');

    if (finalOrder.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must select at least 2 items')),
      );
      return;
    }
    _prefsService.updateNavbarOrder(finalOrder);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Layout saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // We need to differentiate between Active and Inactive items for the UI
    // Active items are in _currentOrder.
    // Inactive items are _moduleInfo.keys that are NOT in _currentOrder.
    
    final activeItems = _currentOrder;
    final inactiveItems = _moduleInfo.keys.where((k) => !_currentOrder.contains(k) && k != 'profile').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Layout'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Active Tabs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Drag to reorder',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final String item = activeItems.removeAt(oldIndex);
                  activeItems.insert(newIndex, item);
                });
              },
              children: [
                for (final key in activeItems)
                  ListTile(
                    key: Key(key),
                    leading: Icon(_moduleInfo[key]!['icon']),
                    title: Text(_moduleInfo[key]!['label']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              activeItems.remove(key);
                              // It effectively moves to inactive because it's no longer in activeItems
                            });
                          },
                        ),
                        const Icon(Icons.drag_handle),
                      ],
                    ),
                  ),
              ],
            ),
            
            // Fixed Profile Item
            ListTile(
              leading: Icon(_moduleInfo['profile']!['icon'], color: Theme.of(context).colorScheme.primary),
              title: Text(
                _moduleInfo['profile']!['label'], 
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)
              ),
              subtitle: const Text('Always fixed at the end'),
              trailing: const Icon(Icons.lock_outline, size: 20),
            ),
            
            const Divider(height: 32),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Available Tabs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            if (inactiveItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('All tabs are active'),
              ),
            
            ...inactiveItems.map((key) => ListTile(
              leading: Icon(_moduleInfo[key]!['icon'], color: Colors.grey),
              title: Text(
                _moduleInfo[key]!['label'],
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                onPressed: () {
                  setState(() {
                    activeItems.add(key);
                  });
                },
              ),
            )),
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
