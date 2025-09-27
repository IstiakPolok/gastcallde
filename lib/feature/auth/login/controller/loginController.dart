import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  // ✅ Text controllers moved here
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var agreedToTerms = false.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleTermsAgreement(bool? value) {
    agreedToTerms.value = value ?? false;
  }

  // ✅ Dispose controllers when controller is removed
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter both email and password.';
      Get.snackbar('Error', errorMessage.value);
      return;
    }

    EasyLoading.show();

    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'EN';

    isLoading.value = true;

    var uri = Uri.parse('${Urls.login}$code');
    var request = http.MultipartRequest('POST', uri)
      ..fields['email'] = email
      ..fields['password'] = password
      ..headers['Content-Type'] = 'multipart/form-data'
      ..headers['Accept'] = 'application/json';

    try {
      var response = await request.send();
      final responseString = await response.stream.bytesToString();

      print('🔵 Login API Response: $responseString');

      if (response.statusCode == 200) {
        Get.snackbar('Login Successful', 'Welcome back!');
        var responseData = jsonDecode(responseString);

        // ✅ Print Restaurant ID safely
        final restaurantData = responseData['restaurant'];

        if (restaurantData != null) {
          final restaurantId = restaurantData['id'];
          print('✅ Restaurant ID: $restaurantId');
          await SharedPreferencesHelper.saveRestaurantId(restaurantId);
        } else {
          print('⚠️ No restaurant data found in response');
        }

        // ✅ Save token
        String accessToken = responseData['access'];
        SharedPreferencesHelper.saveToken(accessToken);

        EasyLoading.dismiss();
        Get.offAll(() => Dashboard());
      } else {
        Get.snackbar('Login Failed', 'Invalid email or password');
        print('🔴 Login failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      print('🔴 Exception during login: $e');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
