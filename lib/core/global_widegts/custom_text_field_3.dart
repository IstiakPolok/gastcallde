import 'package:flutter/material.dart';

class CustomTextField3 extends StatelessWidget {
  final IconData? icon; // Icon is optional
  final String? hintText;
  final TextEditingController controller;

  const CustomTextField3({
    super.key,
    this.icon,
    this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Set fixed height for the entire container (text field)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey), // Border color
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon:
              icon != null
                  ? Icon(icon, color: Colors.grey)
                  : null, // Add icon if provided
          hintText: hintText, // Hint text
          border: InputBorder.none, // Remove the default border
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0, // Set vertical padding to 0
          ), // Padding inside the text field
        ),
      ),
    );
  }
}
