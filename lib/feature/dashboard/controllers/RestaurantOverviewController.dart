import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantOverviewController extends GetxController {
  final String baseUrl = "https://your-api.com"; // Replace with actual baseUrl

  RxDouble totalRevenue = 0.0.obs;
  RxInt totalOrders = 0.obs;
  RxList<double> revenueTrend = <double>[].obs;
  RxList<int> ordersTrend = <int>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrderStats();
  }

  Future<void> fetchOrderStats() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/owner/restaurant/order-stats/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        totalRevenue.value = (data['status']['total_revenue'] as num)
            .toDouble();
        totalOrders.value = (data['status']['total_orders'] as num).toInt();

        revenueTrend.value = (data['last_7_days_revenue'] as List)
            .map((item) => (item.values.first as num).toDouble())
            .toList();

        ordersTrend.value = (data['last_7_days_orders'] as List)
            .map((item) => (item.values.first as num).toInt())
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch stats');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
