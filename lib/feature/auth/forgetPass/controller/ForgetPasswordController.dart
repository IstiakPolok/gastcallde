import 'package:flutter/material.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/feature/auth/forgetPass/screens/otpVerificationScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPasswordController extends GetxController {
  var isLoading = false.obs;

  // Send OTP API
  Future<void> sendOtp(String email) async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        // OTP sent successfully
        Get.to(
          () => otpVerificationScreen(),
          arguments: email,
        ); // Pass email here
        Get.snackbar(
          "Success",
          "OTP has been sent to your  email $email",
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate to OTP Verification Screen
      } else {
        // API response error
        Get.snackbar(
          "Error",
          "Failed to send OTP",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Catch any network errors
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
