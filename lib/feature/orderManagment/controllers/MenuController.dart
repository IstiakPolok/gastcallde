import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/food_item_model.dart';
import '../order_entry_screen.dart';

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

  final String apiUrl = 'http://10.10.13.26:8000/owner/items/?lean=EN';
  final String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU4NzA3MTU4LCJpYXQiOjE3NTg2OTI3NTgsImp0aSI6IjVmNmU0ODQ1MDY0ZDRlZDM4MTRmNWNiOWQ5ZjllNjliIiwidXNlcl9pZCI6IjMiLCJpZCI6MywiZW1haWwiOiJ0YW5veTk0NTE2QGJpdGZhbWkuY29tIiwicm9sZSI6Ik93bmVyIiwicmVzdGF1cmFudF9pZCI6Mn0.l36EN5l60dWBCCwEndXQtM5SAZ5n3yYZoJPDE89NqxY'; // replace with real token

  @override
  void onInit() {
    fetchMenuItems();
    super.onInit();
  }

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        foodItems.value = data
            .map((item) => FoodMenuItemData.fromJson(item))
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load menu items');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
