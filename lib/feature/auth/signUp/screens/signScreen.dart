import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/auth/signUp/controller/signController.dart';
import 'package:gastcallde/feature/auth/signUp/screens/SubmissionCompleteScreen.dart';
import 'package:gastcallde/feature/auth/signUp/screens/UploadFilesScreen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStepIndex = 0;
  bool _isSubmitting = false;

  File? _selectedImage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _websiteController = TextEditingController();
  final _ibanController = TextEditingController();
  final _taxNumberController = TextEditingController();

  late final List<Map<String, dynamic>> _steps;

  // Initialize the steps inside initState
  @override
  void initState() {
    super.initState();

    // Initialize _steps after the widget is created (instance members are available here)
    _steps = [
      {
        'title': 'account'.tr,
        'icon': Icons.account_box_outlined,
        'content': _buildAccountContent(),
        'progress': 0.25,
      },
      {
        'title': 'restaurant'.tr,
        'icon': Icons.restaurant_outlined,
        'content': _buildRestaurantContent(),
        'progress': 0.50,
      },
      {
        'title': 'financial'.tr,
        'icon': Icons.attach_money_outlined,
        'content': _buildFinancialsContent(),
        'progress': 0.75,
      },

      {
        'title': 'menu'.tr,
        'icon': Icons.menu_book_outlined,
        'content': UploadFilesPage(),
        'progress': 1.0,
      },
    ];
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _nextStep() {
    setState(() {
      if (_currentStepIndex == 0) {
        if (_emailController.text.isEmpty ||
            !_isValidEmail(_emailController.text)) {
          _showError("Please enter a valid email address.");
          return;
        }

        if (_passwordController.text.isEmpty ||
            _confirmPasswordController.text.isEmpty) {
          _showError("Please enter both password fields.");
          return;
        }

        if (_passwordController.text != _confirmPasswordController.text) {
          _showError("Passwords do not match.");
          return;
        }
      } else if (_currentStepIndex == 1) {
        if (_restaurantNameController.text.isEmpty) {
          _showError("Restaurant name is required.");
          return;
        }

        if (_addressController.text.isEmpty) {
          _showError("Restaurant address is required.");
          return;
        }

        if (_phoneNumberController.text.isEmpty) {
          _showError("Phone number is required.");
          return;
        }
      }

      if (_currentStepIndex < _steps.length - 1) {
        _currentStepIndex++;
      }
    });
  }

  bool _submitValid() {
    // reuse your existing checks
    if (_emailController.text.isEmpty ||
        !_isValidEmail(_emailController.text)) {
      _showError("Please enter a valid email address.");
      return false;
    }
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError("Please enter both password fields.");
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match.");
      return false;
    }
    if (_restaurantNameController.text.isEmpty) {
      _showError("Restaurant name is required.");
      return false;
    }
    if (_addressController.text.isEmpty) {
      _showError("Restaurant address is required.");
      return false;
    }
    if (_phoneNumberController.text.isEmpty) {
      _showError("Phone number is required.");
      return false;
    }
    return true;
  }

  Future<bool> _submitRegistration() async {
    try {
      await registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        restaurantName: _restaurantNameController.text,
        address: _addressController.text,
        phoneNumber: _phoneNumberController.text,
        website: _websiteController.text,
        iban: _ibanController.text,
        taxNumber: _taxNumberController.text,
        image: _selectedImage,
      );

      // If no error, return true
      return true;
    } catch (e) {
      _showError("Registration failed: $e");
      return false;
    }
  }

  void _showError(String message) {
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  bool _isValidEmail(String email) {
    final emailRegEx = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegEx.hasMatch(email);
  }

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
                      'Step ${_currentStepIndex + 1} of ${_steps.length}',
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
                        Text(
                          'complete_steps'.tr,
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
                                        // setState(() {
                                        //   _currentStepIndex = i;
                                        // });
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

                        _steps[_currentStepIndex]['content'],

                        const SizedBox(height: 32),

                        // Next Step Button
                        if (_currentStepIndex == _steps.length - 1)
                          ...[
                          
                        ] else
                          ElevatedButton(
                            onPressed: _currentStepIndex == _steps.length - 2
                                ? () async {
                                    if (_isSubmitting) return; // guard
                                    if (!_submitValid())
                                      return; // local validation

                                    setState(() => _isSubmitting = true);
                                    final ok = await registerUser(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      restaurantName:
                                          _restaurantNameController.text,
                                      address: _addressController.text,
                                      phoneNumber: _phoneNumberController.text,
                                      website: _websiteController.text,
                                      iban: _ibanController.text,
                                      taxNumber: _taxNumberController.text,
                                      image: _selectedImage,
                                    );
                                    setState(() => _isSubmitting = false);

                                    if (ok) {
                                      _nextStep(); // move to final step
                                    }
                                  }
                                : _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              _currentStepIndex == _steps.length - 2
                                  ? (_isSubmitting
                                        ? 'please_wait..'.tr
                                        : 'register'.tr)
                                  : 'next_step'.tr,
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

  Widget _buildAccountContent() {
    return Column(
      children: [
        _buildTextField(
          label: 'email'.tr,
          hint: 'enter_email'.tr,
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'password'.tr,
          hint: 'type_password'.tr,
          isPassword: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'confirm_password'.tr,
          hint: 'n293bjksj83hyd',
          isPassword: true,
          controller: _confirmPasswordController,
        ),
      ],
    );
  }

  Widget _buildRestaurantContent() {
    return Column(
      children: [
        _buildTextField(
          label: 'restaurant_name'.tr,
          hint: 'Example Restaurant',
          controller: _restaurantNameController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'restaurant_address'.tr,
          hint: '123 Main Street',
          controller: _addressController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'phone_number'.tr,
          hint: '+1 (555) 555-5555',
          controller: _phoneNumberController,
        ),
        _buildTextField(
          label: 'restaurant_website'.tr,
          hint: 'https://xyz.com',
          controller: _websiteController,
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // --- Image Preview ---
            _selectedImage != null
                ? Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: const Icon(Icons.person_2, color: Colors.white),
                  ),

            const SizedBox(width: 16.0), // spacing between preview & button
            // --- Upload Button ---
            OutlinedButton(
              onPressed: _pickImage, // this updates _selectedImage
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                side: const BorderSide(color: Color(0xFFD9D9D9), width: 2.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: Color(0xFF4C8D9B)),
                  const SizedBox(width: 8.0),
                  Text(
                    _selectedImage != null ? 'Change photo' : 'Upload photo',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF4C8D9B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildMenuContent() {
  //   final List<File> selectedFiles = [];

  //   // Function to pick multiple files (image or pdf)
  //   Future<void> _pickFiles() async {
  //     // Pick multiple files using FilePicker
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       allowMultiple: true, // Allow multiple files
  //       type: FileType.custom,
  //       allowedExtensions: [
  //         'jpg',
  //         'png',
  //         'jpeg',
  //         'pdf',
  //       ], // Specify allowed file types
  //     );

  //     if (result != null) {
  //       Get.snackbar(
  //         'Files picked',
  //         'You have picked ${result.files.length} files',
  //         animationDuration: const Duration(milliseconds: 300),
  //       );
  //       print(
  //         'Files picked: ${result.files.length}',
  //       ); // Debug: Print number of files picked

  //       // Using setState to update the UI immediately
  //       setState(() {
  //         for (var file in result.files) {
  //           String? filePath = file.path;
  //           if (filePath != null) {
  //             selectedFiles.add(File(filePath));
  //             Get.snackbar(
  //               'File Added',
  //               'Added file: ${filePath.split('/').last}',
  //               animationDuration: const Duration(milliseconds: 300),
  //             );
  //             if (kDebugMode) {
  //               print('Added file: ${filePath.split('/').last}');
  //             } // Debug: Print file name
  //           }
  //         }
  //       });
  //     } else {
  //       print('No files selected'); // Debug: Print if no files were selected
  //     }
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Upload Menu (Images or PDF)',
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //           color: Color(0xFF333333),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           border: Border.all(
  //             color: const Color(0xFF999999),
  //             style: BorderStyle.solid,
  //             width: 1.0,
  //           ),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.all(32.0),
  //           child: Column(
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Expanded(
  //                     child: OutlinedButton.icon(
  //                       onPressed: () async {
  //                         await _pickFiles(); // Trigger file picker for images and PDFs
  //                       },
  //                       icon: const Icon(Icons.cloud_upload_outlined),
  //                       label: const Text('Upload Files'),
  //                       style: OutlinedButton.styleFrom(
  //                         foregroundColor: const Color(0xFF333333),
  //                         side: const BorderSide(color: Color(0xFFE0E0E0)),
  //                         padding: const EdgeInsets.symmetric(vertical: 16),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 16),
  //               Text(
  //                 'upload_menu_note'.tr,
  //                 style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
  //               ),
  //               const SizedBox(height: 16),

  //               // Display uploaded files list
  //               const Text(
  //                 'Uploaded Files:',
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xFF333333),
  //                 ),
  //               ),
  //               const SizedBox(height: 8),

  //               // ListView.builder to display selected files
  //               selectedFiles.isNotEmpty
  //                   ? ListView.builder(
  //                       shrinkWrap: true, // Allows it to take minimal space
  //                       physics:
  //                           NeverScrollableScrollPhysics(), // Disable scrolling in this list
  //                       itemCount: selectedFiles.length,
  //                       itemBuilder: (context, index) {
  //                         File file = selectedFiles[index];
  //                         print(
  //                           'Rendering file: ${file.path.split('/').last}',
  //                         ); // Debug: Print file being rendered
  //                         return Padding(
  //                           padding: const EdgeInsets.only(bottom: 8.0),
  //                           child: Row(
  //                             children: [
  //                               Icon(
  //                                 file.path.endsWith('.pdf')
  //                                     ? Icons.picture_as_pdf
  //                                     : Icons.image,
  //                                 color: file.path.endsWith('.pdf')
  //                                     ? Colors.red
  //                                     : Colors.blue,
  //                               ),
  //                               const SizedBox(width: 8),
  //                               Text(
  //                                 file.path
  //                                     .split('/')
  //                                     .last, // Display file name
  //                                 style: const TextStyle(fontSize: 14),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                     )
  //                   : const Text(
  //                       'No files uploaded yet',
  //                     ), // Message if no files are uploaded yet
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildFinancialsContent() {
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
            children: [
              Text(
                'financial_information'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333), // Text color
                ),
              ),
              SizedBox(height: 4),
              Text(
                'skip_alert'.tr,
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
        _buildTextField(
          label: 'iban'.tr,
          hint: 'GB33BUKB20201555555555',
          controller: _ibanController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'tax_number'.tr,
          hint: '01012345-0001',
          controller: _taxNumberController,
        ),
        const SizedBox(height: 32),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: TextButton(
        //     onPressed: () async {
        //       if (_isSubmitting) return;
        //       setState(() => _isSubmitting = true);
        //       final ok = await registerUser(
        //         email: _emailController.text,
        //         password: _passwordController.text,
        //         restaurantName: _restaurantNameController.text,
        //         address: _addressController.text,
        //         phoneNumber: _phoneNumberController.text,
        //         website: _websiteController.text,
        //         iban: _ibanController.text,
        //         taxNumber: _taxNumberController.text,
        //         image: _selectedImage,
        //       );
        //       setState(() => _isSubmitting = false);

        //       if (ok) _nextStep();
        //     },

        //     child: Text('Skip', style: TextStyle(color: Colors.black)),
        //   ),
        // ),
      ],
    );
  }
}

// Helper method to build text fields
Widget _buildTextField({
  required String label,
  required String hint,
  required TextEditingController controller,
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
        controller: controller,
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
