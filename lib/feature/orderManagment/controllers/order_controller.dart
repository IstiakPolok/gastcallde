// lib/feature/calls/order_controller.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gastcallde/feature/orderManagment/models/order_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

// Isolate function for parsing orders in background
Future<Map<String, List<Order>>> _parseOrdersInBackground(
  List<dynamic> data,
) async {
  return compute(_parseOrders, data);
}

Map<String, List<Order>> _parseOrders(List<dynamic> data) {
  final Map<String, List<Order>> categorizedOrders = {
    'incoming': [],
    'in_preparation': [],
    'out_for_delivery': [],
    'completed': [],
  };

  for (var orderJson in data) {
    try {
      final order = Order.fromJson(orderJson);
      final status = order.status.toLowerCase();

      if (categorizedOrders.containsKey(status)) {
        categorizedOrders[status]!.add(order);
      }
    } catch (e) {
      debugPrint('Error parsing order: $e');
    }
  }

  return categorizedOrders;
}

class OrderController extends GetxController {
  final incomingOrders = <Order>[].obs;
  final inPreparationOrders = <Order>[].obs;
  final outForDeliveryOrders = <Order>[].obs;
  final completedOrders = <Order>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void fetchOrders({DateTime? date}) async {
    isLoading.value = true;

    // Format date as YYYY-MM-DD
    String dateParam = '';
    if (date != null) {
      dateParam =
          '?date=${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    final url = Uri.parse('${Urls.baseUrl}/owner/my-orders/$dateParam');
    final token = await SharedPreferencesHelper.getAccessToken();

    debugPrint('🔄 Fetching orders from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        debugPrint('✅ Total orders fetched: ${data.length}');

        // Parse orders in background thread to avoid blocking UI
        final categorizedOrders = await _parseOrdersInBackground(data);

        // Clear and update lists on main thread
        incomingOrders.value = categorizedOrders['incoming']!;
        inPreparationOrders.value = categorizedOrders['in_preparation']!;
        outForDeliveryOrders.value = categorizedOrders['out_for_delivery']!;
        completedOrders.value = categorizedOrders['completed']!;

        // Save restaurant ID from first order if available
        if (data.isNotEmpty && data[0]['restaurant'] != null) {
          await SharedPreferencesHelper.saveRestaurantId(data[0]['restaurant']);
        }

        debugPrint('📊 Orders categorized:');
        debugPrint('Incoming: ${incomingOrders.length}');
        debugPrint('In Preparation: ${inPreparationOrders.length}');
        debugPrint('Out for Delivery: ${outForDeliveryOrders.length}');
        debugPrint('Completed: ${completedOrders.length}');
      } else {
        debugPrint('❌ Error fetching orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 Exception while fetching orders: $e');
    } finally {
      isLoading.value = false;
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
