import 'package:flutter/material.dart';
import '../../domain/enums/soundscape_category.dart';

/// Thanh chuyển đổi các chế độ âm thanh (Relax, Focus, Sleep, Activity, Move, ADHD)
/// Thiết kế thanh trượt ngang mượt mà, hỗ trợ thêm bao nhiêu danh mục tùy thích
/// mà không bao giờ bị tràn pixel (overflow) hay co thắt giao diện.
class SoundscapeCategoryBar extends StatelessWidget {
  const SoundscapeCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final SoundscapeCategory selectedCategory;
  final ValueChanged<SoundscapeCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: const Color(0xFF141618),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: SoundscapeCategory.values.map((category) {
                final isSelected = category == selectedCategory;
                return GestureDetector(
                  onTap: () => onCategorySelected(category),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      category.label.toUpperCase(),
                      style: TextStyle(
                        color:
                            isSelected ? Colors.black : const Color(0xFF888888),
                        fontSize: 10.5,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: 1.1,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
