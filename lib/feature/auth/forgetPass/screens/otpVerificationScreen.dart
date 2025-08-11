import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastcallde/core/global_widegts/custom_button.dart';
import 'package:gastcallde/feature/auth/forgetPass/screens/resetPassScreen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

import '../../../../core/const/app_colors.dart';

class otpVerificationScreen extends StatelessWidget {
  const otpVerificationScreen({super.key});

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
                    'Forgot Password',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To catch you follow the proccess',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 60,
                    // total width for 6 boxes and 5 gaps
                    child: PinInputTextField(
                      pinLength: 6,
                      decoration: BoxLooseDecoration(
                        strokeColorBuilder: PinListenColorBuilder(
                          Colors.grey,
                          AppColors.primaryColor,
                        ),
                        radius: Radius.circular(4),
                        strokeWidth: 1,
                        gapSpace: 10,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                      onChanged: (value) {},
                      onSubmit: (pin) {
                        print('Entered PIN: $pin');
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
                      title: "Send Code",
                      onPress: () {
                        Get.to(resetPassScreen());
                      },
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Don’t Get OTP? ',
                        style: GoogleFonts.roboto(
                          color: Colors.grey[700],
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Resend',
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
}
