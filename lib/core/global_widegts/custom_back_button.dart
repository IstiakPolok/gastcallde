import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const CustomBackButton({
    super.key,
    this.backgroundColor = const Color(0xFFD6D6D6),
    this.iconColor = Colors.black,
    this.size = 15,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.back();
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          radius: size,
          child: Icon(
            Icons.arrow_back_ios_new,
            size:
                size! *
                0.8, // Adjust icon size relative to the CircleAvatar size
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
