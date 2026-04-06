import '../models/wallet_model.dart';
import '../../core/database/db_helper.dart';

class WalletRepository {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<List<Wallet>> getAllWallets() async {
    final result = await dbHelper.getWallets();
    return result.map((map) => Wallet.fromMap(map)).toList();
  }

  Future<void> addWallet(Wallet wallet) async {
    await dbHelper.insertWallet(wallet.toMap());
  }

  Future<void> updateWallet(Wallet wallet) async {
    await dbHelper.updateWallet(wallet.toMap());
  }

  Future<void> deleteWallet(String id) async {
    await dbHelper.deleteWallet(id);
  }
}
