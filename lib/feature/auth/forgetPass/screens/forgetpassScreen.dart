import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/custom_button.dart';
import 'package:gastcallde/feature/auth/forgetPass/controller/ForgetPasswordController.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/const/app_colors.dart';
import 'otpVerificationScreen.dart';

class forgetpassScreen extends StatelessWidget {
  forgetpassScreen({super.key});
  final RxBool isPasswordVisible = false.obs;
  final ForgetPasswordController controller = Get.put(
    ForgetPasswordController(),
  );
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? 500
                  : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo and Header
                  Center(
                    child: Image.asset(
                      'assets/icons/logo.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Text(
                    'forgot_password'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'to_catch_you_follow_the_process'.tr, // Use translation key
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  _buildTextField(
                    'email_address'.tr,
                    'enter_your_email'.tr,
                  ), // Use translation keys

                  const SizedBox(height: 50),

                  // Send Code button
                  Obx(() {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width > 600
                          ? 300
                          : double.infinity,
                      child: CustomButton(
                        title: controller.isLoading.value
                            ? "sending".tr
                            : "send_code".tr,
                        onPress: () {
                          String email = _emailController.text;
                          if (email.isEmpty) {
                            Get.snackbar(
                              "error".tr, // Use translation key
                              "please_enter_email".tr, // Use translation key
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } else {
                            controller.sendOtp(email); // Call sendOtp method
                          }
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'remember_password'.tr,
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.offAll(LoginScreen());
                        },
                        child: Text(
                          'login'.tr,
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ), // Active color
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
