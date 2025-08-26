import 'dart:convert';

import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class resetPassController extends GetxController {
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  // Validate Passwords
  bool validatePasswords(String newPassword, String confirmPassword) {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar("Error", "Please enter both passwords.");
      return false;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match.");
      return false;
    }
    return true;
  }

  // API call for password reset
  Future<void> resetPasswordApi(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    isLoading.value = true;

    // Check if passwords are valid
    if (validatePasswords(newPassword, confirmPassword)) {
      bool success = await resetPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (success) {
        // Go to login screen after successful reset
        Get.offAll(LoginScreen());
      }
    }

    isLoading.value = false;
  }
}

Future<bool> resetPassword({
  required String email,
  required String newPassword,
  required String confirmPassword,
}) async {
  final uri = Uri.parse("${Urls.baseUrl}/reset-password/?email=$email");

  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: json.encode({
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    }),
  );

  if (response.statusCode == 200) {
    Get.snackbar("Success", "Password has been reset successfully!");
    return true;
  } else {
    Get.snackbar("Error", "Failed to reset password: ${response.body}");
    return false;
  }
}
