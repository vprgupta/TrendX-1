import 'package:flutter/material.dart';
import 'shimmer_card.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final bool hasImage;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.hasImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerCard(hasImage: hasImage);
      },
    );
  }
}