import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

final categoryProvider = NotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>(() {
  return CategoryNotifier();
});

class CategoryNotifier extends Notifier<AsyncValue<List<Category>>> {
  late final CategoryRepository _repository;

  @override
  AsyncValue<List<Category>> build() {
    _repository = ref.read(categoryRepositoryProvider);
    loadCategories();
    return const AsyncValue.loading();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(Category category) async {
    await _repository.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }

  Future<void> softDeleteCategory(String id) async {
    await _repository.softDeleteCategory(id);
    await loadCategories();
  }
}
