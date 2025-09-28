import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class CallsLineChart extends StatelessWidget {
  final MonthlyStatsController controller = Get.put(MonthlyStatsController());

  CallsLineChart({super.key}) {
    controller.fetchMonthlyStats(); // fetch data when chart is created
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return LineChart(
        LineChartData(
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY:
              (controller.orderData + controller.reservationData).reduce(
                (a, b) => a > b ? a : b,
              ) +
              50, // adjust maxY dynamically
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    color: Color(0xff68737d),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  );

                  const months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  if (value.toInt() >= 0 && value.toInt() < 12) {
                    return Text(months[value.toInt()].tr, style: style);
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                controller.orderData.length,
                (index) =>
                    FlSpot(index.toDouble(), controller.orderData[index]),
              ),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
            LineChartBarData(
              spots: List.generate(
                controller.reservationData.length,
                (index) =>
                    FlSpot(index.toDouble(), controller.reservationData[index]),
              ),
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      );
    });
  }
}

class MonthlyStatsController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<double> orderData = List.filled(12, 0.0).obs;
  RxList<double> reservationData = List.filled(12, 0.0).obs;

  Future<void> fetchMonthlyStats() async {
    try {
      isLoading.value = true;

      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found");
        return;
      }

      final url = Uri.parse("${Urls.baseUrl}/owner/restaurant/monthly-stats/");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orders = data['order'] as List;
        final reservations = data['reservation'] as List;

        orderData.value = RxList<double>.from(
          orders.map<double>(
            (e) => double.tryParse(e.values.first.toString()) ?? 0.0,
          ),
        );

        reservationData.value = RxList<double>.from(
          reservations.map<double>(
            (e) => double.tryParse(e.values.first.toString()) ?? 0.0,
          ),
        );
      } else {
        Get.snackbar("Error", "Failed to fetch monthly stats");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
