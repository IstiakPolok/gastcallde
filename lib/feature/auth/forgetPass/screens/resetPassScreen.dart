import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

import '../../../../core/const/app_colors.dart';
import '../../../../core/const/gradientButton.dart';
import '../../signUp/screens/signScreen.dart';
import '../controller/resetPassController.dart';

class resetPassScreen extends StatelessWidget {
  const resetPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resetPassController controller = Get.put(resetPassController());
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80.0),
              Center(
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 50.0),

              Text(
                "Reset Password",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 70),
              Obx(() => TextField(
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: 'Enter Your Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                ),
              )),
              SizedBox(height: 30),
              Obx(() => TextField(
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  floatingLabelStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: 'Enter Your Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                  ),
                ),
              )),





              const SizedBox(height: 30.0),


              GradientButton(
                text: 'Reset',
                onPressed: () {
                  // Handle verification
                },
              ),


            ],
          ),
        ),
      ),
    );
  }
}
