import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrendXLogo extends StatelessWidget {
  final double height;
  final bool isDark;
  
  const TrendXLogo({
    super.key,
    this.height = 32,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/trendx_logo.svg',
      height: height,
      colorFilter: const ColorFilter.mode(
        Color(0xFF00F0FF), // Cyan brand color
        BlendMode.srcIn,
      ),
    );
  }
}
