import '../models/category_model.dart';
import '../../core/database/db_helper.dart';

class CategoryRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Category>> getAllCategories() async {
    final result = await dbHelper.getCategories();
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> addCategory(Category category) async {
    await dbHelper.insertCategory(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await dbHelper.updateCategory(category.toMap());
  }

  Future<void> softDeleteCategory(String id) async {
    await dbHelper.softDeleteCategory(id);
  }
}
