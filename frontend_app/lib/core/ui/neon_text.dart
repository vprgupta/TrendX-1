import 'package:flutter/material.dart';

class NeonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double blurRadius;
  final TextAlign align;

  const NeonText(
    this.text, {
    super.key,
    this.style,
    this.glowColor = const Color(0xFF00F0FF),
    this.blurRadius = 10,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: (style ?? Theme.of(context).textTheme.bodyMedium!).copyWith(
        shadows: [
          Shadow(
            color: glowColor.withOpacity(0.6),
            blurRadius: blurRadius,
            offset: Offset.zero,
          ),
          Shadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: blurRadius * 2,
            offset: Offset.zero,
          ),
        ],
      ),
    );
  }
}
