// lib/feature/calls/order_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gastcallde/feature/orderManagment/models/order_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class OrderController extends GetxController {
  // ... (existing lists and methods) ...
  final incomingOrders = <Order>[].obs;
  final inPreparationOrders = <Order>[].obs;
  final outForDeliveryOrders = <Order>[].obs;
  final completedOrders = <Order>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void fetchOrders() async {
    final url = Uri.parse('${Urls.baseUrl}/owner/my-orders/');
    final token = await SharedPreferencesHelper.getAccessToken();

    debugPrint('🔄 Fetching orders from: $url');
    debugPrint('🔑 Using token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint('✅ Total orders fetched: ${data.length}');

        // Clear previous lists
        incomingOrders.clear();
        inPreparationOrders.clear();
        outForDeliveryOrders.clear();
        completedOrders.clear();

        // Parse and categorize orders
        for (var orderJson in data) {
          final order = Order.fromJson(orderJson);

          debugPrint(
            '📝 Parsing order id=${order.id}, restaurant=${order.restaurant}',
          );

          // Save restaurant ID only if it's not null or empty

          await SharedPreferencesHelper.saveRestaurantId(order.restaurant);

          switch (order.status.toLowerCase() ?? '') {
            case 'incoming':
              incomingOrders.add(order);
              break;
            case 'in_preparation':
              inPreparationOrders.add(order);
              break;
            case 'out_for_delivery':
              outForDeliveryOrders.add(order);
              break;
            case 'completed':
              completedOrders.add(order);
              break;
            default:
              debugPrint('⚠ Unknown status: ${order.status}');
          }
        }

        debugPrint('📊 Orders after categorization:');
        debugPrint('Incoming: ${incomingOrders.length}');
        debugPrint('In Preparation: ${inPreparationOrders.length}');
        debugPrint('Out for Delivery: ${outForDeliveryOrders.length}');
        debugPrint('Completed: ${completedOrders.length}');
      } else {
        debugPrint('❌ Error fetching orders: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to fetch orders (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('🚨 Exception while fetching orders: $e');
      Get.snackbar('Error', 'Something went wrong while fetching orders.');
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    final url = Uri.parse('${Urls.baseUrl}/owner/order/update/$orderId/');
    final token = await SharedPreferencesHelper.getAccessToken();

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"status": newStatus}),
      );

      print('PATCH $url');
      print('Request body: ${jsonEncode({"status": newStatus})}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Order $orderId status updated to $newStatus');
        return true;
      } else {
        print('Failed to update order: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception while updating order: $e');
      return false;
    }
  }
  // void reverseOrderStatus(Order order) {
  //   if (order.status == 'in_preparation') {
  //     inPreparationOrders.remove(order);
  //     addOrder(order);
  //   } else if (order.status == 'out_for_delivery') {
  //     outForDeliveryOrders.remove(order);
  //     moveToPreparation(order);
  //   } else if (order.status == 'completed') {
  //     completedOrders.remove(order);
  //     moveToDelivery(order);
  //   }
  // }

  void reverseOrderStatus(Order order) {
    switch (order.status) {
      case 'in_preparation':
        inPreparationOrders.remove(order);
        moveToIncoming(order);
        break;
      case 'out_for_delivery':
        outForDeliveryOrders.remove(order);
        moveToPreparation(order);
        break;
      case 'completed':
        completedOrders.remove(order);
        moveToDelivery(order);
        break;
    }
  }

  void addOrder(Order order) {
    incomingOrders.add(order);
  }

  // Move order to "in preparation"
  Future<void> moveToPreparation(Order order) async {
    bool success = await updateOrderStatus(order.id, 'in_preparation');
    if (success) {
      incomingOrders.remove(order);
      order.status = 'in_preparation';
      inPreparationOrders.add(order);
    }
  }

  // Move order to "out for delivery"
  Future<void> moveToDelivery(Order order) async {
    bool success = await updateOrderStatus(order.id, 'out_for_delivery');
    if (success) {
      inPreparationOrders.remove(order);
      order.status = 'out_for_delivery';
      outForDeliveryOrders.add(order);
    }
  }

  // Move order to "completed"
  Future<void> moveToCompleted(Order order) async {
    bool success = await updateOrderStatus(order.id, 'completed');
    if (success) {
      outForDeliveryOrders.remove(order);
      order.status = 'completed';
      completedOrders.add(order);
    }
  }

  // Move order back to "incoming" (used for reverse/back button)
  Future<void> moveToIncoming(Order order) async {
    bool success = await updateOrderStatus(order.id, 'incoming');
    if (success) {
      // Remove from wherever it is now
      inPreparationOrders.remove(order);
      outForDeliveryOrders.remove(order);
      completedOrders.remove(order);

      order.status = 'incoming';
      incomingOrders.add(order);
    }
  }

  // New method to delete an order from any list
  void deleteOrder(Order order) {
    if (incomingOrders.contains(order)) {
      incomingOrders.remove(order);
    } else if (inPreparationOrders.contains(order)) {
      inPreparationOrders.remove(order);
    } else if (outForDeliveryOrders.contains(order)) {
      outForDeliveryOrders.remove(order);
    } else if (completedOrders.contains(order)) {
      completedOrders.remove(order);
    }
  }
}
