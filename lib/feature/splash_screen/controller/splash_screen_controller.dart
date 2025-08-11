import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../bottom_nav_bar/screen/bottom_nav_bar.dart';
import '../../welcome/view/onBoarding.dart';

class SplashScreenController extends GetxController {
  void checkIsLogin() async {
    Timer(const Duration(seconds: 3), () async {
      // Check if the token exists in shared preferences
      String? token = await SharedPreferencesHelper.getAccessToken();

      // If token exists, the user is logged in
      if (token != null && token.isNotEmpty) {
        // Redirect to the main screen (e.g., Bottom Navbar or Home)
        Get.offAll(BottomNavbar());
      } else {
        // Redirect to the Welcome Screen if no token is found
        Get.offAll(onBoardind());
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    checkIsLogin();
  }
}
