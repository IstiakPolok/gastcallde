import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class CallForwardingScreen extends StatefulWidget {
  const CallForwardingScreen({super.key});

  @override
  State<CallForwardingScreen> createState() => _CallForwardingScreenState();
}

class _CallForwardingScreenState extends State<CallForwardingScreen> {
  String? _forwardingMode = 'Always Forward';
  final TextEditingController _originalNumberController = TextEditingController(
    text: '+88 838 78567',
  );
  final TextEditingController _aiAssignedNumberController =
      TextEditingController(text: '+8475 5848 48');
  final TextEditingController _immediateForwardingController =
      TextEditingController();
  final TextEditingController _whenBusyController = TextEditingController();
  final TextEditingController _whenNotAnsweringController =
      TextEditingController();
  final TextEditingController _allForwardingsController =
      TextEditingController();

  @override
  void dispose() {
    _originalNumberController.dispose();
    _aiAssignedNumberController.dispose();
    _immediateForwardingController.dispose();
    _whenBusyController.dispose();
    _whenNotAnsweringController.dispose();
    _allForwardingsController.dispose();
    super.dispose();
  }

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
      body: SingleChildScrollView(
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
                'Call forwarding ensures you never miss a customer call, even when you\'re away from the restaurant. When a customer calls your restaurant\'s number, the call will be automatically forwarded to the AI-assigned number, which is then forwarded to your personal or business phone. This way, you can manage orders and customer inquiries seamlessly, whether you\'re on-site or off-site.',
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
                    controller: _originalNumberController,
                    labelText: 'Original Number (Your restaurant)',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _aiAssignedNumberController,
                    labelText: 'AI-Assigned Number',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _aiAssignedNumberController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard!')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _immediateForwardingController,
                    labelText: 'Immediate Forwarding',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _whenBusyController,
                    labelText: 'When Busy',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _whenNotAnsweringController,
                    labelText: 'When Not Answering',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _allForwardingsController,
                    labelText: 'All Forwardings',
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
                      // Handle Save action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // Matching the green color
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
                      // Handle Test Forwarding action
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.teal,
                      ), // Matching the green border
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

            // Callback settings section
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
                    number: '+0938 477539',
                    isSwitch: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCallbackCard(
                    icon: Icons.calendar_month,
                    title: 'Schedule callback',
                    description:
                        'The AI collects customer data & schedules a callback. You process these later via the call overview.',
                    isSwitch: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
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
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: suffixIcon,
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
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
      activeColor: Colors.blue, // Matching the blue radio button
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
              Icon(icon, color: Colors.teal), // Matching the icon color
              if (isSwitch)
                Switch(
                  value: true, // This can be managed by a state variable
                  onChanged: (bool value) {
                    // Handle switch toggle
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
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.4,
            ),
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
