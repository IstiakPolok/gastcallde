import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../../core/network_caller/endpoints.dart';
import '../../welcome/view/onBoarding.dart';
import 'package:gastcallde/feature/dashboard/screens/dashboard.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkIsLogin();
  }

  Future<void> _checkIsLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    final accessToken = await SharedPreferencesHelper.getAccessToken();
    final refreshToken = await SharedPreferencesHelper.getRefreshToken();

    if (accessToken?.isNotEmpty == true) {
      if (refreshToken?.isNotEmpty == true &&
          await _refreshAccessToken(refreshToken!)) {
        Get.offAll(() => Dashboard());
      } else {
        Get.offAll(() => OnBoarding());
      }
    } else {
      Get.offAll(() => OnBoarding());
    }
  }

  Future<bool> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(Urls.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'];
        final newRefresh = data['refresh'];
        if (newAccess != null && newRefresh != null) {
          await SharedPreferencesHelper.saveToken(newAccess);
          await SharedPreferencesHelper.saveRefreshToken(newRefresh);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}
