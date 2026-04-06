import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/repositories/transaction_repository.dart';

// REPOS
final walletRepositoryProvider = Provider((ref) => WalletRepository());
final transactionRepositoryProvider = Provider((ref) => TransactionRepository());

// WALLET PROVIDER
final walletProvider = StateNotifierProvider<WalletNotifier, List<Wallet>>((ref) {
  return WalletNotifier(ref.read(walletRepositoryProvider), ref);
});

class WalletNotifier extends StateNotifier<List<Wallet>> {
  final WalletRepository _repository;
  final Ref _ref;

  WalletNotifier(this._repository, this._ref) : super([]) {
    loadWallets();
  }

  Future<void> loadWallets() async {
    final wallets = await _repository.getAllWallets();
    state = wallets;
  }

  Future<void> addWallet(Wallet wallet) async {
    await _repository.addWallet(wallet);
    await loadWallets();
  }

  Future<void> updateWallet(Wallet wallet) async {
    await _repository.updateWallet(wallet);
    await loadWallets();
  }

  Future<void> deleteWallet(String id) async {
    await _repository.deleteWallet(id);
    await loadWallets();
    // Cascade effect: refresh transactions as well
    _ref.invalidate(transactionProvider);
  }
}

// TRANSACTION PROVIDER
final transactionProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionNotifier(ref.read(transactionRepositoryProvider), ref);
});

class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionRepository _repository;
  final Ref _ref;

  TransactionNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final transactions = await _repository.getAllTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _repository.addTransaction(transaction);
      // Reload everything after adding transaction
      await loadTransactions();
      await _ref.read(walletProvider.notifier).loadWallets();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      // Reload everything after updating transaction
      await loadTransactions();
      await _ref.read(walletProvider.notifier).loadWallets();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
      await _ref.read(walletProvider.notifier).loadWallets();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
