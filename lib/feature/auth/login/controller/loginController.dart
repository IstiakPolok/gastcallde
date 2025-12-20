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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    print('[DEBUG] Attempting login with email: $email');

    if (email.isEmpty || password.isEmpty) {
      print('[DEBUG] Email or password is empty');
      Get.snackbar('Error', 'Please enter both email and password.');
      return;
    }

    EasyLoading.show();
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString('language_code') ?? 'EN';
      print('[DEBUG] Language code: $code');
      final uri = Uri.parse('${Urls.login}$code');
      print('[DEBUG] Login URL: $uri');
      final request = http.MultipartRequest('POST', uri)
        ..fields['email'] = email
        ..fields['password'] = password
        ..headers['Content-Type'] = 'multipart/form-data'
        ..headers['Accept'] = 'application/json';

      print('[DEBUG] Request fields: email=$email, password=***');
      print('[DEBUG] Request headers: ${request.headers}');

      final response = await request.send();
      print('[DEBUG] Response status: ${response.statusCode}');
      final responseString = await response.stream.bytesToString();
      print('[DEBUG] Response body: $responseString');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseString);
        print('[DEBUG] Login success, data: $data');
        await SharedPreferencesHelper.saveToken(data['access']);
        await SharedPreferencesHelper.saveRefreshToken(data['refresh']);
        if (data['restaurant']?['id'] != null) {
          print('[DEBUG] Saving restaurant id: ${data['restaurant']['id']}');
          await SharedPreferencesHelper.saveRestaurantId(
            data['restaurant']['id'],
          );
        }
        Get.offAll(() => Dashboard());
        Get.snackbar('Login Successful', 'Welcome back!');
      } else {
        print('[DEBUG] Login failed with status: ${response.statusCode}');
        Get.snackbar('Login Failed', 'Invalid email or password');
      }
    } catch (e) {
      print('[DEBUG] Exception during login: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }
}
