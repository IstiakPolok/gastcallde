import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'RevenueController.dart';

class RevenueLineChart extends StatelessWidget {
  RevenueLineChart({super.key});
  final RevenueController controller = Get.put(RevenueController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final spots = List.generate(
        controller.last7DaysRevenue.length,
        (index) => FlSpot(index.toDouble(), controller.last7DaysRevenue[index]),
      );

      return LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY:
              (controller.last7DaysRevenue.reduce((a, b) => a > b ? a : b) +
              50),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
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
                  switch (value.toInt()) {
                    case 0:
                      return Text(
                        'day_1'.tr,
                        style: style,
                      ); // Translates "Day 1"
                    case 1:
                      return Text(
                        'day_2'.tr,
                        style: style,
                      ); // Translates "Day 2"
                    case 2:
                      return Text(
                        'day_3'.tr,
                        style: style,
                      ); // Translates "Day 3"
                    case 3:
                      return Text(
                        'day_4'.tr,
                        style: style,
                      ); // Translates "Day 4"
                    case 4:
                      return Text(
                        'day_5'.tr,
                        style: style,
                      ); // Translates "Day 5"
                    case 5:
                      return Text(
                        'day_6'.tr,
                        style: style,
                      ); // Translates "Day 6"
                    case 6:
                      return Text(
                        'day_7'.tr,
                        style: style,
                      ); // Translates "Day 7"
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),
              barWidth: 2,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [Colors.purple.withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
