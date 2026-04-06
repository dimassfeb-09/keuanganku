import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../providers/category_provider.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final Category? category;
  const AddEditCategoryScreen({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  late TextEditingController _nameController;
  late String _type;
  late int _selectedIcon;
  late Color _selectedColor;

  final List<Color> _availableColors = [
    const Color(0xFF4CAF50), // Green
    const Color(0xFFF44336), // Red
    const Color(0xFF2196F3), // Blue
    const Color(0xFFFFC107), // Amber
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFFFF9800), // Orange
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF795548), // Brown
    const Color(0xFF009688), // Teal
  ];

  // Preset icons synchronized with defaults
  final List<IconData> _availableIcons = [
    Icons.monetization_on_rounded,
    Icons.redeem_rounded,
    Icons.trending_up_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded,
    Icons.theater_comedy_rounded,
    Icons.medication_rounded,
    Icons.more_horiz_rounded,
    Icons.movie_rounded,
    Icons.medical_services_rounded,
    Icons.card_giftcard_rounded,
    Icons.sports_esports_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
    Icons.home_rounded,
    Icons.local_gas_station_rounded,
    Icons.coffee_rounded,
    Icons.shopping_cart_rounded,
    Icons.payments_rounded,
    Icons.flight_rounded,
    Icons.electrical_services_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _type = widget.category?.type ?? 'expense';
    _selectedIcon = widget.category?.icon ?? _availableIcons[4].codePoint;
    _selectedColor = widget.category != null ? Color(widget.category!.color) : _availableColors[0];
    
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori harus diisi'), backgroundColor: Colors.orange)
      );
      return;
    }

    if (widget.category != null) {
      final updatedCategory = Category(
        id: widget.category!.id,
        name: name,
        type: _type,
        icon: _selectedIcon,
        color: _selectedColor.value,
        isActive: widget.category!.isActive,
      );
      ref.read(categoryProvider.notifier).updateCategory(updatedCategory);
    } else {
      final newCategory = Category(
        id: const Uuid().v4(),
        name: name,
        type: _type,
        icon: _selectedIcon,
        color: _selectedColor.value,
        isActive: true,
      );
      ref.read(categoryProvider.notifier).addCategory(newCategory);
    }

    Navigator.pop(context);
  }

  Widget _buildLivePreview() {
    final color = _type == 'expense' ? AppColors.expense : AppColors.income;
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconData(_selectedIcon, fontFamily: 'MaterialIcons'),
              color: _selectedColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isEmpty ? 'Nama Kategori' : _nameController.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _nameController.text.isEmpty ? Colors.grey[400] : AppColors.textMain,
            ),
          ),
          Text(
            _type == 'expense' ? 'Pengeluaran' : 'Pemasukan',
            style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.category != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Kategori' : 'Tambah Kategori'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLivePreview(),
            const SizedBox(height: 40),
            
            TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Contoh: Belanja, Gaji...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.edit_rounded, color: Colors.indigo),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text('Tipe Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isEdit ? null : () => setState(() => _type = 'expense'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == 'expense' ? AppColors.expense : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _type == 'expense' ? AppColors.expense : Colors.grey[200]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Pengeluaran',
                          style: TextStyle(
                            color: _type == 'expense' ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: isEdit ? null : () => setState(() => _type = 'income'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _type == 'income' ? AppColors.income : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _type == 'income' ? AppColors.income : Colors.grey[200]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Pemasukan',
                          style: TextStyle(
                            color: _type == 'income' ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const SizedBox(height: 32),
            const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  bool isSelected = _selectedColor == color;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                        boxShadow: isSelected ? [
                          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
                        ] : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                bool isSelected = _selectedIcon == icon.codePoint;

                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon.codePoint),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected ? [
                        BoxShadow(color: _selectedColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
                      ] : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: _submit,
                child: Text(
                  isEdit ? 'Simpan Perubahan' : 'Buat Kategori',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
