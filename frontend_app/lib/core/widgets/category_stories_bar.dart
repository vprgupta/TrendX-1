import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryStory {
  final String label;
  final String emoji;
  final List<Color> gradient;
  final String filterKey; // matches backend category param

  const CategoryStory({
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.filterKey,
  });
}

const List<CategoryStory> kCategoryStories = [
  CategoryStory(
    label: 'All',
    emoji: '✨',
    gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    filterKey: 'All',
  ),
  CategoryStory(
    label: 'Tech',
    emoji: '💻',
    gradient: [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
    filterKey: 'Technology',
  ),
  CategoryStory(
    label: 'World News',
    emoji: '🌍',
    gradient: [Color(0xFF10B981), Color(0xFF059669)],
    filterKey: 'world',
  ),
  CategoryStory(
    label: 'Health',
    emoji: '🏥',
    gradient: [Color(0xFFF43F5E), Color(0xFFEC4899)],
    filterKey: 'Health',
  ),
  CategoryStory(
    label: 'General',
    emoji: '📰',
    gradient: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    filterKey: 'General',
  ),
  CategoryStory(
    label: 'Science',
    emoji: '🔬',
    gradient: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
    filterKey: 'Science',
  ),
  CategoryStory(
    label: 'Business',
    emoji: '💼',
    gradient: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    filterKey: 'Business',
  ),
  CategoryStory(
    label: 'Sports',
    emoji: '🏆',
    gradient: [Color(0xFF22C55E), Color(0xFF16A34A)],
    filterKey: 'Sports',
  ),
];

class CategoryStoriesBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryStoriesBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kCategoryStories.length,
        itemBuilder: (context, i) {
          final cat = kCategoryStories[i];
          final isSelected = selectedCategory == cat.filterKey;
          return _CategoryStoryItem(
            story: cat,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              onCategorySelected(cat.filterKey);
            },
          );
        },
      ),
    );
  }
}

class _CategoryStoryItem extends StatelessWidget {
  final CategoryStory story;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryStoryItem({
    required this.story,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing avatar ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isSelected ? 58 : 52,
              height: isSelected ? 58 : 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? LinearGradient(
                        colors: story.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: isSelected
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: story.gradient.first.withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(fontSize: isSelected ? 26 : 22),
                  child: Text(story.emoji),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? story.gradient.first
                    : Colors.white.withOpacity(0.55),
              ),
              child: Text(story.label),
            ),
          ],
        ),
      ),
    );
  }
}
