import 'dart:convert';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPlan {
  final int id;
  final String name;
  final String description;
  final double amount;
  final String billingInterval;
  final int intervalCount;
  final String status;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.billingInterval,
    required this.intervalCount,
    required this.status,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      amount: json['amount'],
      billingInterval: json['billing_interval'],
      intervalCount: json['interval_count'],
      status: json['status'],
    );
  }
}

class SubscriptionController extends GetxController {
  var plans = <SubscriptionPlan>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'EN';

    // Build URL with selected language
    final String Url = "${Urls.getSubscriptionPlan}$code";

    final token = await SharedPreferencesHelper.getAccessToken();

    try {
      isLoading(true);

      print("🌐 Fetching Plans from: $Url"); // 🔹 Debug print
      print("🔑 Using Token: $token"); // 🔹 Debug print
      print("🌍 Language Code: $code"); // 🔹 Debug print

      final response = await http.get(
        Uri.parse(Url), // ✅ no hardcoded EN
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print("📡 Response Status: ${response.statusCode}"); // 🔹 Debug print
      print("📦 Response Body: ${response.body}"); // 🔹 Debug print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];

        plans.value = results
            .map((json) => SubscriptionPlan.fromJson(json))
            .toList();

        print("✅ Plans Loaded: ${plans.length}"); // 🔹 Debug print
      } else {
        Get.snackbar("Error", "Failed to fetch plans");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("❌ Exception: $e"); // 🔹 Debug print
    } finally {
      isLoading(false);
    }
  }
}
