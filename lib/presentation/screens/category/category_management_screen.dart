import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/category_provider.dart';
import '../../../data/models/category_model.dart';
import 'add_edit_category_screen.dart';

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Kategori'),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Pengeluaran'),
              Tab(text: 'Pemasukan'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  final expenses = categories.where((c) => c.type == 'expense').toList();
                  final incomes = categories.where((c) => c.type == 'income').toList();

                  return TabBarView(
                    children: [
                      _CategoryList(categories: expenses, type: 'expense'),
                      _CategoryList(categories: incomes, type: 'income'),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditCategoryScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final List<Category> categories;
  final String type;

  const _CategoryList({required this.categories, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Belum ada kategori', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final primaryColor = type == 'expense' ? AppColors.expense : AppColors.income;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.isActive ? primaryColor.withValues(alpha: 0.1) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconData(category.icon, fontFamily: 'MaterialIcons'),
                color: category.isActive ? primaryColor : Colors.grey[400],
                size: 24,
              ),
            ),
            title: Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: category.isActive ? AppColors.textMain : Colors.grey[400],
                decoration: category.isActive ? null : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              category.isActive ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 12,
                color: category.isActive ? primaryColor.withValues(alpha: 0.7) : Colors.grey[400],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded, color: Colors.indigo),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditCategoryScreen(category: category),
                      ),
                    );
                  },
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: category.isActive,
                    activeColor: primaryColor,
                    onChanged: (val) {
                      ref.read(categoryProvider.notifier).updateCategory(
                        Category(
                          id: category.id,
                          name: category.name,
                          type: category.type,
                          icon: category.icon,
                          color: category.color,
                          isActive: val,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
