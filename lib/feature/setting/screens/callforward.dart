import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:get/get.dart';

import '../controllers/RestaurantSettingsController.dart';

class CallForwardingScreen extends StatefulWidget {
  const CallForwardingScreen({super.key});

  @override
  State<CallForwardingScreen> createState() => _CallForwardingScreenState();
}

class _CallForwardingScreenState extends State<CallForwardingScreen> {
  final RestaurantSettingsController restaurantController = Get.put(
    RestaurantSettingsController(),
  );

  String? _forwardingMode = 'disable_forwarding';
  final TextEditingController _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize phone controller with current value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantController.phoneNumber1.value.isNotEmpty) {
        _phoneController.text = restaurantController.phoneNumber1.value;
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (restaurantController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'call_forwarding'.tr,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'how_to_forward'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'call_forwarding_desc'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Number fields section
              Row(
                children: [
                  Expanded(
                    child: _buildEditableTextField(
                      controller: _phoneController,
                      labelText: 'original_number'.tr,
                      hintText: restaurantController.phoneNumber1.value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      initialValue: restaurantController.twilioNumber.value,
                      labelText: 'ai_assigned_number'.tr,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: restaurantController.twilioNumber.value,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('copied_to_clipboard'.tr)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Forwarding Mode section
              Text(
                'forwarding_mode'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRadioListTile(
                      title: 'always_forward'.tr,
                      value: 'always_forward',
                    ),
                    _buildRadioListTile(
                      title: 'forward_during_opening_hours'.tr,
                      value: 'forward_during_opening_hours',
                    ),
                    _buildRadioListTile(
                      title: 'disable_forwarding'.tr,
                      value: 'disable_forwarding',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              setState(() {
                                _isSaving = true;
                              });

                              final newPhoneNumber = _phoneController.text
                                  .trim();

                              if (newPhoneNumber.isEmpty) {
                                Get.snackbar(
                                  'error'.tr,
                                  'phone_number_empty_error'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                setState(() {
                                  _isSaving = false;
                                });
                                return;
                              }

                              if (_forwardingMode == null) {
                                Get.snackbar(
                                  'error'.tr,
                                  'select_forwarding_mode_error'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                setState(() {
                                  _isSaving = false;
                                });
                                return;
                              }

                              final success = await restaurantController
                                  .updatePhoneNumber(
                                    newPhoneNumber,
                                    _forwardingMode!,
                                  );

                              setState(() {
                                _isSaving = false;
                              });

                              if (success) {
                                Get.snackbar(
                                  'success'.tr,
                                  'settings_updated_success'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.snackbar(
                                  'error'.tr,
                                  'settings_update_failed'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'save'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Expanded(
                  //   child: OutlinedButton(
                  //     onPressed: () {
                  //       // TODO: Test Forwarding
                  //     },
                  //     style: OutlinedButton.styleFrom(
                  //       side: const BorderSide(color: Colors.teal),
                  //       padding: const EdgeInsets.symmetric(vertical: 16),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       'Test Forwarding',
                  //       style: TextStyle(fontSize: 16, color: Colors.teal),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 24),

              // // Callback settings
              // const Text(
              //   'Callback settings',
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.black87,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // const Text(
              //   'Configure how the AI should react to important request during opening hours',
              //   style: TextStyle(fontSize: 14, color: Colors.black54),
              // ),
              // const SizedBox(height: 16),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Expanded(
              //       child: _buildCallbackCard(
              //         icon: Icons.sync_alt,
              //         title: 'Forward immediately',
              //         description:
              //             'For important matters the customer is forward directly to an employee',
              //         number: restaurantController.phoneNumber1.value,
              //         isSwitch: true,
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: _buildCallbackCard(
              //         icon: Icons.calendar_month,
              //         title: 'Schedule callback',
              //         description:
              //             'The AI collects customer data & schedules a callback.',
              //         isSwitch: true,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    required String labelText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            hintText: hintText ?? 'enter_phone_number'.tr,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioListTile({required String title, required String value}) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      value: value,
      groupValue: _forwardingMode,
      onChanged: (String? newValue) {
        setState(() {
          _forwardingMode = newValue;
        });
      },
      activeColor: AppColors.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // Widget _buildCallbackCard({
  //   required IconData icon,
  //   required String title,
  //   required String description,
  //   String? number,
  //   required bool isSwitch,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(16.0),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(8.0),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 5,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Icon(icon, color: Colors.teal),
  //             if (isSwitch)
  //               Switch(
  //                 value: true,
  //                 onChanged: (bool value) {
  //                   // Handle toggle
  //                 },
  //                 activeColor: Colors.teal,
  //               ),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             color: Colors.black87,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           description,
  //           style: const TextStyle(fontSize: 13, color: Colors.black54),
  //         ),
  //         if (number != null) ...[
  //           const SizedBox(height: 12),
  //           Text(
  //             'Number: $number',
  //             style: const TextStyle(
  //               fontSize: 13,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.black87,
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }
}
