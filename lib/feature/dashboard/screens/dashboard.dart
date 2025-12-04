import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/dashboard/widgets/RestaurantOverview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/global_widegts/LanguageToggleWidget.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double mobileBreakpoint = 600;
    const double tabletBreakpoint = 1024;

    final isMobile = screenWidth < mobileBreakpoint;
    final isTablet =
        screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'restaurant_overview'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'live_overview'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  LanguageToggleButton(),
                ],
              ),
            )
          : null,
      drawer: isMobile
          ? ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return CustomDrawer(
                  selectedIndex: 0,
                  onItemSelected: (index) {
                    _selectedIndexNotifier.value = index;
                  },
                );
              },
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return CustomNavigationRail(
                    selectedIndex: 0,
                    onDestinationSelected: (index) {
                      _selectedIndexNotifier.value = index;
                    },
                  );
                },
              ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return RestaurantOverviewPage();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
