import '../models/transaction_model.dart';
import '../../core/database/db_helper.dart';

class TransactionRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Transaction>> getAllTransactions() async {
    final result = await dbHelper.getTransactions();
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await dbHelper.insertTransaction(transaction.toMap());
    await dbHelper.updateWalletBalance(transaction.walletId, transaction.amount, transaction.type);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await dbHelper.updateTransaction(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await dbHelper.deleteTransaction(id);
  }
}
