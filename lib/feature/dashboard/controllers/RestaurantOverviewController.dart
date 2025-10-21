import 'dart:convert';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class RevenueOverviewController extends GetxController {
  var totalOrders = 0.obs;
  var totalRevenue = 0.0.obs;
  var totalRevenueOrder = 0.0.obs; // revenue from orders
  var numberOfNewCustomers = 0.obs;
  var numberOfReturnCustomers = 0.obs;
  var totalNumberOfReservations = 0.obs;
  var totalReservationGuests = 0.obs;
  var numberOfNewReservations = 0.obs;
  var numberOfReturningReservations = 0.obs;
  var averageOrderValue = 0.0.obs;

  // New fields
  var newCustomerOrderRevenue = 0.0.obs;
  var returningCustomerOrderRevenue = 0.0.obs;
  var newCustomerOrderPercentage = 0.0.obs;
  var returningCustomerOrderPercentage = 0.0.obs;
  var newCustomerReservationPercentage = 0.0.obs;
  var returningCustomerReservationPercentage = 0.0.obs;

  Future<void> fetchStats({DateTime? startDate, DateTime? endDate}) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final String urlString = (startDate != null && endDate != null)
          ? '${Urls.baseUrl}/owner/stats/?start_date=${startDate.toIso8601String().split("T")[0]}&end_date=${endDate.toIso8601String().split("T")[0]}'
          : '${Urls.baseUrl}/owner/stats/';
      final url = Uri.parse(urlString);
      print(url);

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Core stats
        totalOrders.value = (data['total_orders'] ?? 0).toInt();
        totalRevenue.value = (data['revenus_from_orders'] ?? 0).toDouble();
        totalRevenueOrder.value = (data['revenus_from_orders'] ?? 0).toDouble();
        numberOfNewCustomers.value =
            (data['number_of_new_customer_orders'] ?? 0).toInt();
        numberOfReturnCustomers.value =
            (data['number_of_returning_customer_orders'] ?? 0).toInt();
        totalNumberOfReservations.value = (data['number_of_reservations'] ?? 0)
            .toInt();
        totalReservationGuests.value =
            (data['number_of_reservation_guests'] ?? 0).toInt();
        numberOfNewReservations.value =
            (data['number_of_new_customer_reservations'] ?? 0).toInt();
        numberOfReturningReservations.value =
            (data['number_of_returning_customer_reservations'] ?? 0).toInt();
        averageOrderValue.value = (data['average_order_value'] ?? 0.0)
            .toDouble();

        // Additional fields
        newCustomerOrderRevenue.value =
            (data['new_customer_order_revenue'] ?? 0.0).toDouble();
        returningCustomerOrderRevenue.value =
            (data['returning_customer_order_revenue'] ?? 0.0).toDouble();
        newCustomerOrderPercentage.value =
            (data['new_customer_order_percentage'] ?? 0.0).toDouble();
        returningCustomerOrderPercentage.value =
            (data['returning_customer_order_percentage'] ?? 0.0).toDouble();
        newCustomerReservationPercentage.value =
            (data['new_customer_reservation_percentage'] ?? 0.0).toDouble();
        returningCustomerReservationPercentage.value =
            (data['returning_customer_reservation_percentage'] ?? 0.0)
                .toDouble();

        // ✅ Debug print
        print('--- Revenue Stats ---');
        print('Total Orders: ${totalOrders.value}');
        print('Total Revenue: ${totalRevenue.value}');
        print('Revenue from Orders: ${totalRevenueOrder.value}');
        print('Average Order Value: ${averageOrderValue.value}');
        print('New Customer Orders: ${numberOfNewCustomers.value}');
        print('Returning Customer Orders: ${numberOfReturnCustomers.value}');
        print('Total Reservations: ${totalNumberOfReservations.value}');
        print('Total Reservation Guests: ${totalReservationGuests.value}');
        print('New Customer Reservations: ${numberOfNewReservations.value}');
        print(
          'Returning Customer Reservations: ${numberOfReturningReservations.value}',
        );
        print('New Customer Order Revenue: ${newCustomerOrderRevenue.value}');
        print(
          'Returning Customer Order Revenue: ${returningCustomerOrderRevenue.value}',
        );
        print('New Customer Order %: ${newCustomerOrderPercentage.value}');
        print(
          'Returning Customer Order %: ${returningCustomerOrderPercentage.value}',
        );
        print(
          'New Customer Reservation %: ${newCustomerReservationPercentage.value}',
        );
        print(
          'Returning Customer Reservation %: ${returningCustomerReservationPercentage.value}',
        );
        print('--------------------');
      } else {
        print('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }
}
