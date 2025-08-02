import 'package:flutter/material.dart';

class CustomTextField4 extends StatefulWidget {
  final IconData? icon;
  final String? hintText;
  final String? prefixDisplay; // e.g. 🇱🇧 +961 |
  final TextEditingController controller;
  final VoidCallback? onTap;

  const CustomTextField4({
    super.key,
    this.icon,
    this.hintText,
    this.prefixDisplay,
    required this.controller,
    this.onTap,
  });

  @override
  _CustomTextField2State createState() => _CustomTextField2State();
}

class _CustomTextField2State extends State<CustomTextField4> {
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onTap: widget.onTap,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon:
              widget.icon != null
                  ? Icon(widget.icon, color: Colors.grey)
                  : null,
          prefix:
              _isFocused && widget.prefixDisplay != null
                  ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      widget.prefixDisplay!,
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                  : null,
          hintText:
              _isFocused ? null : widget.hintText, // Hide hint when focused
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
