import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
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
  final emailController = TextEditingController();
  final orderNotesController = TextEditingController();
  final allergyController = TextEditingController();
  final discountTextController = TextEditingController();

  var selectedCategory = 'All'.obs;
  var orderType = 'delivery'.obs; // 'pickup' or 'delivery'
  var selectedDeliveryArea = Rxn<int>(); // Nullable integer
  var isLoadingCustomer = false.obs;
  var countryCode = '+49'.obs;

  Future<void> fetchCustomerByPhone(String selectedCountryCode) async {
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a phone number');
      return;
    }

    try {
      isLoadingCustomer.value = true;
      countryCode.value = selectedCountryCode;
      final token = await SharedPreferencesHelper.getAccessToken();
      final fullPhoneNumber = '$selectedCountryCode${phoneController.text}';
      final url = Uri.parse(
        '${Urls.baseUrl}/owner/customers/',
      ).replace(queryParameters: {'search': fullPhoneNumber});

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isEmpty) {
          Get.snackbar(
            'Info',
            'No customer found with this phone number',
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
          );
          return;
        }

        final customer = data[0];

        // Auto-fill the form fields
        customerNameController.text = customer['customer_name'] ?? '';
        emailController.text = customer['email'] ?? '';
        addressController.text = customer['address'] ?? '';

        Get.snackbar(
          'Success',
          'Customer information loaded successfully',
          backgroundColor: AppColors.primaryColor.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else if (response.statusCode == 404) {
        Get.snackbar(
          'Info',
          'No customer found with this phone number',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to fetch customer information');
      }
    } catch (e) {
      print('Error fetching customer: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoadingCustomer.value = false;
    }
  }

  Future<void> createOrder() async {
    if (orderItems.isEmpty || customerNameController.text.isEmpty) {
      Get.snackbar('Error', 'Please add food items and customer name.');
      print("Order creation failed: Missing required fields");
      return;
    }

    // Validate address for delivery orders
    if (orderType.value == 'delivery' && addressController.text.isEmpty) {
      Get.snackbar('Error', 'Address is required for delivery orders.');
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
            "extras": item.extras,
            "extras_price": item.extrasPrice.toString(),
            "special_instructions": item.specialInstructions,
          };
        }).toList(),
        "email": emailController.text.isNotEmpty ? emailController.text : null,
        "phone": phoneController.text.isNotEmpty
            ? '${countryCode.value}${phoneController.text}'
            : null,
        "order_notes": orderNotesController.text.isNotEmpty
            ? orderNotesController.text
            : null,
        "address": addressController.text.isNotEmpty
            ? addressController.text
            : null,
        "allergy": allergyController.text.isNotEmpty
            ? allergyController.text
            : null,
        "discount_text": discountTextController.text.isNotEmpty
            ? discountTextController.text
            : null,
        "delivery_area": selectedDeliveryArea.value,
        "verified": true,
        "order_type": orderType.value,
      };

      // print("\n📦 ========== ORDER PAYLOAD DEBUG ==========");
      // print("📝 Raw Body Map: $body");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");

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
    emailController.clear();
    orderNotesController.clear();
    allergyController.clear();
    discountTextController.clear();
    orderItems.clear();
    selectedDeliveryArea.value = null;
    orderType.value = 'delivery';
    print("Form cleared");
  }
}
