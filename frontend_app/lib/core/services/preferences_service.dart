import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class PreferencesService extends ChangeNotifier {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  final Set<String> _selectedPlatforms = {'Instagram', 'Facebook', 'Twitter', 'TikTok', 'YouTube'};
  Set<String> get selectedPlatforms => _selectedPlatforms;

  final Set<String> _selectedCountries = {'USA', 'India'};
  Set<String> get selectedCountries => _selectedCountries;

  final Set<String> _selectedWorldCategories = {'Science', 'Space', 'Art'};
  Set<String> get selectedWorldCategories => _selectedWorldCategories;

  final Set<String> _selectedTechCategories = {'AI', 'Mobile'};
  Set<String> get selectedTechCategories => _selectedTechCategories;

  String _selectedCountryFilter = 'Worldwide';
  String get selectedCountryFilter => _selectedCountryFilter;

  Future<void> updatePlatforms(Set<String> platforms) async {
    _selectedPlatforms.clear();
    _selectedPlatforms.addAll(platforms);
    await _syncToBackend();
    notifyListeners();
  }

  Future<void> updateCountries(Set<String> countries) async {
    _selectedCountries.clear();
    _selectedCountries.addAll(countries);
    await _syncToBackend();
    notifyListeners();
  }

  Future<void> updateWorldCategories(Set<String> categories) async {
    _selectedWorldCategories.clear();
    _selectedWorldCategories.addAll(categories);
    await _syncToBackend();
    notifyListeners();
  }

  Future<void> updateTechCategories(Set<String> categories) async {
    _selectedTechCategories.clear();
    _selectedTechCategories.addAll(categories);
    await _syncToBackend();
    notifyListeners();
  }

  Future<void> _syncToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        await ApiService.updatePreferences(token, {
          'platforms': _selectedPlatforms.toList(),
          'countries': _selectedCountries.toList(),
          'worldCategories': _selectedWorldCategories.toList(),
          'techCategories': _selectedTechCategories.toList(),
        });
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> loadFromBackend() async {
    await loadNavbarOrder(); // Load local prefs first
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        final response = await ApiService.getPreferences(token);
        final preferences = response['preferences'];
        
        _selectedPlatforms.clear();
        _selectedPlatforms.addAll(List<String>.from(preferences['platforms'] ?? []));
        
        _selectedCountries.clear();
        _selectedCountries.addAll(List<String>.from(preferences['countries'] ?? []));
        
        final categories = List<String>.from(preferences['categories'] ?? []);
        _selectedWorldCategories.clear();
        _selectedTechCategories.clear();
        
        for (final category in categories) {
          if (['Science', 'Agriculture', 'Space', 'Art', 'Environment', 'Health', 'Politics', 'Sports', 'Entertainment'].contains(category)) {
            _selectedWorldCategories.add(category);
          } else {
            _selectedTechCategories.add(category);
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> loadCountryFilter() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCountryFilter = prefs.getString('selectedCountryFilter') ?? 'Worldwide';
    notifyListeners();
  }

  // Navbar Order Preference
  List<String> _navbarOrder = ['platform', 'shorts', 'country', 'tech', 'profile'];
  List<String> get navbarOrder => _navbarOrder;
  
  // Available modules for reference
  // platform, shorts, country, tech, profile, politics, geopolitics, local

  Future<void> updateNavbarOrder(List<String> newOrder) async {
    _navbarOrder = newOrder;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('navbarOrder', newOrder);
    notifyListeners();
  }

  Future<void> loadNavbarOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('navbarOrder');
    if (savedOrder != null && savedOrder.isNotEmpty) {
      _navbarOrder = savedOrder;
    }
    notifyListeners();
  }

  Future<void> updateCountryFilter(String country) async {
    _selectedCountryFilter = country;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCountryFilter', country);
    notifyListeners();
  }
}