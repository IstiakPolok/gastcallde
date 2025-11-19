import 'package:flutter/material.dart';
import 'package:gastcallde/feature/auth/login/screens/loginScreen.dart';
import 'package:get/get.dart';

import '../../core/const/app_colors.dart';
import '../dashboard/screens/dashboard.dart';

class paymentCompleteScreen extends StatelessWidget {
  const paymentCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Get.offAll(Dashboard());
                    debugPrint('Close button pressed!');
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              // GastCall.de logo with text
              Center(child: Image.asset('assets/icons/logo.png', width: 200)),
              const SizedBox(height: 40.0),
              // Checkmark icon
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20.0),
              // Main text
              const Text(
                'Submission Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003D5C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),

              // Sub text 1

              // "Wait for Admin Approval" button
              ElevatedButton(
                onPressed: () {
                  Get.offAll(LoginScreen());
                  debugPrint('Dashboard  button pressed!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFE0F7FA,
                  ), // Light blue background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4C8D9B), // Custom blue text color
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Bottom text
            ],
          ),
        ),
      ),
    );
  }
}
