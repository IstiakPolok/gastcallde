import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> registerUser({
  required String email,
  required String password,
  required String restaurantName,
  required String address,
  required String phoneNumber,
  required String website,
  required String iban,
  required String taxNumber,
  required File? image,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('language_code') ?? 'EN';

  final uri = Uri.parse("${Urls.register}$code");
  final request = http.MultipartRequest('POST', uri);

  // Fields (keep keys exactly as your API expects)
  request.fields['email'] = email;
  request.fields['password'] = password;
  request.fields['resturent_name'] = restaurantName; // spelling per API
  request.fields['address'] = address;
  request.fields['phone_number_1'] = phoneNumber;
  request.fields['websiteww'] = website; // spelling per API
  request.fields['iban'] = iban;
  request.fields['tax_number'] = taxNumber;

  if (image != null) {
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
  }

  // Important: do NOT set Content-Type manually for MultipartRequest
  request.headers['Accept'] = 'application/json';

  // Debug
  debugPrint("----- DEBUG REQUEST -----");
  debugPrint("URL: $uri");
  debugPrint("Method: POST");
  debugPrint("Headers: ${request.headers}");
  debugPrint("Fields: ${request.fields}");
  if (request.files.isNotEmpty) {
    for (var f in request.files) {
      debugPrint("Attached file: ${f.filename} (${f.length} bytes)");
    }
  }
  debugPrint("-------------------------");

  try {
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint("Status: ${response.statusCode}");
    debugPrint("Body: ${response.body}");

    print('HTTP response status: ${response.statusCode}');

    // Your API might return 200 or 201 — handle both
    if (response.statusCode == 201 || response.statusCode == 200) {
      Get.snackbar("Success", "Registration Successful");

      Map<String, dynamic> responseBody = jsonDecode(response.body);

      String accessToken = responseBody['access_token'];
      String refreshToken = responseBody['refresh_token'];

      // Log the access and refresh tokens
      debugPrint("Access Token: $accessToken");
      debugPrint("Refresh Token: $refreshToken");

      // Save the token when user logs in
      SharedPreferencesHelper.saveToken(accessToken);

      print('SAVE TOKE ');

      print(await SharedPreferencesHelper.getAccessToken());
      // If you actually need the response JSON, parse it:
      // final body = json.decode(response.body);
      return true;
    } else {
      Get.snackbar("Failed", "Registration failed (${response.statusCode})");
      return false;
    }
  } catch (e) {
    Get.snackbar("Error", "Something went wrong: $e");
    return false;
  }
}
