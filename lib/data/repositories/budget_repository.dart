import '../../core/database/db_helper.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> upsertBudget(Budget budget) async {
    await _dbHelper.upsertBudget(budget.toMap());
  }

  Future<List<Budget>> getBudgetsByMonth(String monthYear) async {
    final res = await _dbHelper.getBudgetsByMonth(monthYear);
    return res.map((m) => Budget.fromMap(m)).toList();
  }

  Future<void> deleteBudget(String id) async {
    await _dbHelper.deleteBudget(id);
  }
}
