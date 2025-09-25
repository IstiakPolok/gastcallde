import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
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

  @override
  void onInit() {
    fetchMenuItems();
    super.onInit();
  }

  Future<void> fetchMenuItems() async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
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
