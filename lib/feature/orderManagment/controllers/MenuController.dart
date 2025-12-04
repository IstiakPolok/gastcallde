import 'dart:convert';
import 'package:flutter/foundation.dart'; // For compute
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../order_entry_screen.dart';

// Top-level function for background parsing
List<FoodMenuItemData> parseMenuItems(String responseBody) {
  final List<dynamic> data = jsonDecode(responseBody);
  return data.map((item) => FoodMenuItemData.fromJson(item)).toList();
}

class Menu_Controller extends GetxController {
  var foodItems = <FoodMenuItemData>[].obs;
  var isLoading = false.obs;
  List<String> get categories {
    final catSet = <String>{};
    catSet.add('All');
    for (var item in foodItems) {
      catSet.add(item.category);
    }
    return catSet.toList();
  }

  List<FoodMenuItemData> filteredItems(String selectedCategory) {
    if (selectedCategory == 'All') return foodItems;
    return foodItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  @override
  void onInit() {
    fetchMenuItems();
    super.onInit();
  }

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      final apiUrl = '${Urls.baseUrl}/owner/items/?lean=EN';
      // print('🔄 Fetching menu items from: $apiUrl');

      final token = await SharedPreferencesHelper.getAccessToken();
      // print('🔑 Token: $token');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      // print('📡 Response status: ${response.statusCode}');
      // print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Use compute to parse JSON in a background isolate
        foodItems.value = await compute(parseMenuItems, response.body);
        print('✅ Menu items fetched: ${foodItems.length}');
      } else {
        print('❌ Failed to load menu items. Status: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to load menu items');
      }
    } catch (e) {
      print('🚨 Error fetching menu: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
