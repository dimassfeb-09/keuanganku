import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class CategoryExpenseChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  final double totalExpense;
  final List<String> categoryNames;
  final List<int> categoryIcons;
  final List<int> categoryColors;

  const CategoryExpenseChart({
    super.key,
    required this.sections,
    required this.totalExpense,
    required this.categoryNames,
    required this.categoryIcons,
    required this.categoryColors,
  });

  @override
  State<CategoryExpenseChart> createState() => _CategoryExpenseChartState();
}

class _CategoryExpenseChartState extends State<CategoryExpenseChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Belum ada data pengeluaran bulan ini', 
          style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Pengeluaran per Kategori',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sentuh bagian diagram untuk detail',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sections: showingSections(),
                    centerSpaceRadius: 60,
                    sectionsSpace: 2,
                  ),
                ),
                _buildCenterText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterText() {
    bool isTouched = touchedIndex != -1 && touchedIndex < widget.categoryNames.length;
    
    String label = isTouched ? widget.categoryNames[touchedIndex] : 'Total';
    double value = isTouched ? widget.sections[touchedIndex].value : widget.totalExpense;
    Color color = isTouched ? widget.sections[touchedIndex].color : AppColors.expense;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: isTouched ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value),
            key: ValueKey(value),
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
              color: color
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.sections.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 65.0 : 55.0;
      final badgeSize = isTouched ? 42.0 : 32.0;
      
      final section = widget.sections[i];

      return section.copyWith(
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
        badgeWidget: (i < widget.categoryIcons.length) 
          ? _Badge(
              IconData(widget.categoryIcons[i], fontFamily: 'MaterialIcons'),
              size: badgeSize,
              borderColor: Color(widget.categoryColors[i]),
            )
          : null,
        badgePositionPercentageOffset: 1.15,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;

  const _Badge(
    this.icon, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.6, // Slightly smaller to ensure better centering
          color: borderColor,
        ),
      ),
    );
  }
}
