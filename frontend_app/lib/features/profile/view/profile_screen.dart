import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'preferences_screen.dart';
import 'edit_profile_screen.dart';
import 'customize_navbar_screen.dart';
import '../../auth/controller/auth_controller.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/services/preferences_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  
  const ProfileScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _authController = AuthController();
  final _profileService = ProfileService();
  final _prefsService = PreferencesService();
  final _imagePicker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String? _profileName;
  String? _profileBio;
  String? _avatarPath;

  final Map<String, String> _countries = {
    'Worldwide': '🌍 Worldwide',
    'IN': '🇮🇳 India',
    'NP': '🇳🇵 Nepal',
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }
  
  Future<void> _loadProfileData() async {
    _profileName = await _profileService.getName();
    _profileBio = await _profileService.getBio();
    _avatarPath = await _profileService.getAvatarPath();
    if (mounted) setState(() {});
  }
  
  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _profileService.saveAvatarPath(pickedFile.path);
      setState(() => _avatarPath = pickedFile.path);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Ensure transparency for global background
      body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
                child: Column(
                  children: [
                    _buildAppBar(context, colorScheme),
                    const SizedBox(height: 32),
                    _buildProfileHeader(context, colorScheme),
                    const SizedBox(height: 24),
                    _buildCountrySection(context, colorScheme),
                    const SizedBox(height: 24),
                    _buildMenuItems(context, colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),

    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // Avatar with tap to select image
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                child: _avatarPath == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: colorScheme.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Username
        Text(
          _profileName ?? _authController.currentUser?.name ?? 'Guest User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Bio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _profileBio ?? 'Tap Edit Profile to add your bio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        
        // Edit Profile Button
        OutlinedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
            if (result == true) {
              _loadProfileData(); // Reload data after edit
            }
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildCountrySection(BuildContext context, ColorScheme colorScheme) {
    final current = _prefsService.selectedCountryFilter.isEmpty
        ? 'Worldwide'
        : _prefsService.selectedCountryFilter;
    final displayName = _countries[current] ?? '🌍 $current';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          _prefsService.updateCountryFilter(value);
          setState(() {});
        },
        itemBuilder: (context) => _countries.entries.map((entry) {
          return PopupMenuItem(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language_outlined, color: Colors.blue, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Country / Region',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, ColorScheme colorScheme) {
    final menuItems = [
      {'icon': Icons.tune, 'title': 'Preferences', 'subtitle': 'Customize your content preferences', 'color': Colors.purple, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PreferencesScreen()))},
      {'icon': Icons.dashboard_customize_outlined, 'title': 'Customize Layout', 'subtitle': 'Reorder and toggle tabs', 'color': Colors.indigo, 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomizeNavbarScreen()))},
      {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'subtitle': 'Manage alerts', 'color': Colors.blue, 'onTap': () {}},
      {'icon': Icons.help_outline, 'title': 'Help & Support', 'subtitle': 'Get assistance', 'color': Colors.green, 'onTap': () {}},
      {'icon': Icons.info_outline, 'title': 'About', 'subtitle': 'App information', 'color': Colors.teal, 'onTap': () {}},
    ];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              ...menuItems.map((item) => _buildMenuItem(
                context,
                colorScheme,
                item['icon'] as IconData,
                item['title'] as String,
                item['subtitle'] as String,
                item['color'] as Color,
                item['onTap'] as VoidCallback,
              )),
              _buildThemeToggle(context, colorScheme),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLogoutButton(context, colorScheme),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, ColorScheme colorScheme, IconData icon, String title, String subtitle, Color accentColor, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor.withOpacity(0.2), accentColor.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.withOpacity(0.2), Colors.indigo.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.indigo,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.isDarkMode,
            onChanged: (_) => widget.onThemeToggle(),
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.error.withOpacity(0.1), colorScheme.error.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.error.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: colorScheme.error),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}