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

class CustomNavigationRail extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<CustomNavigationRail> createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends State<CustomNavigationRail> {
  final subscriptionController = Get.put(SubscriptionCountController());
  static bool _persistentExpanded = true;
  bool get _isExpanded => _persistentExpanded;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final logoWidth = isTablet ? 80.0 : 100.0;
    final iconSize = isTablet ? 20.0 : 24.0;

    return Container(
      width: _isExpanded
          ? (isTablet ? 200 : 240)
          : (isTablet ? 56 : 60), // Minimum width when collapsed
      color: Colors.white,
      child: Column(
        children: [
          // Logo and toggle button
          Container(
            color: _isExpanded ? AppColors.primaryColor : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _isExpanded ? 8.0 : 4.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  if (_isExpanded)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.menu_open : Icons.menu,
                          color: _isExpanded
                              ? AppColors.primaryColor
                              : Colors.white,
                          size: iconSize,
                        ),
                        onPressed: () {},
                        tooltip: _isExpanded ? 'Collapse' : 'Expand',
                        padding: EdgeInsets.all(isTablet ? 8.0 : 12.0),
                        constraints: BoxConstraints(
                          minWidth: isTablet ? 36 : 40,
                          minHeight: isTablet ? 36 : 40,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/icons/logo.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.menu_open : Icons.menu,
                        color: _isExpanded
                            ? Colors.white
                            : AppColors.primaryColor,
                        size: iconSize,
                      ),
                      onPressed: () {
                        setState(() {
                          _persistentExpanded = !_persistentExpanded;
                        });
                      },
                      tooltip: _isExpanded ? 'Collapse' : 'Expand',
                      padding: EdgeInsets.all(isTablet ? 8.0 : 12.0),
                      constraints: BoxConstraints(
                        minWidth: isTablet ? 36 : 40,
                        minHeight: isTablet ? 36 : 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 4.0 : 8.0),
              child: Column(
                children: [
                  // Navigation Rail Items
                  IntrinsicHeight(
                    child: NavigationRail(
                      backgroundColor: Colors.white,
                      selectedIndex: widget.selectedIndex,
                      onDestinationSelected: (index) {
                        widget.onDestinationSelected(index);
                        _navigateToScreen(index);
                      },
                      labelType: _isExpanded
                          ? NavigationRailLabelType.all
                          : NavigationRailLabelType.none,
                      minWidth: isTablet ? 56 : 72,
                      minExtendedWidth: isTablet ? 180 : 200,
                      destinations: [
                        _buildDestination(
                          'assets/icons/svg/1.svg',
                          'Overview',
                          widget.selectedIndex == 0,
                        ),
                        _buildDestination(
                          'assets/icons/svg/2.svg',
                          'Calls',
                          widget.selectedIndex == 1,
                        ),
                        _buildDestination(
                          'assets/icons/svg/3.svg',
                          'Order Management',
                          widget.selectedIndex == 2,
                        ),
                        _buildDestination(
                          'assets/icons/svg/4.svg',
                          'Reservation',
                          widget.selectedIndex == 3,
                        ),
                        _buildDestination(
                          'assets/icons/svg/5.svg',
                          'Menu Management',
                          widget.selectedIndex == 4,
                        ),
                        _buildDestination(
                          'assets/icons/svg/6.svg',
                          'Customers',
                          widget.selectedIndex == 5,
                        ),
                        _buildDestination(
                          'assets/icons/svg/9.svg',
                          'Delivery Management',
                          widget.selectedIndex == 6,
                        ),
                        _buildDestination(
                          'assets/icons/svg/8.svg',
                          'Subscription Plans',
                          widget.selectedIndex == 7,
                        ),
                        _buildDestination(
                          'assets/icons/svg/7.svg',
                          'Settings',
                          widget.selectedIndex == 8,
                        ),
                      ],
                    ),
                  ),
                  // Bottom section (after Settings)
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 6.0 : 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.off(SubscriptionPlans());
                              _showSubscriptionDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 6 : 8,
                                horizontal: _isExpanded ? 12 : 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flash_on, size: isTablet ? 18 : 20),
                                if (_isExpanded) ...[
                                  SizedBox(width: isTablet ? 6 : 8),
                                  Flexible(
                                    child: Text(
                                      'Upgrade Now',
                                      style: TextStyle(
                                        fontSize: isTablet ? 10 : 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isTablet ? 8 : 10),
                        if (_isExpanded)
                          Obx(() {
                            if (subscriptionController.isLoading.value) {
                              return Text(
                                'Checking subscription...',
                                style: TextStyle(
                                  fontSize: isTablet ? 10 : 11,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              );
                            } else {
                              return Text(
                                'You have ${subscriptionController.remainingDays.value} days of Free Limit',
                                style: TextStyle(
                                  fontSize: isTablet ? 10 : 11,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              );
                            }
                          }),
                        SizedBox(height: isTablet ? 8 : 10),
                        TextButton(
                          onPressed: () {
                            print('Log out button pressed');
                            SharedPreferencesHelper.logoutUser();
                            Get.to(LoginScreen());
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFE53935),
                            padding: _isExpanded
                                ? EdgeInsets.symmetric(
                                    horizontal: isTablet ? 8 : 12,
                                    vertical: isTablet ? 6 : 8,
                                  )
                                : EdgeInsets.zero,
                            minimumSize: _isExpanded ? null : Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: _isExpanded
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_sharp,
                                      size: isTablet ? 22 : 24,
                                    ),
                                    SizedBox(width: isTablet ? 6 : 8),
                                    Flexible(
                                      child: Text(
                                        'Log out',
                                        style: TextStyle(
                                          fontSize: isTablet ? 11 : 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : Icon(
                                  Icons.logout_sharp,
                                  size: isTablet ? 22 : 24,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    Widget screen;
    switch (index) {
      case 0:
        screen = Dashboard();
        break;
      case 1:
        screen = callScreen();
        break;
      case 2:
        screen = orderManagmentscreen();
        break;
      case 3:
        screen = ReservationScreen();
        break;
      case 4:
        screen = menuManagement();
        break;
      case 5:
        screen = Customerscreen();
        break;
      case 6:
        screen = DeliveryScreen();
        break;
      case 7:
        screen = SubscriptionPlans();
        break;
      case 8:
        screen = settingScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  NavigationRailDestination _buildDestination(
    String assetPath,
    String label,
    bool isSelected,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final iconSize = isTablet ? 18.0 : 20.0;

    return NavigationRailDestination(
      icon: SvgPicture.asset(
        assetPath,
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        width: iconSize,
        height: iconSize,
      ),
      selectedIcon: SvgPicture.asset(
        assetPath,
        colorFilter: const ColorFilter.mode(
          AppColors.primaryColor,
          BlendMode.srcIn,
        ),
        width: iconSize,
        height: iconSize,
      ),
      label: Text(
        label,
        style: TextStyle(fontSize: isTablet ? 11 : 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: InkWell(
                  //     onTap: () {
                  //       Navigator.of(context).pop();
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.all(4.0),
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Color(0xFFE5E5E5),
                  //       ),
                  //       child: const Icon(
                  //         Icons.close,
                  //         color: Colors.black,
                  //         size: 20.0,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  // Placeholder for the GastCall.de logo
                  // In a real app, you would use your actual SVG asset here.
                  Image.asset('assets/icons/logo.png', height: 36),
                  const SizedBox(height: 30),
                  // Alert icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Color(0xFF18415F),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Subscription Needed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your 10 days Free trial limit Reached',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Need to Upgrade your plan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SubscriptionPlans()),
                      );

                      // Navigator.of(context).pop();
                      print('Upgrade Now tapped!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      elevation: 5,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flash_on, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Upgrade Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
