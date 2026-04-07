import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/wallet_model.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/app_responsive.dart';
import '../../core/theme/app_colors.dart';
import '../providers/app_providers.dart';
import '../screens/transaction/add_transaction_screen.dart';

void showTransactionDetail(
  BuildContext context,
  WidgetRef ref,
  Transaction transaction,
  Category? category,
  Wallet? wallet,
) {
  final rp = AppResponsive.of(context);
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxWidth: rp.isTablet ? 600 : double.infinity),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      bool isIncome = transaction.type == 'income';
      Color color = isIncome ? Colors.green : Colors.red;

      return Padding(
        padding: rp.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: rp.isTablet ? 32 : 24),
            Row(
              children: [
                CircleAvatar(
                  radius: rp.isTablet ? 36 : 30,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(
                    category != null
                        ? IconData(category.icon, fontFamily: 'MaterialIcons')
                        : (isIncome
                              ? Icons.arrow_downward
                              : Icons.arrow_upward),
                    color: color,
                    size: rp.isTablet ? 36 : 30,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Kategori Dihapus',
                      style: TextStyle(
                        fontSize: rp.isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isIncome ? 'Pemasukan' : 'Pengeluaran',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: rp.isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormat.convertToIdr(transaction.amount, 0)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: rp.isTablet ? 26 : 22,
                  ),
                ),
              ],
            ),
            SizedBox(height: rp.isTablet ? 40 : 32),
            _detailRow(
              rp,
              Icons.calendar_today,
              'Tanggal',
              DateFormat('EEEE, dd MMMM yyyy').format(transaction.date),
            ),
            _detailRow(
              rp,
              Icons.access_time,
              'Waktu',
              DateFormat('HH:mm').format(transaction.date),
            ),
            _detailRow(
              rp,
              Icons.account_balance_wallet,
              'Dompet',
              wallet?.name ?? 'Dompet Dihapus',
            ),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              _detailRow(rp, Icons.notes, 'Catatan', transaction.note!),
            SizedBox(height: rp.isTablet ? 40 : 32),
            SizedBox(
              width: double.infinity,
              height: rp.isTablet ? 60 : 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup modal detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTransactionScreen(transaction: transaction),
                    ),
                  );
                },
                icon: Icon(Icons.edit_outlined, size: rp.isTablet ? 24 : 20),
                label: Text(
                  'Edit Transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rp.isTablet ? 16 : 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: rp.isTablet ? 60 : 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: BorderSide(color: Colors.red[200]!),
                ),
                onPressed: () => _confirmDelete(context, ref, transaction.id),
                icon: Icon(Icons.delete_outline, size: rp.isTablet ? 24 : 20),
                label: Text(
                  'Hapus Transaksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rp.isTablet ? 16 : 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: rp.isTablet ? 24 : 16),
          ],
        ),
      );
    },
  );
}

Widget _detailRow(AppResponsive rp, IconData icon, String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: rp.isTablet ? 20 : 16),
    child: Row(
      children: [
        Icon(icon, size: rp.isTablet ? 24 : 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600], 
            fontSize: rp.isTablet ? 16 : 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500, 
              fontSize: rp.isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Transaksi?'),
      content: const Text(
        'Data transaksi ini akan dihapus dan saldo dompet akan dikembalikan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            ref.read(transactionProvider.notifier).deleteTransaction(id);
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close bottom sheet
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
