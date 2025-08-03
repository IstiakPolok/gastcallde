import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.backgroundColor = AppColors.primaryColor, // Default color
    this.borderColor,
    required this.onPress,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ), // Default text style
  });

  final String title;
  final Color backgroundColor;
  final Color? borderColor;
  final TextStyle textStyle; // Default text style is set to white color
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        splashColor: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        onTap: onPress,
        child: Center(
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),

              border: borderColor != null
                  ? Border.all(color: borderColor!)
                  : null,
            ),
            child: Center(child: Text(title, style: textStyle)),
          ),
        ),
      ),
    );
  }
}
