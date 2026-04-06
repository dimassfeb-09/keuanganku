import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/category_provider.dart';
import '../../widgets/transaction_type_selector.dart';
import '../../widgets/wallet_horizontal_selector.dart';
import '../../widgets/category_grid_selector.dart';

import '../../../data/models/recurring_transaction_model.dart';
import '../../providers/recurring_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();
  bool _isAmountFocused = false;
  late String _type;
  String? _selectedWalletId;
  String? _selectedCategoryId;
  late DateTime _selectedDate;
  
  // Recurring state
  bool _isRecurring = false;
  String _frequency = 'monthly';

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi default
    _type = widget.transaction?.type ?? 'expense';
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toInt().toString();
      _noteController.text = widget.transaction!.note ?? '';
      _selectedWalletId = widget.transaction!.walletId;
      _selectedCategoryId = widget.transaction!.categoryId;
    }

    _amountFocusNode.addListener(() {
      setState(() {
        _isAmountFocused = _amountFocusNode.hasFocus;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_amountController.text.isEmpty ||
        _selectedWalletId == null ||
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data transaksi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah nominal tidak valid')),
      );
      return;
    }

    final isEdit = widget.transaction != null;

    final tx = Transaction(
      id: isEdit ? widget.transaction!.id : const Uuid().v4(),
      amount: amount,
      type: _type,
      date: _selectedDate,
      note: _noteController.text,
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
    );

    if (isEdit) {
      ref.read(transactionProvider.notifier).updateTransaction(tx);
    } else {
      ref.read(transactionProvider.notifier).addTransaction(tx);
      
      // Jika transaksi rutin diaktifkan, buat templatenya
      if (_isRecurring) {
        final rt = RecurringTransaction(
          id: const Uuid().v4(),
          amount: amount,
          type: _type,
          note: _noteController.text,
          walletId: _selectedWalletId!,
          categoryId: _selectedCategoryId!,
          frequency: _frequency,
          nextRunDate: _calculateInitialNextRun(_selectedDate, _frequency),
          isActive: true,
        );
        ref.read(recurringProvider.notifier).addRecurring(rt);
      }
    }
    
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Transaksi berhasil diperbarui' : 'Transaksi berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  DateTime _calculateInitialNextRun(DateTime current, String frequency) {
    switch (frequency) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(current.year, current.month + 1, current.day);
      default:
        return current.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    // Auto-select first wallet if only one exists
    if (_selectedWalletId == null && wallets.length == 1) {
      _selectedWalletId = wallets.first.id;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.transaction != null ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TransactionTypeSelector(
              selectedType: _type,
              onChanged: (val) {
                setState(() {
                  _type = val;
                  _selectedCategoryId = null; // Reset category on type change
                });
              },
            ),
            const SizedBox(height: 32),

            // Amount Input Redesign
            Center(
              child: Column(
                children: [
                  Text(
                    'Masukkan Nominal',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Rp ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textMain,
                        ),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: _type == 'expense'
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                          decoration: InputDecoration(
                            hintText: _isAmountFocused ? '' : '0',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            WalletHorizontalSelector(
              wallets: wallets,
              selectedWalletId: _selectedWalletId,
              onSelected: (id) => setState(() => _selectedWalletId = id),
            ),

            const SizedBox(height: 32),

            categoriesAsync.when(
              data: (categories) {
                final filteredCategories = categories
                    .where((c) => c.type == _type && c.isActive)
                    .toList();

                // Auto-select first category if none selected
                if (_selectedCategoryId == null && filteredCategories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedCategoryId = filteredCategories.first.id;
                      });
                    }
                  });
                }

                return CategoryGridSelector(
                  categories: filteredCategories,
                  selectedCategoryId: _selectedCategoryId,
                  activeColor: _type == 'expense'
                      ? AppColors.expense
                      : AppColors.income,
                  onSelected: (id) => setState(() => _selectedCategoryId = id),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Text('Error: $err'),
            ),

            const SizedBox(height: 12),

            const Text(
              'Tanggal Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Catatan Tambahan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Tulis keterangan transaksi...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              maxLines: 2,
            ),

            if (widget.transaction == null) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Transaksi Rutin',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('Otomatis catat di masa depan'),
                      value: _isRecurring,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isRecurring = val),
                    ),
                    if (_isRecurring)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: DropdownButtonFormField<String>(
                          value: _frequency,
                          decoration: const InputDecoration(
                            labelText: 'Frekuensi Pengulangan',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'daily', child: Text('Harian')),
                            DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                            DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                          ],
                          onChanged: (val) => setState(() => _frequency = val!),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                onPressed: _submit,
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
