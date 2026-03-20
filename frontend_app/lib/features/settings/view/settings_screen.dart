import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import 'theme_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.violet,
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              ListTile(
                leading: Icon(Icons.palette, color: AppTheme.cyan),
                title: const Text('App Theme'),
                subtitle: const Text('Change colors to match your style'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ThemeSelectionScreen())
                  );
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Preferences',
            [
              ListTile(
                leading: Icon(Icons.location_on, color: AppTheme.cyan),
                title: const Text('Country Preferences'),
                subtitle: const Text('Select your preferred countries'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/preferences');
                },
              ),
              ListTile(
                leading: Icon(Icons.computer, color: AppTheme.cyan),
                title: const Text('Technology Preferences'),
                subtitle: const Text('Select technologies to follow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/preferences');
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Notifications',
            [
              SwitchListTile(
                secondary: Icon(Icons.notifications, color: AppTheme.cyan),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive trend alerts'),
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                leading: Icon(Icons.info, color: AppTheme.cyan),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: AppTheme.cyan),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showInfoDialog(
                  'Privacy Policy',
                  'TrendX respects your privacy. We do not sell your personal data. All trending information is aggregated from public sources.',
                ),
              ),
              ListTile(
                leading: Icon(Icons.description, color: AppTheme.cyan),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showInfoDialog(
                  'Terms of Service',
                  'By using TrendX, you agree to our terms of service regarding data usage and community standards.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
