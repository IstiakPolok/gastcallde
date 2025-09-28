import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gastcallde/core/const/app_colors.dart';
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
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/logo.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Text(
                ' ',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
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
            'assets/icons/svg/8.svg',
            'SubscriptionPlans',
            6,
          ),
          _buildDrawerItem(context, 'assets/icons/svg/7.svg', 'Settings', 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double
                        .infinity, // Makes the button take all available width
                    child: ElevatedButton(
                      onPressed: () {
                        Get.off(SubscriptionPlans());
                        print('Global Button Pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center icon + text
                        mainAxisSize: MainAxisSize.min, // Only shrink to fit
                        children: const [
                          Icon(Icons.flash_on, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              const Text(
                'You have 5 days of Free Limit',
                style: TextStyle(fontSize: 11, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  print('Log out button pressed');
                  SharedPreferencesHelper.logoutUser();
                  Get.to(LoginScreen());
                  print('Log out button pressed');
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(
                    0xFFE53935,
                  ), // Red color for the icon and text
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arrow icon
                    Icon(Icons.logout_sharp, size: 28),
                    SizedBox(width: 8),
                    // "Log out" text
                    Text(
                      'Log out',
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
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: SvgPicture.asset(
        svgAssetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isSelected ? Colors.teal : Colors.black,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.teal : Colors.black),
      ),
      selected: isSelected,
      onTap: () {
        onItemSelected(index);
        // Navigate to the corresponding screen
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
      case 7:
        return settingScreen();
      case 6:
        return SubscriptionPlans();

      default:
        return Dashboard();
    }
  }
}
