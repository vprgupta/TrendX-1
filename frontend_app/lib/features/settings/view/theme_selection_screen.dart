import 'package:flutter/material.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../config/theme.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Theme'),
      ),
      body: ListenableBuilder(
        listenable: ThemeService(),
        builder: (context, _) {
          final activeThemeId = ThemeService().activeTheme;
          
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildSectionHeader(context, "System & Classic"),
              _buildThemeOption(context, 'system', 'System Default', AppTheme.darkTheme, activeThemeId),
              _buildThemeOption(context, 'light', 'Classic Light', AppTheme.lightTheme, activeThemeId),
              _buildThemeOption(context, 'dark', 'Classic Dark (Uber)', AppTheme.darkTheme, activeThemeId),
              
              const Divider(height: 32),
              _buildSectionHeader(context, "Premium Dark & Vibrant"),
              _buildThemeOption(context, 'ocean', 'Midnight Ocean', AppTheme.oceanTheme, activeThemeId),
              _buildThemeOption(context, 'cyberpunk', 'Cyberpunk Neon', AppTheme.cyberpunkTheme, activeThemeId),
              _buildThemeOption(context, 'forest', 'Deep Forest', AppTheme.forestTheme, activeThemeId),
              
              const Divider(height: 32),
              _buildSectionHeader(context, "Premium Light"),
              _buildThemeOption(context, 'lavender', 'Soft Lavender', AppTheme.lavenderTheme, activeThemeId),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, String themeId, String label, ThemeData previewTheme, String activeThemeId) {
    final bool isSelected = themeId == activeThemeId;
    
    return ListTile(
      onTap: () {
        ThemeService().setTheme(themeId);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected 
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : const SizedBox.shrink(),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: previewTheme.scaffoldBackgroundColor,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Preview Primary Color
            Positioned(
              left: -4,
              bottom: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: previewTheme.colorScheme.primary,
                ),
              ),
            ),
            // Preview Secondary color
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: previewTheme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
