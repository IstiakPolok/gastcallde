import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/Subscription/SubscriptionPlansScreen.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:gastcallde/feature/calls/screens/callScreen.dart';
import 'package:gastcallde/feature/customers/screens/customerSCreen.dart';
import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';
import 'package:gastcallde/feature/delivery/deliveryscreen.dart';
import 'package:gastcallde/feature/menuManagement/screens/menuManagement.dart';
import 'package:gastcallde/feature/orderManagment/orderManagmentscreen.dart';
import 'package:gastcallde/feature/reservastion/screens/reservationScreen.dart';
import 'package:gastcallde/feature/setting/screens/settingScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CustomDrawer extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final subscriptionController = Get.put(SubscriptionCountController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final drawerWidth = isMobile ? screenWidth * 0.75 : 300.0;

    return Drawer(
      backgroundColor: Colors.white,
      width: drawerWidth,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 30.0 : 50.0,
              vertical: 16.0,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: Image.asset('assets/icons/logo.png', fit: BoxFit.contain),
          ),
          _buildDrawerItem(context, 'assets/icons/svg/1.svg', 'Overview', 0),
          _buildDrawerItem(context, 'assets/icons/svg/2.svg', 'Calls', 1),
          _buildDrawerItem(
            context,
            'assets/icons/svg/3.svg',
            'Order Management',
            2,
          ),
          _buildDrawerItem(context, 'assets/icons/svg/4.svg', 'Reservation', 3),
          _buildDrawerItem(
            context,
            'assets/icons/svg/5.svg',
            'Menu Management',
            4,
          ),
          _buildDrawerItem(context, 'assets/icons/svg/6.svg', 'Customers', 5),
          _buildDrawerItem(
            context,
            'assets/icons/svg/9.svg',
            'Delivery Management',
            6,
          ),
          _buildDrawerItem(
            context,
            'assets/icons/svg/8.svg',
            'SubscriptionPlans',
            7,
          ),
          _buildDrawerItem(context, 'assets/icons/svg/7.svg', 'Settings', 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12.0 : 16.0,
                  vertical: 12.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.off(SubscriptionPlans());
                      print('Global Button Pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on, size: isMobile ? 24 : 28),
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          'Upgrade Now',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 8 : 10),
              Obx(() {
                if (subscriptionController.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12.0 : 16.0,
                    ),
                    child: Text(
                      'Checking subscription...',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12.0 : 16.0,
                    ),
                    child: Text(
                      'You have ${subscriptionController.remainingDays.value} days of Free Limit',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 11,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
              }),
              SizedBox(height: isMobile ? 8 : 10),
              TextButton(
                onPressed: () {
                  print('Log out button pressed');
                  SharedPreferencesHelper.logoutUser();
                  Get.to(LoginScreen());
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE53935),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 8 : 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_sharp, size: isMobile ? 24 : 28),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      'Log out',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String svgAssetPath,
    String title,
    int index,
  ) {
    final isSelected = widget.selectedIndex == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final iconSize = isMobile ? 20.0 : 24.0;
    final fontSize = isMobile ? 13.0 : 14.0;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 16.0,
        vertical: isMobile ? 4.0 : 8.0,
      ),
      leading: SvgPicture.asset(
        svgAssetPath,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(
          isSelected ? AppColors.primaryColor : Colors.grey.shade700,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primaryColor : Colors.black87,
          fontSize: fontSize,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        widget.onItemSelected(index);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => _getScreenForIndex(index)),
        );
      },
    );
  }

  // Return the corresponding screen for each index
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return Dashboard();
      case 1:
        return callScreen();
      case 2:
        return orderManagmentscreen();
      case 3:
        return ReservationScreen();
      case 4:
        return menuManagement();
      case 5:
        return Customerscreen();
      case 6:
        return DeliveryScreen();
      case 7:
        return SubscriptionPlans();
      case 8:
        return settingScreen();
      default:
        return Dashboard();
    }
  }
}

class SubscriptionCountController extends GetxController {
  RxInt remainingDays = 0.obs;
  RxBool isLoading = true.obs;

  Future<void> fetchSubscriptionStatus() async {
    try {
      isLoading.value = true;
      print("🔄 Fetching subscription status...");

      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        print("⚠️ No token found. User not authenticated.");
        remainingDays.value = 0;
        return;
      }

      print("🔑 Token fetched: $token");

      final response = await http.get(
        Uri.parse("${Urls.baseUrl}/subscription/subscription-status/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📡 API Response Status: ${response.statusCode}");
      print("📡 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Parsed Data: $data");

        final String endDateStr = data["current_period_end"];
        print("📅 Subscription End Date (raw): $endDateStr");

        final DateTime endDate = DateTime.parse(endDateStr);
        print("📅 Subscription End Date (parsed): $endDate");

        final DateTime now = DateTime.now().toUtc();
        print("⏰ Current UTC Time: $now");

        final int daysLeft = endDate.difference(now).inDays;
        print("📊 Days Left (calculated): $daysLeft");

        remainingDays.value = daysLeft > 0 ? daysLeft : 0;
        print("📊 Remaining Days (final): ${remainingDays.value}");
      } else {
        print("❌ Failed to fetch subscription. Status: ${response.statusCode}");
        remainingDays.value = 0;
      }
    } catch (e) {
      print("🔥 Error fetching subscription: $e");
      remainingDays.value = 0;
    } finally {
      isLoading.value = false;
      print("✅ Finished fetching subscription.");
    }
  }

  @override
  void onInit() {
    super.onInit();
    print("🚀 SubscriptionCountController initialized.");
    fetchSubscriptionStatus();
  }
}
