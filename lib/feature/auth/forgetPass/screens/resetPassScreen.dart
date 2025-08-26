import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/custom_button.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/const/app_colors.dart';
import '../controller/resetPassController.dart';

class resetPassScreen extends StatelessWidget {
  resetPassScreen({super.key});
  final RxBool isPasswordVisible = false.obs;
  final String email = Get.arguments;

  final resetPassController controller = Get.put(resetPassController());

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final resetPassController controller = Get.put(resetPassController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 600
                ? 500
                : double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32,
              ),
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
                    'reset_password'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'enter_new_password'.tr,
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Password Field with Visibility Toggle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'enter_new_password_label'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => TextFormField(
                      controller: newPasswordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: 'enter_new_password_hint'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ), // Active color
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            isPasswordVisible.value = !isPasswordVisible.value;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'confirm_new_password_label'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: 'confirm_new_password_hint'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ), // Active color
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            controller.isPasswordVisible.value =
                                !controller.isPasswordVisible.value;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Checkbox

                  // Sign up button
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 600
                        ? 300
                        : double.infinity,
                    child: CustomButton(
                      title: "done".tr,
                      onPress: () {
                        controller.resetPasswordApi(
                          email,
                          newPasswordController.text,
                          confirmPasswordController.text,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "Have an account? Log In"
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
}
