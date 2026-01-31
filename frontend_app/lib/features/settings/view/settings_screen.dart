import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Preferences',
            [
              ListTile(
                leading: Icon(Icons.location_on, color: AppTheme.accentColor),
                title: const Text('Country Preferences'),
                subtitle: const Text('Select your preferred countries'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, '/preferences');
                },
              ),
              ListTile(
                leading: Icon(Icons.computer, color: AppTheme.accentColor),
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
                secondary: Icon(Icons.notifications, color: AppTheme.accentColor),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive trend alerts'),
                value: true,
                onChanged: (value) {
                  // TODO: Implement notification toggle in Phase 3
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              ListTile(
                leading: Icon(Icons.info, color: AppTheme.accentColor),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: AppTheme.accentColor),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Policy coming in Phase 2')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.description, color: AppTheme.accentColor),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms of Service coming in Phase 2')),
                  );
                },
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
