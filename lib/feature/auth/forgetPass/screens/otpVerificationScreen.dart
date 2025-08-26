import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastcallde/core/global_widegts/custom_button.dart';
import 'package:gastcallde/feature/auth/forgetPass/controller/OtpVerificationController.dart';
import 'package:gastcallde/feature/auth/forgetPass/screens/resetPassScreen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

import '../../../../core/const/app_colors.dart';

class otpVerificationScreen extends StatelessWidget {
  final OtpVerificationController controller = Get.put(
    OtpVerificationController(),
  );
  otpVerificationScreen({super.key});

  final String email = Get.arguments;

  // OTP variable to store the entered OTP
  String otp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    'to_catch_you_follow_the_process'.tr,
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 60,
                    child: PinInputTextField(
                      pinLength: 4,
                      decoration: BoxLooseDecoration(
                        strokeColorBuilder: PinListenColorBuilder(
                          Colors.grey,
                          AppColors.primaryColor,
                        ),
                        radius: Radius.circular(4),
                        strokeWidth: 1,
                        gapSpace: 40,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        otp = value; // Update OTP when value changes
                      },
                      onSubmit: (pin) {
                        print('Entered PIN: $pin');
                        _verifyOtp(pin); // Verify OTP when submitted
                      },
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  /// Verify Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 600
                        ? 300
                        : double.infinity,
                    child: CustomButton(
                      title: "verify_otp".tr,
                      onPress: () {
                        if (otp.isEmpty) {
                          Get.snackbar(
                            "error".tr,
                            "please_enter_otp".tr,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          _verifyOtp(otp); // Trigger OTP verification
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'didnt_get_otp'.tr,
                        style: GoogleFonts.roboto(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _resendOtp();
                        },
                        child: Text(
                          'resend'.tr,
                          style: GoogleFonts.roboto(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
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

  // Verify OTP by calling controller's verifyOtp method
  void _verifyOtp(String otp) {
    print('Entered OTP: $otp');
    controller.verifyOtp(email, otp); // Pass email and OTP to the controller
  }

  // Resend OTP by calling controller's resendOtp method
  void _resendOtp() {
    controller.resendOtp(email); // Pass email to resend OTP
  }
}
