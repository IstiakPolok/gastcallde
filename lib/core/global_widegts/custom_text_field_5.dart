
import 'package:flutter/material.dart';

import '../style/global_text_style.dart';

class CustomTextField5 extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? prefixIcon;
  final String? prefixText; // 👈 Add this
  final Widget? suffixIcon;
  final bool obscureText;

  const CustomTextField5({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.prefixText, // 👈 Add this
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField5> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      style: globalTextStyle(
        fontSize: 16,
      ), // Replace with your global text style
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        // If focused, show the prefix text, otherwise hide it
        prefixText:
            _isFocused && widget.prefixText != null
                ? widget
                    .prefixText // Show the prefix like 🇱🇧 +961 |
                : null,
        prefixStyle: globalTextStyle(
          color: Color(0xFFA9A9A9),
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
        hintText:
            _isFocused ? null : widget.hintText, // Hide hint text when focused
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
            color: Color(0xffd90000).withOpacity(0.25), // 25% transparency
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffd90000).withOpacity(0.25), // 25% transparency
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Color(0xffd90000).withOpacity(0.25), // 25% transparency
          ),
        ),
        prefixIcon:
            widget.prefixIcon != null
                ? Image.asset(widget.prefixIcon!, width: 20)
                : null,
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}
