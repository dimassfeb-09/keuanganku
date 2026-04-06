import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('keuanganku.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 5, // Update ke versi 5 untuk warna kategori
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN isActive INTEGER DEFAULT 1');
    }
    
    if (oldVersion < 3) {
      // Migrasi Ikon Kategori
      final updates = {
        'c_gaji': 0xe402,      
        'c_bonus': 0xe506,     
        'c_invest': 0xe661,    
        'c_inc_other': 0xe041, 
        'c_makanan': 0xe56c,   
        'c_trans': 0xe1d1,     
        'c_belanja': 0xf36b,   
        'c_tagihan': 0xef6e,   
        'c_hiburan': 0xea03,   
        'c_sehat': 0xf1ef,     
        'c_exp_other': 0xe5d3, 
      };

      for (var entry in updates.entries) {
        await db.update('categories', 
          {'icon': entry.value}, 
          where: 'id = ?', 
          whereArgs: [entry.key]
        );
      }
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE categories ADD COLUMN color INTEGER DEFAULT 0xFF9E9E9E');
      
      // Update warna default untuk kategori bawaan jika ada
      final categoryColors = {
        'c_gaji': 0xFF4CAF50,
        'c_bonus': 0xFFFFC107,
        'c_invest': 0xFF3F51B5,
        'c_inc_other': 0xFF607D8B,
        'c_makanan': 0xFFF44336,
        'c_trans': 0xFF2196F3,
        'c_belanja': 0xFFE91E63,
        'c_tagihan': 0xFFFF9800,
        'c_hiburan': 0xFF9C27B0,
        'c_sehat': 0xFF00BCD4,
        'c_exp_other': 0xFF795548,
      };

      for (var entry in categoryColors.entries) {
        await db.update('categories', 
          {'color': entry.value}, 
          where: 'id = ?', 
          whereArgs: [entry.key]
        );
      }
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        color INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        isActive INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        walletId TEXT NOT NULL,
        categoryId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        amountLimit REAL NOT NULL,
        monthYear TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        walletId TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        frequency TEXT NOT NULL,
        nextRunDate TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (walletId) REFERENCES wallets (id),
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Seed Data Dummy - Wallet
    await _seedData(db);
  }

  Future<void> _seedData(DatabaseExecutor db) async {
    await db.insert('wallets', {
      'id': 'w_cash',
      'name': 'Cash',
      'balance': 0.0,
      'color': 0xFF4CAF50,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    final List<Map<String, dynamic>> incomeCategories = [
      {'id': 'c_gaji', 'name': 'Gaji', 'type': 'income', 'icon': Icons.monetization_on.codePoint, 'color': 0xFF4CAF50, 'isActive': 1},
      {'id': 'c_bonus', 'name': 'Bonus', 'type': 'income', 'icon': Icons.redeem.codePoint, 'color': 0xFFFFC107, 'isActive': 1},
      {'id': 'c_invest', 'name': 'Investasi', 'type': 'income', 'icon': Icons.trending_up.codePoint, 'color': 0xFF3F51B5, 'isActive': 1},
      {'id': 'c_inc_other', 'name': 'Pendapatan Lain', 'type': 'income', 'icon': Icons.account_balance_wallet.codePoint, 'color': 0xFF607D8B, 'isActive': 1},
    ];
    
    final List<Map<String, dynamic>> expenseCategories = [
      {'id': 'c_makanan', 'name': 'Makanan', 'type': 'expense', 'icon': Icons.restaurant.codePoint, 'color': 0xFFF44336, 'isActive': 1},
      {'id': 'c_trans', 'name': 'Transportasi', 'type': 'expense', 'icon': Icons.directions_car.codePoint, 'color': 0xFF2196F3, 'isActive': 1},
      {'id': 'c_belanja', 'name': 'Belanja', 'type': 'expense', 'icon': Icons.shopping_bag.codePoint, 'color': 0xFFE91E63, 'isActive': 1},
      {'id': 'c_tagihan', 'name': 'Tagihan', 'type': 'expense', 'icon': Icons.receipt_long.codePoint, 'color': 0xFFFF9800, 'isActive': 1},
      {'id': 'c_hiburan', 'name': 'Hiburan', 'type': 'expense', 'icon': Icons.theater_comedy.codePoint, 'color': 0xFF9C27B0, 'isActive': 1},
      {'id': 'c_sehat', 'name': 'Kesehatan', 'type': 'expense', 'icon': Icons.medication.codePoint, 'color': 0xFF00BCD4, 'isActive': 1},
      {'id': 'c_exp_other', 'name': 'Lain-lain', 'type': 'expense', 'icon': Icons.more_horiz.codePoint, 'color': 0xFF795548, 'isActive': 1},
    ];

    for (var cat in incomeCategories) { 
      await db.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.replace); 
    }
    for (var cat in expenseCategories) { 
      await db.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.replace); 
    }
  }

  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('wallets');
      await txn.delete('categories');
      await txn.delete('budgets');
      await txn.delete('recurring_transactions');
      await _seedData(txn);
    });
  }

  // Categories CRUD
  Future<int> insertCategory(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('categories', row);
  }

  Future<int> updateCategory(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('categories', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> softDeleteCategory(String id) async {
    final db = await instance.database;
    return await db.update('categories', {'isActive': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  // Wallets CRUD
  Future<List<Map<String, dynamic>>> getWallets() async {
    final db = await instance.database;
    return await db.query('wallets');
  }

  Future<int> insertWallet(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('wallets', row);
  }

  Future<int> updateWallet(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      'wallets',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<void> deleteWallet(String id) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('transactions', where: 'walletId = ?', whereArgs: [id]);
      await txn.delete('wallets', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Transactions CRUD
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('transactions', row);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await instance.database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  Future<void> updateWalletBalance(String walletId, double amount, String type) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final res = await txn.query('wallets', where: 'id = ?', whereArgs: [walletId]);
      if (res.isNotEmpty) {
        double currentBalance = res.first['balance'] as double;
        double newBalance = type == 'income' ? currentBalance + amount : currentBalance - amount;
        await txn.update('wallets', {'balance': newBalance}, where: 'id = ?', whereArgs: [walletId]);
      }
    });
  }

  Future<void> updateTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 1. Dapatkan data transaksi lama
      final id = row['id'];
      final oldTxRes = await txn.query('transactions', where: 'id = ?', whereArgs: [id]);
      
      if (oldTxRes.isNotEmpty) {
        final oldTx = oldTxRes.first;
        final oldAmount = oldTx['amount'] as double;
        final oldType = oldTx['type'] as String;
        final walletId = oldTx['walletId'] as String; // Asumsi walletId tidak berubah sesuai plan

        // 2. Hitung nilai lama (Pemasukan +, Pengeluaran -)
        double oldVal = oldType == 'income' ? oldAmount : -oldAmount;

        // 3. Hitung nilai baru dari input 'row'
        final newAmount = row['amount'] as double;
        final newType = row['type'] as String;
        double newVal = newType == 'income' ? newAmount : -newAmount;

        // 4. Hitung selisih
        double diff = newVal - oldVal;

        // 5. Update saldo dompet jika ada selisih
        if (diff != 0) {
          final wRes = await txn.query('wallets', where: 'id = ?', whereArgs: [walletId]);
          if (wRes.isNotEmpty) {
            double currentBalance = wRes.first['balance'] as double;
            await txn.update(
              'wallets', 
              {'balance': currentBalance + diff}, 
              where: 'id = ?', 
              whereArgs: [walletId]
            );
          }
        }
      }

      // 6. Update data transaksi
      await txn.update(
        'transactions', 
        row, 
        where: 'id = ?', 
        whereArgs: [id]
      );
    });
  }

  Future<void> deleteTransaction(String id) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // Get transaction details first to reverse balance
      final txRes = await txn.query('transactions', where: 'id = ?', whereArgs: [id]);
      if (txRes.isNotEmpty) {
        final tx = txRes.first;
        final amount = tx['amount'] as double;
        final type = tx['type'] as String;
        final walletId = tx['walletId'] as String;

        // Reverse-update-balance:
        // if old was income, subtract it. if old was expense, add it back.
        final reverseType = type == 'income' ? 'expense' : 'income';
        
        final wRes = await txn.query('wallets', where: 'id = ?', whereArgs: [walletId]);
        if (wRes.isNotEmpty) {
          double currentBalance = wRes.first['balance'] as double;
          double newBalance = reverseType == 'income' ? currentBalance + amount : currentBalance - amount;
          await txn.update('wallets', {'balance': newBalance}, where: 'id = ?', whereArgs: [walletId]);
        }
      }
      
      // Delete the transaction
      await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Budgets CRUD
  Future<int> upsertBudget(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('budgets', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getBudgetsByMonth(String monthYear) async {
    final db = await instance.database;
    return await db.query('budgets', where: 'monthYear = ?', whereArgs: [monthYear]);
  }

  Future<int> deleteBudget(String id) async {
    final db = await instance.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Recurring Transactions CRUD
  Future<int> insertRecurringTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('recurring_transactions', row);
  }

  Future<List<Map<String, dynamic>>> getActiveRecurringTransactions() async {
    final db = await instance.database;
    return await db.query('recurring_transactions', where: 'isActive = 1');
  }

  Future<int> updateRecurringTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('recurring_transactions', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteRecurringTransaction(String id) async {
    final db = await instance.database;
    return await db.delete('recurring_transactions', where: 'id = ?', whereArgs: [id]);
  }
}
