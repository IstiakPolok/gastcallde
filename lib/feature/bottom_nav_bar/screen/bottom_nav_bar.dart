import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Assuming these imports are correctly set up in your project
// import '../../../core/const/nav_bar_images.dart';
// import '../controller/bottom_nav_bar_controller.dart';

// Placeholder for AppColors if not defined in your project
class AppColors {
  static const Color primaryColor = Color(0xFF4CAF50); // A shade of green
  static const Color bgColor = Colors.white; // Background color
  static const Color navBarBgColor = Color(0xFF4CAF50); // Green background for the nav bar
  static const Color navBarIconColor = Colors.white; // White icons
}

// Placeholder for NavBarImages if not defined in your project
class NavBarImages {
  static const String passchat = 'assets/icons/chat_passive.png'; // Placeholder path
  static const String actchat = 'assets/icons/chat_active.png'; // Placeholder path
  static const String passCalls = 'assets/icons/calls_passive.png'; // Placeholder path
  static const String actCalls = 'assets/icons/calls_active.png'; // Placeholder path
  static const String passCallrec = 'assets/icons/callrec_passive.png'; // Placeholder path
  static const String actCallrec = 'assets/icons/callrec_active.png'; // Placeholder path
  static const String passprofile = 'assets/icons/profile_passive.png'; // Placeholder path
  static const String actprofile = 'assets/icons/profile_active.png'; // Placeholder path

  // Adding placeholders for the new icons based on the image
  static const String videoPassive = 'assets/icons/video_passive.png'; // Placeholder for video icon
  static const String videoActive = 'assets/icons/video_active.png'; // Placeholder for video icon
  static const String documentPassive = 'assets/icons/document_passive.png'; // Placeholder for document icon
  static const String documentActive = 'assets/icons/document_active.png'; // Placeholder for document icon
  static const String gridPassive = 'assets/icons/grid_passive.png'; // Placeholder for grid icon
  static const String gridActive = 'assets/icons/grid_active.png'; // Placeholder for grid icon
  static const String personSearchPassive = 'assets/icons/person_search_passive.png'; // Placeholder for person search icon
  static const String personSearchActive = 'assets/icons/person_search_active.png'; // Placeholder for person search icon
  static const String editNotePassive = 'assets/icons/edit_note_passive.png'; // Placeholder for edit note icon
  static const String editNoteActive = 'assets/icons/edit_note_active.png'; // Placeholder for edit note icon
}


// Placeholder for BottomNavbarController if not defined in your project
class BottomNavbarController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}


class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final BottomNavbarController controller = Get.put(BottomNavbarController());

  // Define the pages for each tab
  final List<Widget> pages = [
    Container(color: Colors.red), // Placeholder for Video Screen
    Container(color: Colors.grey), // Placeholder for Document Screen
    Container(color: Colors.blueGrey), // Placeholder for Grid Screen
    Container(color: Colors.blue), // Placeholder for Person Search Screen
    Container(color: Colors.purple), // Placeholder for Note/Edit Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Ensure the scaffold background is transparent
      extendBody: true, // Extend body to allow content to overlap the transparent parts
      body: Obx(() {
        // Listen to changes in the selected index of the bottom navigation
        return pages[controller.currentIndex.value];
      }),
      bottomNavigationBar: Container(
        height: 80, // Height of the bottom navigation bar
        decoration: BoxDecoration(
          color: AppColors.navBarBgColor, // Green background for the nav bar
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25), // Rounded corners as in the image
            topRight: Radius.circular(25),
            bottomLeft: Radius.circular(25), // Added for full pill shape
            bottomRight: Radius.circular(25), // Added for full pill shape
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 5), // Shadow for depth
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Margin from edges
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10), // Adjust vertical padding for icon alignment
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                iconData: Icons.play_circle_fill, // Video Icon
                index: 0,
              ),
              _buildNavItem(
                iconData: Icons.description, // Document Icon
                index: 1,
              ),
              _buildNavItem(
                iconData: Icons.apps, // Grid Icon
                index: 2,
              ),
              _buildNavItem(
                iconData: Icons.person_search, // Person Search Icon
                index: 3,
              ),
              _buildNavItem(
                iconData: Icons.edit_note, // Note/Edit Icon
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData iconData,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        controller.changeIndex(index);
      },
      child: Obx(() {
        final isSelected = controller.currentIndex.value == index;
        return Icon(
          iconData,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7), // White for selected, slightly transparent for unselected
          size: 30, // Set the desired size
        );
      }),
    );
  }
}
