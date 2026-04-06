import '../../core/database/db_helper.dart';
import '../models/recurring_transaction_model.dart';

class RecurringRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> addRecurringTransaction(RecurringTransaction rt) async {
    await _dbHelper.insertRecurringTransaction(rt.toMap());
  }

  Future<List<RecurringTransaction>> getActiveRecurrings() async {
    final res = await _dbHelper.getActiveRecurringTransactions();
    return res.map((m) => RecurringTransaction.fromMap(m)).toList();
  }

  Future<void> updateRecurring(RecurringTransaction rt) async {
    await _dbHelper.updateRecurringTransaction(rt.toMap());
  }

  Future<void> deleteRecurring(String id) async {
    await _dbHelper.deleteRecurringTransaction(id);
  }
}
