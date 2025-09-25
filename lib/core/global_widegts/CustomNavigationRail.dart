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

class CustomNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NavigationRail(
          backgroundColor: Colors.white,
          //elevation: 0,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            onDestinationSelected(index);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => _getScreenForIndex(index)),
            );
          },
          leading: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
            child: Image.asset('assets/icons/logo.png', width: 100),
          ),
          labelType: NavigationRailLabelType.all,
          destinations: [
            _buildDestination(
              'assets/icons/svg/1.svg',
              'Overview',
              selectedIndex == 0,
            ),
            _buildDestination(
              'assets/icons/svg/2.svg',
              'Calls',
              selectedIndex == 1,
            ),
            _buildDestination(
              'assets/icons/svg/3.svg',
              'Order Management',
              selectedIndex == 2,
            ),
            _buildDestination(
              'assets/icons/svg/4.svg',
              'Reservation',
              selectedIndex == 3,
            ),
            _buildDestination(
              'assets/icons/svg/5.svg',
              'Menu Management',
              selectedIndex == 4,
            ),
            _buildDestination(
              'assets/icons/svg/6.svg',
              'Customers',
              selectedIndex == 5,
            ),
            _buildDestination(
              'assets/icons/svg/8.svg',
              'Subscription Plans',
              selectedIndex == 6,
            ),
            _buildDestination(
              'assets/icons/svg/7.svg',
              'Settings',
              selectedIndex == 7,
            ),
          ],
        ),
        Positioned(
          bottom: 20, // Distance from the bottom of the screen
          left: 0, // Align the button to the left of the screen
          right: 0, // Allow the button to span the width
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showSubscriptionDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(Icons.flash_on, size: 28),

                        const Text(
                          'Upgrage Now', // Text for the global button
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
          ),
        ),
      ],
    );
  }

  NavigationRailDestination _buildDestination(
    String assetPath,
    String label,
    bool isSelected,
  ) {
    return NavigationRailDestination(
      icon: SvgPicture.asset(
        assetPath,
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        width: 24,
        height: 24,
      ),
      selectedIcon: SvgPicture.asset(
        assetPath,
        colorFilter: const ColorFilter.mode(
          AppColors.primaryColor,
          BlendMode.srcIn,
        ),
        width: 24,
        height: 24,
      ),
      label: Text(label),
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
        return Center(child: Container(color: Colors.green));
    }
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
                      // Handle "Upgrade Now" logic here
                      Navigator.of(context).pop();
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
