import 'package:flutter/material.dart';
import 'package:gastcallde/core/global_widegts/custom_button.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/const/app_colors.dart';

class signScreen extends StatelessWidget {
  const signScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // You'd typically use a stateful widget or a state management solution (like GetX) for this,
    // but for a stateless widget, a ValueNotifier can be used for a single-property state.
    final RxBool isPasswordVisible = false.obs;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? 600
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
                    'Register',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request for restaurant dashboard',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  _buildTextField('Restaurant Name', 'Enter restaurant name'),
                  _buildTextField('Email address', 'Enter your email'),
                  _buildTextField('Phone number', 'Enter your phone number'),

                  // Password Field with Visibility Toggle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => TextFormField(
                      obscureText: !isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: 'Type password',
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

                  // Checkbox
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (bool? value) {}),
                      Expanded(
                        child: Text(
                          'I agree with all terms & conditions',
                          style: GoogleFonts.inter(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign up button
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 600
                        ? 300
                        : double.infinity,
                    child: CustomButton(
                      title: "Sign up",
                      onPress: () {
                        Get.to(LoginScreen());
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider "Or"
                  // Center(child: Text('Or', style: GoogleFonts.inter())),
                  // const SizedBox(height: 24),

                  // // Social login buttons
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildSocialButton(
                  //         icon: FontAwesomeIcons.google,
                  //         text: 'Sign in with Google',
                  //         onPressed: () {},
                  //       ),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Expanded(
                  //       child: _buildSocialButton(
                  //         icon: FontAwesomeIcons.apple,
                  //         text: 'Sign in with Apple',
                  //         onPressed: () {},
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 24),

                  // "Have an account? Log In"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Have an account?',
                        style: TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.offAll(LoginScreen());
                        },
                        child: Text(
                          'Log In',
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
