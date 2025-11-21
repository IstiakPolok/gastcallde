import 'package:flutter/foundation.dart'; // For compute
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/menuManagement/screens/menuManagement.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Top-level function for background parsing
List<Item> parseItems(String responseBody) {
  final List<dynamic> data = jsonDecode(responseBody);
  return data.map((json) => Item.fromJson(json)).toList();
}

Future<List<Item>> fetchItems() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('language_code') ?? 'EN';
  final String url = '${Urls.baseUrl}/owner/items/?lean=EN';

  final String? token = await SharedPreferencesHelper.getAccessToken();
  print('fatch menu Token: $token');
  final headers = {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  try {
    print("🔍 Fetching items...");
    print("➡️ URL: $url");
    print("➡️ Headers: $headers");

    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception(
              'Connection timeout - Server took too long to respond',
            );
          },
        );

    print("✅ Response Status: ${response.statusCode}");
    // print("📦 Response Body: ${response.body}"); // Avoid printing large body in prod

    if (response.statusCode == 200) {
      // Use compute to parse JSON in a background isolate
      return await compute(parseItems, response.body);
    } else {
      throw Exception(
        '❌ Failed to load items: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  } catch (error, stackTrace) {
    print("⚠️ Error occurred: $error");
    print("📌 Stack Trace: $stackTrace");

    // Return empty list instead of throwing to prevent app crash
    Get.snackbar(
      'Connection Error',
      'Unable to fetch menu items. Please check your internet connection.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return [];
  }
}

Future<void> deleteItem(int itemId) async {
  final String url = '${Urls.baseUrl}/owner/items/delete/$itemId/';
  final String? token = await SharedPreferencesHelper.getAccessToken();
  print('fatch menu Token: $token');
  final headers = {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  try {
    final response = await http.delete(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      print('Item deleted successfully');
      Get.to(menuManagement());
    } else {
      throw Exception('Failed to delete item');
    }
  } catch (error) {
    throw Exception('Failed to delete item: $error');
  }
}

Future<void> updateFoodItem({
  required int itemId,
  required String itemName,
  required String status,
  required String description,
  required String price,
  required String category,
  required String preparationTime,
  String? discount,
  String? imageFilePath,
}) async {
  final String url = '${Urls.baseUrl}/owner/items/update/$itemId/?lean=EN';
  final String? token = await SharedPreferencesHelper.getAccessToken();
  print('🔑 Fetching menu with Token: $token');
  final headers = {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'multipart/form-data',
  };

  final request = http.MultipartRequest('PATCH', Uri.parse(url));

  request.headers.addAll(headers);

  // Add the fields as form-data
  request.fields['item_name'] = itemName;
  request.fields['status'] = status;
  request.fields['descriptions'] = description;
  request.fields['price'] = price;
  request.fields['category'] = category;
  request.fields['preparation_time'] = preparationTime;

  // Only add discount if it's not null
  if (discount != null) {
    request.fields['discount'] = discount;
  }

  // If image is provided, add it to the request
  if (imageFilePath != null) {
    final imageFile = await http.MultipartFile.fromPath('image', imageFilePath);
    request.files.add(imageFile);
  }

  try {
    print("🔍 Updating food item...");
    print("➡️ URL: $url");
    print("➡️ Headers: $headers");
    print("➡️ Request Fields: ${request.fields}");

    final response = await request.send();

    print("✅ Response Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      print('✅ Food item updated successfully');
    } else {
      print("❌ Error: ${response.statusCode} - ${response.reasonPhrase}");
      throw Exception('Failed to update food item');
    }
  } catch (error) {
    print("⚠️ Error occurred: $error");
    throw Exception('Failed to update food item: $error');
  }
}
