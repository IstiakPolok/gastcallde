import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  var isPasswordVisible = false.obs;
  var agreedToTerms = false.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    print('Password visibility toggled: ${isPasswordVisible.value}');
  }

  void toggleTermsAgreement(bool? value) {
    agreedToTerms.value = value ?? false;
    print('Terms agreement toggled: ${agreedToTerms.value}');
  }

  // Method to handle login
  Future<void> login(String email, String password) async {
    // Validate the email and password before sending the request
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter both email and password.';
      print('Error: Email or password is empty');
      return;
    }

    EasyLoading.show();

    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'EN';
    print("selected language : $code");

    print('Login attempt with email: $email');
    print('Login attempt with password: $password');

    isLoading.value = true;
    print('Loading state set to true');

    // Prepare the multipart request
    var uri = Uri.parse('${Urls.login}$code');
    print('Request URI: $uri');
    var request = http.MultipartRequest('POST', uri)
      ..fields['email'] = email
      ..fields['password'] = password
      ..headers['Content-Type'] = 'multipart/form-data'
      ..headers['Accept'] = 'application/json';

    // Send POST request
    try {
      var response = await request.send();

      // Get response from the server
      final responseString = await response.stream.bytesToString();
      print('HTTP response status: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 200) {
        // Parse the response
        Get.snackbar('Login Successful', 'Welcome back!');
        var responseData = jsonDecode(responseString);
        String accessToken = responseData['access'];
        String refreshToken = responseData['refresh'];

        // Log the access and refresh tokens

        // Save the token when user logs in
        SharedPreferencesHelper.saveToken(accessToken);

        print(await SharedPreferencesHelper.getAccessToken());

        EasyLoading.dismiss();
        Get.to(Dashboard());
      } else if (response.statusCode == 401) {
        Get.snackbar('Login Failed', 'Invalid email or password');
        errorMessage.value = 'Login failed: ${response.reasonPhrase}';
        print(
          'Error: Login failed with status: ${response.statusCode}, ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      print('Error occurred during login: $e');
    } finally {
      isLoading.value = false;
      print('Loading state set to false');
    }
    EasyLoading.dismiss();
  }
}
