import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/app_responsive.dart';
import '../../../data/models/wallet_model.dart';
import '../../providers/app_providers.dart';

class AddEditWalletScreen extends ConsumerStatefulWidget {
  final Wallet? wallet;
  const AddEditWalletScreen({super.key, this.wallet});

  @override
  ConsumerState<AddEditWalletScreen> createState() => _AddEditWalletScreenState();
}

class _AddEditWalletScreenState extends ConsumerState<AddEditWalletScreen> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late int _selectedColor;

  final List<int> _availableColors = [
    0xFF4CAF50, // Green
    0xFF2196F3, // Blue
    0xFFE91E63, // Pink
    0xFFF44336, // Red
    0xFFFF9800, // Orange
    0xFF9C27B0, // Purple
    0xFF673AB7, // Deep Purple
    0xFF00BCD4, // Cyan
    0xFF607D8B, // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet?.balance != null ? widget.wallet!.balance.toInt().toString() : '',
    );
    _selectedColor = widget.wallet?.color ?? _availableColors[1]; // Default Blue

    // Listen to changes to rebuild for Live Preview
    _nameController.addListener(() => setState(() {}));
    _balanceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dompet harus diisi'), backgroundColor: Colors.orange),
      );
      return;
    }

    final balanceText = _balanceController.text.replaceAll('.', '').replaceAll(',', '');
    final balance = double.tryParse(balanceText) ?? 0;

    if (widget.wallet != null) {
      final updatedWallet = Wallet(
        id: widget.wallet!.id,
        name: name,
        balance: balance,
        color: _selectedColor,
      );
      ref.read(walletProvider.notifier).updateWallet(updatedWallet);
    } else {
      final newWallet = Wallet(
        id: const Uuid().v4(),
        name: name,
        balance: balance,
        color: _selectedColor,
      );
      ref.read(walletProvider.notifier).addWallet(newWallet);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.wallet != null ? 'Dompet berhasil diperbarui' : 'Dompet berhasil dibuat'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    bool isEdit = widget.wallet != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Dompet' : 'Tambah Dompet Baru', 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(rp.pagePadding.left, 24, rp.pagePadding.right, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rp.isTablet ? 600 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LIVE PREVIEW SECTION
                Text(
                  'Pratinjau Kartu',
                  style: TextStyle(
                    fontSize: rp.isTablet ? 16 : 14, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLivePreview(rp),
                
                const SizedBox(height: 40),
                
                // FORM SECTION
                _buildInputLabel('Nama Dompet', rp),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Misal: Tabungan Utama, OVO, dll',
                  icon: Icons.edit_note,
                  rp: rp,
                ),
                
                const SizedBox(height: 24),
                
                _buildInputLabel('Saldo Awal', rp),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _balanceController,
                  hint: '0',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                  rp: rp,
                  prefix: Text(
                    'Rp ', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: AppColors.textMain,
                      fontSize: rp.isTablet ? 18 : 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                _buildInputLabel('Pilih Warna Dompet', rp),
                const SizedBox(height: 16),
                _buildColorSelector(rp),
                
                const SizedBox(height: 60),
                
                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: rp.isTablet ? 64 : 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      isEdit ? 'Simpan Perubahan' : 'Buat Dompet Sekarang',
                      style: TextStyle(
                        fontSize: rp.isTablet ? 18 : 16, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLivePreview(AppResponsive rp) {
    final color = Color(_selectedColor);
    final name = _nameController.text.isEmpty ? 'Nama Dompet' : _nameController.text;
    final balanceVal = double.tryParse(_balanceController.text) ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: rp.cardPadding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: rp.isTablet ? 24 : 20, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.account_balance_wallet, 
                color: Colors.white70, 
                size: rp.isTablet ? 32 : 28,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Saldo Tersedia', 
            style: TextStyle(
              color: Colors.white70, 
              fontSize: rp.isTablet ? 15 : 13,
            ),
          ),
          Text(
            CurrencyFormat.convertToIdr(balanceVal, 0),
            style: TextStyle(
              color: Colors.white, 
              fontSize: rp.isTablet ? 32 : 26, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, AppResponsive rp) {
    return Text(
      label,
      style: TextStyle(
        fontSize: rp.isTablet ? 17 : 15, 
        fontWeight: FontWeight.bold, 
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required AppResponsive rp,
    TextInputType? keyboardType,
    Widget? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: rp.isTablet ? 18 : 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey[400], 
          fontWeight: FontWeight.normal,
          fontSize: rp.isTablet ? 18 : 16,
        ),
        prefixIcon: Icon(
          icon, 
          color: AppColors.primary, 
          size: rp.isTablet ? 26 : 22,
        ),
        prefix: prefix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(rp.isTablet ? 20 : 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildColorSelector(AppResponsive rp) {
    return SizedBox(
      height: rp.isTablet ? 64 : 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _availableColors.length,
        itemBuilder: (context, index) {
          final colorVal = _availableColors[index];
          final isSelected = _selectedColor == colorVal;

          return GestureDetector(
            onTap: () => setState(() => _selectedColor = colorVal),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? (rp.isTablet ? 60 : 50) : (rp.isTablet ? 54 : 44),
              height: isSelected ? (rp.isTablet ? 60 : 50) : (rp.isTablet ? 54 : 44),
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Color(colorVal),
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                boxShadow: isSelected ? [
                  BoxShadow(color: Color(colorVal).withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 3))
                ] : null,
              ),
              child: isSelected ? Icon(
                Icons.check, 
                color: Colors.white, 
                size: rp.isTablet ? 28 : 24,
              ) : null,
            ),
          );
        },
      ),
    );
  }
}
