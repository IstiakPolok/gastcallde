import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:gastcallde/feature/orderManagment/models/food_item_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../orderManagmentscreen.dart';

class OrderEntryController extends GetxController {
  final orderItems = <FoodItem>[].obs;
  final customerNameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final orderNotesController = TextEditingController();

  var selectedCategory = 'All'.obs;

  Future<void> createOrder() async {
    if (orderItems.isEmpty ||
        customerNameController.text.isEmpty ||
        addressController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add food items, customer name, and address.',
      );
      print("Order creation failed: Missing required fields");
      return;
    }

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse('${Urls.baseUrl}/owner/create/order/');
      final RestaurantId = await SharedPreferencesHelper.getRestaurantId();

      final body = {
        "restaurant": RestaurantId,
        "customer_name": customerNameController.text,
        "status": "incoming",
        "order_items": orderItems.map((item) {
          print(
            "Order item: ${item.name}, qty: ${item.quantity}, extras: ${item.extras}",
          );
          return {
            "item": item.id,
            "quantity": item.quantity,
            "extras": item.extras.join(", "),
            "extras_price":
                item.totalPrice - item.price, // calculate extras price
            "special_instructions": item.specialInstructions,
          };
        }).toList(),
        "email": "test@example.com",
        "phone": phoneController.text,
        "order_notes": orderNotesController.text,
        "address": addressController.text,
        "allergy": "",
        "discount_text": "",
      };

      print("Sending order payload: $body");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar("Success", "Order Created Successfully!");
        clearForm();
        Get.off(orderManagmentscreen());
      } else {
        Get.snackbar("Error", "Failed to create order: ${response.body}");
      }
    } catch (e) {
      print("Order creation exception: $e");
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }

  void addFoodItem(FoodItem item) {
    print("Adding item: ${item.name}");
    var existingItemIndex = orderItems.indexWhere((i) => i.name == item.name);
    if (existingItemIndex != -1) {
      orderItems[existingItemIndex].quantity++;
      orderItems.refresh();
      print(
        "Incremented quantity of ${item.name} to ${orderItems[existingItemIndex].quantity}",
      );
    } else {
      orderItems.add(item);
      print("Added new item: ${item.name}");
    }
  }

  void incrementQuantity(FoodItem item) {
    item.quantity++;
    orderItems.refresh();
    print("Incremented quantity of ${item.name} to ${item.quantity}");
  }

  void decrementQuantity(FoodItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      print("Decremented quantity of ${item.name} to ${item.quantity}");
    } else {
      orderItems.remove(item);
      print("Removed item: ${item.name}");
    }
    orderItems.refresh();
  }

  void removeItem(FoodItem item) {
    orderItems.remove(item);
    print("Removed item: ${item.name}");
  }

  void clearForm() {
    customerNameController.clear();
    addressController.clear();
    phoneController.clear();
    orderNotesController.clear();
    orderItems.clear();
    print("Form cleared");
  }
}
