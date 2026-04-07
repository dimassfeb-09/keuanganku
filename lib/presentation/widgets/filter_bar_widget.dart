import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_responsive.dart';

class FilterBarWidget extends ConsumerWidget {
  const FilterBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterProvider);
    final rp = AppResponsive.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: rp.pagePadding.left, 
        vertical: rp.isTablet ? 16 : 10,
      ),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            rp,
            'Semua',
            filter.type == null,
            () => ref.read(filterProvider.notifier).updateType(null),
          ),
          SizedBox(width: rp.itemSpacing),
          _buildFilterChip(
            context,
            rp,
            'Pemasukan',
            filter.type == 'income',
            () => ref.read(filterProvider.notifier).updateType('income'),
            activeColor: AppColors.income,
          ),
          SizedBox(width: rp.itemSpacing),
          _buildFilterChip(
            context,
            rp,
            'Pengeluaran',
            filter.type == 'expense',
            () => ref.read(filterProvider.notifier).updateType('expense'),
            activeColor: AppColors.expense,
          ),
          SizedBox(width: rp.itemSpacing * 2),
          IconButton(
            onPressed: () => _showFilterBottomSheet(context, ref, rp),
            icon: Icon(Icons.tune_rounded, size: rp.isTablet ? 24 : 20),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: rp.isTablet ? 48 : 40, 
              minHeight: rp.isTablet ? 48 : 40,
            ),
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
    AppResponsive rp,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: rp.isTablet ? 20 : 16, 
          vertical: rp.isTablet ? 12 : 8,
        ),
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
            fontSize: rp.isTablet ? 15 : 13,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref, AppResponsive rp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(maxWidth: rp.isTablet ? 600 : double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentFilter = ref.watch(filterProvider);
        return Container(
          padding: EdgeInsets.all(rp.isTablet ? 32 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Lanjutan', 
                style: TextStyle(
                  fontSize: rp.isTablet ? 22 : 18, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: rp.sectionSpacing),
              ListTile(
                leading: Icon(Icons.calendar_today_rounded, size: rp.isTablet ? 28 : 24),
                title: Text(
                  'Rentang Tanggal',
                  style: TextStyle(fontSize: rp.isTablet ? 18 : 16),
                ),
                subtitle: Text(
                  currentFilter.startDate != null 
                    ? '${currentFilter.startDate.toString().split(' ')[0]} - ${currentFilter.endDate.toString().split(' ')[0]}'
                    : 'Semua waktu',
                  style: TextStyle(fontSize: rp.isTablet ? 15 : 13),
                ),
                onTap: () async {
                   final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (range != null) {
                    ref.read(filterProvider.notifier).updateDateRange(range.start, range.end);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.refresh_rounded, size: rp.isTablet ? 28 : 24),
                title: Text(
                  'Reset Semua Filter',
                  style: TextStyle(fontSize: rp.isTablet ? 18 : 16),
                ),
                onTap: () {
                  ref.read(filterProvider.notifier).reset();
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: rp.sectionSpacing),
            ],
          ),
        );
      },
    );
  }
}
