import 'package:flutter/material.dart';
import '../../../../core/ui/glass_container.dart';
import '../../../../core/ui/section_header.dart';
import '../../model/platform.dart';
import 'trend_card.dart';

class PlatformFeed extends StatelessWidget {
  final String platformName;
  final List<PlatformTrend> trends;

  const PlatformFeed({
    super.key,
    required this.platformName,
    required this.trends,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Platform Header
        // Platform Header
        SectionHeader(
          title: platformName,
          icon: _getPlatformIcon(platformName),
          color: _getPlatformColor(platformName),
        ),
        
        // Trends with Spacing
        ...trends.map((trend) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: TrendCard(trend: trend),
        )),
        
        const SizedBox(height: 8),
      ],
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Colors.purple;
      case 'facebook':
        return Colors.blue;
      case 'twitter':
        return Colors.lightBlue;
      case 'youtube':
        return Colors.red;
      case 'tiktok':
        return Colors.black;
      case 'linkedin':
        return Colors.indigo;
      case 'reddit':
        return Colors.orange;
      case 'snapchat':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email;
      case 'youtube':
        return Icons.play_circle;
      case 'tiktok':
        return Icons.music_note;
      case 'linkedin':
        return Icons.business;
      case 'reddit':
        return Icons.forum;
      case 'snapchat':
        return Icons.camera;
      default:
        return Icons.public;
    }
  }
}