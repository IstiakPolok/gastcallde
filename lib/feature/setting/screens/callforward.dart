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

  String? _forwardingMode = 'Always Forward';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Call Forwarding',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (restaurantController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // How to Forward a call section
              const Text(
                'How to Forward a call',
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
                child: const Text(
                  'Call forwarding ensures you never miss a customer call, even when you\'re away from the restaurant...',
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
                    child: _buildTextField(
                      initialValue: restaurantController.phoneNumber1.value,
                      labelText: 'Original Number (Your restaurant)',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      initialValue: restaurantController.twilioNumber.value,
                      labelText: 'AI-Assigned Number',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: restaurantController.twilioNumber.value,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard!'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Forwarding Mode section
              const Text(
                'Forwarding Mode',
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
                      title: 'Always Forward',
                      value: 'Always Forward',
                    ),
                    _buildRadioListTile(
                      title: 'Forward During Opening Hours',
                      value: 'Forward During Opening Hours',
                    ),
                    _buildRadioListTile(
                      title: 'Disable Forwarding',
                      value: 'Disable Forwarding',
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
                      onPressed: () {
                        // TODO: Save changes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Test Forwarding
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Test Forwarding',
                        style: TextStyle(fontSize: 16, color: Colors.teal),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Callback settings
              const Text(
                'Callback settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure how the AI should react to important request during opening hours',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildCallbackCard(
                      icon: Icons.sync_alt,
                      title: 'Forward immediately',
                      description:
                          'For important matters the customer is forward directly to an employee',
                      number: restaurantController.phoneNumber1.value,
                      isSwitch: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCallbackCard(
                      icon: Icons.calendar_month,
                      title: 'Schedule callback',
                      description:
                          'The AI collects customer data & schedules a callback.',
                      isSwitch: true,
                    ),
                  ),
                ],
              ),
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

  Widget _buildCallbackCard({
    required IconData icon,
    required String title,
    required String description,
    String? number,
    required bool isSwitch,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.teal),
              if (isSwitch)
                Switch(
                  value: true,
                  onChanged: (bool value) {
                    // Handle toggle
                  },
                  activeColor: Colors.teal,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          if (number != null) ...[
            const SizedBox(height: 12),
            Text(
              'Number: $number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
