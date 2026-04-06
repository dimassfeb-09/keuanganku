import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryGridSelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String) onSelected;
  final Color activeColor;

  const CategoryGridSelector({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onSelected,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kategori',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            bool isSelected = category.id == selectedCategoryId;

            return GestureDetector(
              onTap: () => onSelected(category.id),
              child: Column(
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: isSelected ? 1.15 : 1.0,
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : Colors.grey[100],
                        shape: BoxShape.circle,
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ] : null,
                      ),
                      child: Icon(
                        IconData(category.icon, fontFamily: 'MaterialIcons'),
                        color: isSelected ? Colors.white : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? activeColor : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
