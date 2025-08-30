import 'dart:async';

import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';
import 'package:get/get.dart';

import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../bottom_nav_bar/screen/bottom_nav_bar.dart';
import '../../welcome/view/onBoarding.dart';

class SplashScreenController extends GetxController {
  void checkIsLogin() async {
    Timer(const Duration(seconds: 3), () async {
      String? token = await SharedPreferencesHelper.getAccessToken();

      if (token != null && token.isNotEmpty) {
        Get.offAll(Dashboard());
        print(token);
      } else {
        Get.offAll(OnBoarding());
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    checkIsLogin();
  }
}
