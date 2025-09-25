import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/LanguageToggleWidget.dart';
import 'package:gastcallde/core/global_widegts/custom_button.dart';
import 'package:gastcallde/feature/auth/login/controller/loginController.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/const/app_colors.dart';
import '../../forgetPass/screens/forgetpassScreen.dart';
import '../../signUp/screens/signScreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.put(LoginController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width > 600
                ? 600
                : double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: LanguageToggleButton(),
                  ),
                  Image.asset('assets/icons/logo.png', width: 200, height: 200),
                  Text(
                    'welcome'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('subtitle'.tr, style: GoogleFonts.inter(fontSize: 16)),
                  const SizedBox(height: 32),

                  // Email Field
                  _buildTextField(
                    'email'.tr,
                    'enter_email'.tr,
                    loginController.emailController,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'password'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => TextFormField(
                      controller: loginController.passwordController,
                      obscureText: !loginController.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: 'type_password'.tr,
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
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            loginController.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: loginController.togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.to(() => forgetpassScreen()),
                      child: Text(
                        'forgot_password'.tr,
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: MediaQuery.of(context).size.width > 600
                        ? 300
                        : double.infinity,
                    child: CustomButton(
                      title: "login".tr,
                      onPress: loginController.login, // ✅ No need to pass text
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'signup_question'.tr,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => RegistrationScreen()),
                        child: Text(
                          'signup'.tr,
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
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
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
