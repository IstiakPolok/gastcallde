import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:gastcallde/feature/auth/signUp/screens/signScreen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:slide_to_act/slide_to_act.dart';

class onBoardind extends StatelessWidget {
  const onBoardind({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<SlideActionState> key = GlobalKey();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image

          // Centered logo
          Center(
            child: Image.asset(
              'assets/icons/logo.png',
              width: 200,
              height: 200,
            ),
          ),

          // SlideAction with bouncy entry using TweenAnimationBuilder
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                curve: Curves.elasticOut, // Bouncy effect
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: SlideAction(
                    key: key,
                    onSubmit: () {
                      Get.to(LoginScreen());
                      key.currentState!.reset();
                    },
                    height: 80,
                    borderRadius: 40,
                    elevation: 0,
                    innerColor: AppColors.primaryColor,
                    outerColor: Colors.white.withOpacity(0.3),
                    sliderButtonIcon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 80),
                        Text(
                          'Lets Go',
                          style: GoogleFonts.philosopher(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: AppColors.primaryColor.withOpacity(0.2),
                          size: 30,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: AppColors.primaryColor.withOpacity(0.5),
                          size: 32,
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: AppColors.primaryColor,
                          size: 35,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
