import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class RevenueOverviewController extends GetxController {
  RxBool isLoading = false.obs;

  // API Data
  RxDouble totalRevenueOrder = 0.0.obs;
  RxInt totalCalls = 0.obs;
  RxInt totalNumberOfOrders = 0.obs;
  RxInt totalNumberOfReservations = 0.obs;
  RxInt numberOfNewCustomers = 0.obs;
  RxInt numberOfReturnCustomers = 0.obs;
  RxInt totalDurationSeconds = 0.obs;
  RxInt totalCallbackTrack = 0.obs;

  Future<void> fetchStats({int days = 7}) async {
    try {
      isLoading.value = true;
      print("📡 Fetching stats for last $days days...");

      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        print("❌ No token found in SharedPreferences");
        Get.snackbar("Error", "User not authenticated");
        return;
      }

      final url = Uri.parse("${Urls.baseUrl}/owner/stats/?days=$days");
      print("🔗 API URL: $url");
      print("🔑 Using token: $token");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Add your token here
          'Content-Type': 'application/json',
        },
      );

      print("✅ API Status Code: ${response.statusCode}");
      print("📦 Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Decoded Data: $data");

        totalRevenueOrder.value =
            double.tryParse(data['total_revenue_order'].toString()) ?? 0.0;
        totalCalls.value = data['total_calls'] ?? 0;
        totalNumberOfOrders.value = data['total_number_of_orders'] ?? 0;
        totalNumberOfReservations.value =
            data['total_number_of_reservations'] ?? 0;
        numberOfNewCustomers.value = data['number_of_new_customers'] ?? 0;
        numberOfReturnCustomers.value = data['number_of_return_customers'] ?? 0;
        totalDurationSeconds.value = data['total_duration_seconds'] ?? 0;
        totalCallbackTrack.value = data['total_callback_track'] ?? 0;

        // ✅ Print all parsed values
        print("📊 Parsed Stats:");
        print("   • totalRevenueOrder: ${totalRevenueOrder.value}");
        print("   • totalCalls: ${totalCalls.value}");
        print("   • totalNumberOfOrders: ${totalNumberOfOrders.value}");
        print(
          "   • totalNumberOfReservations: ${totalNumberOfReservations.value}",
        );
        print("   • numberOfNewCustomers: ${numberOfNewCustomers.value}");
        print("   • numberOfReturnCustomers: ${numberOfReturnCustomers.value}");
        print("   • totalDurationSeconds: ${totalDurationSeconds.value}");
        print("   • totalCallbackTrack: ${totalCallbackTrack.value}");
      } else {
        print("❌ Failed to fetch stats. Status code: ${response.statusCode}");
        Get.snackbar("Error", "Failed to fetch stats");
      }
    } catch (e, stack) {
      print("🔥 Exception while fetching stats: $e");
      print(stack);
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      print("✅ Done fetching stats.");
    }
  }
}
