import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../../core/theme/app_colors.dart';

class FilterBarWidget extends ConsumerWidget {
  const FilterBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            'Semua',
            filter.type == null,
            () => ref.read(filterProvider.notifier).updateType(null),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Pemasukan',
            filter.type == 'income',
            () => ref.read(filterProvider.notifier).updateType('income'),
            activeColor: AppColors.income,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Pengeluaran',
            filter.type == 'expense',
            () => ref.read(filterProvider.notifier).updateType('expense'),
            activeColor: AppColors.expense,
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _showFilterBottomSheet(context, ref),
            icon: const Icon(Icons.tune_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (activeColor ?? AppColors.primary) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? (activeColor ?? AppColors.primary) : Colors.grey[200]!,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: (activeColor ?? AppColors.primary).withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentFilter = ref.watch(filterProvider);
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Lanjutan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded),
                title: const Text('Rentang Tanggal'),
                subtitle: currentFilter.startDate != null 
                  ? Text('${currentFilter.startDate.toString().split(' ')[0]} - ${currentFilter.endDate.toString().split(' ')[0]}')
                  : const Text('Semua waktu'),
                onTap: () async {
                   final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (range != null) {
                    ref.read(filterProvider.notifier).updateDateRange(range.start, range.end);
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Reset Semua Filter'),
                onTap: () {
                  ref.read(filterProvider.notifier).reset();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
