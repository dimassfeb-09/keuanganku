import 'package:flutter/material.dart';
import '../../core/utils/app_responsive.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final Widget? prefixIcon;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final rp = AppResponsive.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: rp.isTablet ? 20 : 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: rp.isTablet ? 18 : 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: rp.isTablet ? 16 : 14),
          hintText: hint,
          hintStyle: TextStyle(fontSize: rp.isTablet ? 16 : 14),
          prefixIcon: prefixIcon != null 
            ? Padding(
                padding: EdgeInsets.all(rp.isTablet ? 12 : 8),
                child: prefixIcon,
              )
            : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: rp.isTablet ? 20 : 16, 
            vertical: rp.isTablet ? 18 : 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
