import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/calls/screens/callScreen.dart';
import 'package:gastcallde/feature/customers/screens/customerSCreen.dart';
import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';
import 'package:gastcallde/feature/menuManagement/screens/menuManagement.dart';
import 'package:gastcallde/feature/orderManagment/orderManagmentscreen.dart';
import 'package:gastcallde/feature/reservastion/screens/reservationScreen.dart';
import 'package:gastcallde/feature/setting/screens/settingScreen.dart';

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
    return SingleChildScrollView(
      child: NavigationRail(
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
            'assets/icons/svg/7.svg',
            'Settings',
            selectedIndex == 6,
          ),
        ],
      ),
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
      case 6:
        return settingScreen();

      default:
        return Center(child: Container(color: Colors.green));
    }
  }
}
