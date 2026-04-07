import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../core/utils/app_responsive.dart';

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
    final rp = AppResponsive.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Kategori',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: rp.isTablet ? 18 : 16,
          ),
        ),
        SizedBox(height: rp.isTablet ? 16 : 12),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: rp.gridCrossAxisCount,
            mainAxisSpacing: rp.isTablet ? 28 : 16,
            crossAxisSpacing: rp.isTablet ? 20 : 16,
            childAspectRatio: rp.isTablet ? 0.95 : 0.85,
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
                    scale: isSelected ? 1.1 : 1.0,
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(rp.isTablet ? 18 : 12),
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
                        size: rp.isTablet ? 32 : 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: rp.isTablet ? 14 : 12,
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
