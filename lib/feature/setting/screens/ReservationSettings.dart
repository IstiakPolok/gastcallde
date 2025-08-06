import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';

class ReservationSettingsScreen extends StatefulWidget {
  const ReservationSettingsScreen({super.key});

  @override
  State<ReservationSettingsScreen> createState() =>
      _ReservationSettingsScreenState();
}

class _ReservationSettingsScreenState extends State<ReservationSettingsScreen> {
  bool _automaticTableAssignment = true;
  bool _manageTableAssignmentManually = false;
  final TextEditingController _numberOfTablesController =
      TextEditingController();
  final TextEditingController _perTableCapacityController =
      TextEditingController();
  final TextEditingController _maxGuestsPerReservationController =
      TextEditingController();
  final List<Map<String, TextEditingController>> _tables = [];

  @override
  void initState() {
    super.initState();
    _addTable(); // Add initial table row
  }

  @override
  void dispose() {
    _numberOfTablesController.dispose();
    _perTableCapacityController.dispose();
    _maxGuestsPerReservationController.dispose();
    for (var table in _tables) {
      table['name']?.dispose();
      table['capacity']?.dispose();
    }
    super.dispose();
  }

  void _addTable() {
    setState(() {
      _tables.add({
        'name': TextEditingController(),
        'capacity': TextEditingController(),
      });
    });
  }

  void _removeTable(int index) {
    setState(() {
      _tables[index]['name']?.dispose();
      _tables[index]['capacity']?.dispose();
      _tables.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reservation settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reservation settings section
              _buildSectionTitle('Reservation settings', Icons.settings),
              const SizedBox(height: 16),
              _buildToggleRow(
                'Automatic table assignment',
                'Let our AI automatically assign tables to reservations',
                _automaticTableAssignment,
                (bool value) {
                  setState(() {
                    _automaticTableAssignment = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildToggleRow(
                'Manage table assignment manually',
                'Set table assignment manually to maintain control',
                _manageTableAssignmentManually,
                (bool value) {
                  setState(() {
                    _manageTableAssignmentManually = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Additional configurations section
              _buildSectionTitle('Additional configurations', Icons.settings),
              const SizedBox(height: 16),
              _buildTextFieldRow(
                'Number of tables',
                'Enter number of tables',
                _numberOfTablesController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFieldRow(
                'Per Table capacity',
                'Enter capacity per table',
                _perTableCapacityController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFieldRow(
                'Maximum guests per reservation',
                'Enter maximum guests',
                _maxGuestsPerReservationController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // Add Table section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Table',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  InkWell(
                    onTap: _addTable,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primaryColor, // Blue color for add button
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Table Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Table Capacity',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        SizedBox(width: 24), // For the remove icon
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tables.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSmallTextField(
                                  'Table ${index + 1}',
                                  _tables[index]['name']!,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSmallTextField(
                                  'Capacity',
                                  _tables[index]['capacity']!,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _removeTable(index),
                                child: const Icon(
                                  Icons.close,
                                  color: Color(
                                    0xFF94A3B8,
                                  ), // Greyish color for close icon
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: () {
            // Handle save action
            print('Save button pressed!');
            print('Automatic Table Assignment: $_automaticTableAssignment');
            print(
              'Manage Table Assignment Manually: $_manageTableAssignmentManually',
            );
            print('Number of Tables: ${_numberOfTablesController.text}');
            print('Per Table Capacity: ${_perTableCapacityController.text}');
            print(
              'Maximum Guests Per Reservation: ${_maxGuestsPerReservationController.text}',
            );
            for (int i = 0; i < _tables.length; i++) {
              print(
                'Table ${i + 1} Name: ${_tables[i]['name']?.text}, Capacity: ${_tables[i]['capacity']?.text}',
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.primaryColor, // Blue color for save button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor, // Blue active color
            inactiveThumbColor: const Color(
              0xFFCBD5E1,
            ), // Light grey inactive thumb
            inactiveTrackColor: const Color(
              0xFFE2E8F0,
            ), // Lighter grey inactive track
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
            style: const TextStyle(color: Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTextField(
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFFF8FAFC,
        ), // Lighter background for these text fields
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 1.5,
            ),
          ),
        ),
        style: const TextStyle(color: Color(0xFF1E293B)),
      ),
    );
  }
}
