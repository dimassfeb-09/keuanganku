import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../../data/models/budget_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_responsive.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final Budget? budget;

  const AddEditBudgetScreen({super.key, this.budget});

  @override
  ConsumerState<AddEditBudgetScreen> createState() =>
      _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amountLimit.toStringAsFixed(0);
      _selectedCategoryId = widget.budget!.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedCategoryId == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kategori dan jumlah anggaran')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final now = DateTime.now();
    final monthYear = DateFormat('MM-yyyy').format(now);

    final budget = Budget(
      id: widget.budget?.id ?? const Uuid().v4(),
      categoryId: _selectedCategoryId!,
      amountLimit: amount,
      monthYear: monthYear,
    );

    ref.read(budgetProvider.notifier).upsertBudget(budget);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    final categoriesAsync = ref.watch(categoryProvider);
    final expenseCategories = categoriesAsync.when(
      data: (cats) => cats.where((c) => c.type == 'expense').toList(),
      loading: () => [],
      error: (_, _) => [],
    );

    final now = DateTime.now();
    final monthHeader = DateFormat('MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Set Anggaran' : 'Edit Anggaran'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textMain,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: rp.pagePadding.left),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: rp.isTablet ? 600 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Target pengeluaran bulan $monthHeader',
                        style: TextStyle(
                          color: Colors.grey[600], 
                          fontSize: rp.isTablet ? 15 : 13,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // LARGE AMOUNT INPUT
                      Text(
                        'RENCANA LIMIT',
                        style: TextStyle(
                          fontSize: rp.isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          autofocus: widget.budget == null,
                          style: TextStyle(
                            fontSize: rp.isTablet ? 56 : 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -1,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: TextStyle(
                              fontSize: rp.isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // CATEGORY SELECTION HEADER
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pilih Kategori',
                          style: TextStyle(
                            fontSize: rp.isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // CATEGORY GRID
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rp.isTablet ? 4 : 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: expenseCategories.length,
                        itemBuilder: (context, index) {
                          final cat = expenseCategories[index];
                          final isSelected = _selectedCategoryId == cat.id;

                          return InkWell(
                            onTap: widget.budget != null
                                ? null
                                : () {
                                    setState(() => _selectedCategoryId = cat.id);
                                  },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey[200]!,
                                  width: 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    IconData(cat.icon, fontFamily: 'MaterialIcons'),
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMain,
                                    size: rp.isTablet ? 32 : 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      cat.name,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: rp.isTablet ? 14 : 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textMain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ACTION BUTTONS
          Container(
            padding: EdgeInsets.fromLTRB(
              rp.pagePadding.left, 
              24, 
              rp.pagePadding.right, 
              24 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: rp.isTablet ? 600 : double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.budget != null) ...[
                      TextButton.icon(
                        onPressed: () {
                          ref
                              .read(budgetProvider.notifier)
                              .deleteBudget(widget.budget!.id);
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.delete_outline, 
                          color: Colors.red,
                          size: rp.isTablet ? 24 : 20,
                        ),
                        label: Text(
                          'Hapus Anggaran Ini',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: rp.isTablet ? 16 : 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: rp.isTablet ? 64 : 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.budget == null
                              ? 'Aktifkan Anggaran'
                              : 'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: rp.isTablet ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
