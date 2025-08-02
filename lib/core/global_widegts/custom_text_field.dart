
import 'package:flutter/material.dart';

import '../style/global_text_style.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? prefixIcon;
  final String? prefixText; // 👈 Add this
  final Widget? suffixIcon;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.prefixText, // 👈 Add this
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: globalTextStyle(
        fontSize: 16,
      ), // Replace with your global text style
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixText: prefixText, // 👈 Show prefix like 🇱🇧 +961 |
        prefixStyle: TextStyle(color: Colors.black), // Optional styling
        hintText: hintText,
        hintStyle: globalTextStyle(
          color: Color(0xFFA9A9A9),

          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffd90000).withValues(alpha: 0.25),
          ), // 25% transparency
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffd90000).withValues(alpha: 0.25),
          ), // 25% transparency
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffd90000).withValues(alpha: 0.25),
          ), // 25% transparency
        ),

        prefixIcon:
            prefixIcon != null ? Image.asset(prefixIcon!, width: 20) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
