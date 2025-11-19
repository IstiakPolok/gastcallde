import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/const/app_colors.dart';
import 'RevenueController.dart';

class OrdersBarChart extends StatelessWidget {
  OrdersBarChart({super.key});
  final RevenueController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (controller.last7DaysOrders.reduce((a, b) => a > b ? a : b) + 1)
              .toDouble(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  // ✅ Only show integer values (no decimals)
                  if (value % 1 != 0) return const SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                      return Text('day_1'.tr, style: style);
                    case 1:
                      return Text('day_2'.tr, style: style);
                    case 2:
                      return Text('day_3'.tr, style: style);
                    case 3:
                      return Text('day_4'.tr, style: style);
                    case 4:
                      return Text('day_5'.tr, style: style);
                    case 5:
                      return Text('day_6'.tr, style: style);
                    case 6:
                      return Text('day_7'.tr, style: style);
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barGroups: List.generate(controller.last7DaysOrders.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: controller.last7DaysOrders[index].toDouble(),
                  color: AppColors.primaryColor,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      );
    });
  }
}
