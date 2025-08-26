import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  // Save selected language

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.language, color: AppColors.primaryColor),
      onPressed: () async {
        if (Get.locale?.languageCode == 'en') {
          Get.updateLocale(const Locale('de', 'DE'));
          await SharedPreferencesHelper.saveLanguage('DE'); // Save Deutsch
          print('Language changed to Deutsch'); // 🔹 Debug print
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Language changed to Deutsch'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          Get.updateLocale(const Locale('en', 'US'));
          await SharedPreferencesHelper.saveLanguage('EN'); // Save English
          print('Language changed to English'); // 🔹 Debug print
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Language changed to English'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}
