import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStepIndex = 0;

  // A list of all the steps in the registration process
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Account',
      'icon': Icons.account_box_outlined,
      'content': _buildAccountContent(),
      'progress': 0.25,
    },
    {
      'title': 'Restaurant',
      'icon': Icons.restaurant_outlined,
      'content': _buildRestaurantContent(),
      'progress': 0.50,
    },
    {
      'title': 'Menu',
      'icon': Icons.menu_book_outlined,
      'content': _buildMenuContent(),
      'progress': 0.75,
    },
    {
      'title': 'Financials',
      'icon': Icons.attach_money_outlined,
      'content': _buildFinancialsContent(),
      'progress': 1.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/icons/logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 32),

                // Title - Localize this text
                Text(
                  'join_platform'.tr,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'register_progress'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Text(
                      'step'.trArgs([
                        (_currentStepIndex + 1).toString(),
                        _steps.length.toString(),
                      ]),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _steps[_currentStepIndex]['progress'],
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 24),

                // Main Registration Card
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFFE0E0E0), // light gray border
                      width: 1,
                    ),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Title and Subtitle (dynamic based on step)
                        Text(
                          '${_steps[_currentStepIndex]['title']} Registration',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Complete all steps to get started with your free trial',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tabs/Steps
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int i = 0; i < _steps.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _currentStepIndex = i;
                                        });
                                      },
                                      child: _StepTab(
                                        icon: _steps[i]['icon'],
                                        text: _steps[i]['title'],
                                        isSelected: i == _currentStepIndex,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Dynamic content for the current step
                        _steps[_currentStepIndex]['content'],

                        const SizedBox(height: 32),

                        // Next Step Button
                        ElevatedButton(
                          onPressed: () {
                            if (_currentStepIndex < _steps.length - 1) {
                              setState(() {
                                _currentStepIndex++;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _currentStepIndex < _steps.length - 1
                                ? 'Next Step'
                                : 'Finish',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Static Helper methods to build content for each step ---

  static Widget _buildAccountContent() {
    return Column(
      children: [
        _buildTextField(label: 'Email Address *', hint: 'User2025@gmail.com'),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Password *',
          hint: 'User2025@gmail.com',
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Confirm Password *',
          hint: 'n293bjksj83hyd',
          isPassword: true,
        ),
      ],
    );
  }

  static Widget _buildRestaurantContent() {
    return Column(
      children: [
        _buildTextField(label: 'Restaurant Name *', hint: 'Example Restaurant'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Restaurant Address *', hint: '123 Main Street'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Phone Number *', hint: '+1 (555) 555-5555'),
        _buildTextField(
          label: 'Restaurant Website',
          hint: 'https://ywedyudvs.com',
        ),
      ],
    );
  }

  static Widget _buildMenuContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload menu (File or Photo)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF999999),
              style: BorderStyle.solid,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles();

                          if (result != null) {
                            // You can get the picked file path
                            String? filePath = result.files.single.path;
                            print('Selected file: $filePath');
                          } else {
                            print('File picking cancelled.');
                          }
                        },
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Upload File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF333333),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                          );

                          if (image != null) {
                            File imageFile = File(image.path);
                            print('Captured image path: ${imageFile.path}');
                            // You can now display or upload the image
                          } else {
                            print('No image captured.');
                          }
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Take Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF333333),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'upload_menu_note'.tr,
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildFinancialsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0), // Padding around the content
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(
              0.1,
            ), // Background color (you can choose any color)
            borderRadius: BorderRadius.circular(
              12,
            ), // Rounded corners (optional)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Financial Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333), // Text color
                ),
              ),
              SizedBox(height: 4),
              Text(
                'You can skip this step and provide your IBAN and tax number after your free trial period.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1EC0B8), // Text color
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        // Row(
        //   children: [
        //     Checkbox(
        //       value: false, // You would manage this with a state variable
        //       onChanged: (bool? newValue) {
        //         // Handle checkbox state change
        //       },
        //       activeColor: AppColors.primaryColor,
        //     ),
        //     const Text(
        //       'Skip for now',
        //       style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
        //     ),
        //   ],
        // ),`
        const SizedBox(height: 16),
        _buildTextField(label: 'IBAN *', hint: 'GB33BUKB20201555555555'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Tax Number *', hint: '01012345-0001'),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () {},

            child: Text('Skip', style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
}

// Helper method to build text fields
Widget _buildTextField({
  required String label,
  required String hint,
  bool isPassword = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF999999)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1EC0B8), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    ],
  );
}

// Custom widget for the step tabs
class _StepTab extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;

  const _StepTab({
    required this.icon,
    required this.text,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.primaryColor)
            : Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFF666666),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primaryColor
                  : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
