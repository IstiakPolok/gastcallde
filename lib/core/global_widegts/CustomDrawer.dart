import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gastcallde/feature/calls/screens/callScreen.dart';
import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';

import 'package:gastcallde/feature/dashboard/widgets/RestaurantOverview.dart';
import 'package:gastcallde/feature/menuManagement/screens/menuManagement.dart';
import 'package:gastcallde/feature/orderManagment/orderManagmentscreen.dart';
import 'package:gastcallde/feature/reservastion/screens/reservationScreen.dart';

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
          _buildDrawerItem(context, 'assets/icons/svg/7.svg', 'Settings', 6),
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
        return Center(child: Container(color: Colors.purple));
      case 6:
        return Center(child: Container(color: Colors.green));

      default:
        return Dashboard();
    }
  }
}
