import 'dart:convert';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/feature/auth/forgetPass/screens/resetPassScreen.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../../core/const/app_colors.dart';

class OtpVerificationController extends GetxController {
  var isLoading = false.obs;

  // API call to verify OTP
  Future<void> verifyOtp(String email, String otp) async {
    isLoading.value = true;
    print('Starting OTP verification...'); // Debugging: API call start

    try {
      final response = await http.post(
        Uri.parse(Urls.verifyOtp), // Verify OTP endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      print(
        'Response status: ${response.statusCode}',
      ); // Debugging: Response status
      print('Response body: ${response.body}'); // Debugging: Response body

      if (response.statusCode == 200) {
        // OTP verified successfully
        Get.snackbar(
          "Success",
          "OTP verified successfully",
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate to reset password screen

        Get.to(() => resetPassScreen(), arguments: email);
      } else {
        // OTP verification failed
        Get.snackbar(
          "Error",
          "OTP verification failed",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Network or other error
      print(
        'Error occurred during OTP verification: $e',
      ); // Debugging: Error details
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      print('OTP verification completed.'); // Debugging: API call completed
    }
  }

  // API call to resend OTP
  Future<void> resendOtp(String email) async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        // OTP sent successfully
        // Pass email here
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
