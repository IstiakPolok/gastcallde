import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/Subscription/SubscriptionPlansScreen.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:gastcallde/feature/calls/screens/callScreen.dart';
import 'package:gastcallde/feature/customers/screens/customerSCreen.dart';
import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';
import 'package:gastcallde/feature/menuManagement/screens/menuManagement.dart';
import 'package:gastcallde/feature/orderManagment/orderManagmentscreen.dart';
import 'package:gastcallde/feature/reservastion/screens/reservationScreen.dart';
import 'package:gastcallde/feature/setting/screens/settingScreen.dart';

class SidebarItemData {
  final String label;
  final String svgAsset;
  final Widget page;

  SidebarItemData({
    required this.label,
    required this.svgAsset,
    required this.page,
  });
}

class CustomSidebar extends StatefulWidget {
  const CustomSidebar({Key? key}) : super(key: key);

  @override
  _CustomSidebarState createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  int selectedIndex = 0;
  final subscriptionController = Get.put(SubscriptionCountController());

  final List<SidebarItemData> _items = [
    SidebarItemData(
      label: 'Overview',
      svgAsset: 'assets/icons/svg/1.svg',
      page: Dashboard(),
    ),
    SidebarItemData(
      label: 'Calls',
      svgAsset: 'assets/icons/svg/2.svg',
      page: callScreen(),
    ),
    SidebarItemData(
      label: 'Order Management',
      svgAsset: 'assets/icons/svg/3.svg',
      page: orderManagmentscreen(),
    ),
    SidebarItemData(
      label: 'Reservation',
      svgAsset: 'assets/icons/svg/4.svg',
      page: ReservationScreen(),
    ),
    SidebarItemData(
      label: 'Menu Management',
      svgAsset: 'assets/icons/svg/5.svg',
      page: menuManagement(),
    ),
    SidebarItemData(
      label: 'Customers',
      svgAsset: 'assets/icons/svg/6.svg',
      page: Customerscreen(),
    ),
    SidebarItemData(
      label: 'Subscription Plans',
      svgAsset: 'assets/icons/svg/8.svg',
      page: SubscriptionPlans(),
    ),
    SidebarItemData(
      label: 'Settings',
      svgAsset: 'assets/icons/svg/7.svg',
      page: settingScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Image.asset('assets/icons/logo.png', width: 100),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isSelected = index == selectedIndex;

                      return ListTile(
                        leading: SvgPicture.asset(
                          item.svgAsset,
                          colorFilter: ColorFilter.mode(
                            isSelected ? AppColors.primaryColor : Colors.grey,
                            BlendMode.srcIn,
                          ),
                          width: 24,
                          height: 24,
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.flash_on, size: 20),
                        label: Text(
                          'Upgrade Now',
                          style: TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          _showSubscriptionDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Obx(() {
                        if (subscriptionController.isLoading.value) {
                          return const Text(
                            'Checking subscription...',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return Text(
                            'You have ${subscriptionController.remainingDays.value} days of Free Limit',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }
                      }),
                      SizedBox(height: 10),
                      TextButton.icon(
                        icon: Icon(
                          Icons.logout_sharp,
                          size: 20,
                          color: Color(0xFFE53935),
                        ),
                        label: Text(
                          'Log out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        onPressed: () {
                          SharedPreferencesHelper.logoutUser();
                          Get.to(LoginScreen());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Page content
          Expanded(child: _items[selectedIndex].page),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/logo.png', height: 36),
            SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Color(0xFF18415F),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.error_outline, color: Colors.white, size: 40),
            ),
            SizedBox(height: 20),
            Text(
              'Subscription Needed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your 10 days Free trial limit Reached',
              style: TextStyle(color: AppColors.primaryColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Need to Upgrade your plan',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.flash_on, size: 20),
              label: Text('Upgrade Now', style: TextStyle(fontSize: 12)),
              onPressed: () {
                Get.off(SubscriptionPlans());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Subscription controller
class SubscriptionCountController extends GetxController {
  RxInt remainingDays = 0.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptionStatus();
  }

  Future<void> fetchSubscriptionStatus() async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        remainingDays.value = 0;
        return;
      }

      final response = await http.get(
        Uri.parse("${Urls.baseUrl}/subscription/subscription-status/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final DateTime endDate = DateTime.parse(data["current_period_end"]);
        final int daysLeft = endDate.difference(DateTime.now().toUtc()).inDays;
        remainingDays.value = daysLeft > 0 ? daysLeft : 0;
      } else {
        remainingDays.value = 0;
      }
    } catch (e) {
      remainingDays.value = 0;
    } finally {
      isLoading.value = false;
    }
  }
}
