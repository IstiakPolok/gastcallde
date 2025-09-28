import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network_caller/endpoints.dart';

class RevenueController extends GetxController {
  RxList<double> last7DaysRevenue = List.filled(7, 0.0).obs;
  RxList<int> last7DaysOrders = List.filled(7, 0).obs;
  RxBool isLoading = true.obs;
  RxDouble totalRevenue = 0.0.obs; // total revenue
  RxInt totalOrders = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRevenueStats();
  }

  Future<void> fetchRevenueStats() async {
    isLoading.value = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      isLoading.value = false;
      Get.snackbar('Error', 'No token found');
      return;
    }

    final url = Uri.parse('${Urls.baseUrl}/owner/restaurant/order-stats/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        totalRevenue.value = (data["status"]["total_revenue"] as num)
            .toDouble();
        totalOrders.value = (data["status"]["total_orders"] as num).toInt();

        final revenueList = data['last_7_days_revenue'] as List;
        final ordersList = data['last_7_days_orders'] as List;

        // Map revenue to double, preserving day7 → day1 order
        last7DaysRevenue.value = revenueList
            .map((dayMap) => (dayMap.values.first as num).toDouble())
            .toList()
            .reversed
            .toList();

        // Map orders to int, preserving day7 → day1 order
        last7DaysOrders.value = ordersList
            .map((dayMap) => (dayMap.values.first as num).toInt())
            .toList()
            .reversed
            .toList();

        print('Total Revenue: $totalRevenue');
        print('Total Orders: $totalOrders');
      } else {
        Get.snackbar('Error', 'Failed to fetch revenue stats');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
