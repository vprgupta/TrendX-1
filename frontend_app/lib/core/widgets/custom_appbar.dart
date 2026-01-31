import 'package:flutter/material.dart';
import 'trendx_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogo;
  
  const CustomAppBar({super.key, required this.title, this.showLogo = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      title: showLogo 
        ? TrendXLogo(isDark: isDark)
        : Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}