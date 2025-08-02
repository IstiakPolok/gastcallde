import 'package:flutter/material.dart';

class CustomTextField2 extends StatelessWidget {
  final IconData? icon; // Icon is optional
  final String? hintText;
  final String? prefixText; // 👈 Add this
  final TextEditingController controller;
  final VoidCallback? onTap;

  const CustomTextField2({
    super.key,
    this.icon,
    this.hintText,
    this.prefixText, // 👈 Add this
    required this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey), // Border color
      ),
      child: TextField(
        controller: controller,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon:
              icon != null
                  ? Icon(icon, color: Colors.grey)
                  : null, // Add icon if provided
          prefixText: prefixText, // 👈 Show prefix like 🇱🇧 +961 |
          prefixStyle: TextStyle(color: Colors.black), // Optional styling
          hintText: hintText, // Hint text
          border: InputBorder.none, // Remove the default border
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ), // Padding inside the text field
        ),
      ),
    );
  }
}
