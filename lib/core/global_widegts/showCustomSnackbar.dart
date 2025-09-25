import 'package:get/get.dart';

void showCustomSnackbar({
  required String title,
  required String message,
  // required Color backgroundColor,
  // required Color textColor,
  Duration duration = const Duration(seconds: 3),
  SnackPosition position = SnackPosition.BOTTOM,
}) {
  Get.snackbar(
    title, // Title of the snackbar
    message, // Message of the snackbar
    // snackPosition:
    //     position, // Where the snackbar will appear (bottom, top, etc.)
    // backgroundColor: backgroundColor, // Background color
    // colorText: textColor, // Text color
    // margin: EdgeInsets.all(10), // Margin around the snackbar
    // borderRadius: 10, // Rounded corners
    // duration: duration, // Duration for which the snackbar will be shown
    // isDismissible: true, // Dismissable snackbar
    // dismissDirection:
    //     DismissDirection.horizontal, // Dismiss horizontally (swipe to dismiss)
    // barBlur: 20, // Optional blur effect on the background
  );
}
