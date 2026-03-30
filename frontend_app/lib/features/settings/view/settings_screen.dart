import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import 'theme_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;

  // Replace with your actual hosted privacy policy URL
  static const _privacyPolicyUrl =
      'https://vprgupta.github.io/trendx-privacy-policy';
  static const _termsOfServiceUrl =
      'https://vprgupta.github.io/trendx-privacy-policy#terms';

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the page.')),
        );
      }
    }
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
                leading: const Icon(Icons.privacy_tip, color: AppTheme.cyan),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _launchUrl(_privacyPolicyUrl),
              ),
              ListTile(
                leading: const Icon(Icons.description, color: AppTheme.cyan),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _launchUrl(_termsOfServiceUrl),
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
