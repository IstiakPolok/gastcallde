import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/setting/controllers/TableController.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ReservationSettingsScreen extends StatefulWidget {
  ReservationSettingsScreen({super.key});
  final TableController tableController = Get.put(TableController());
  // Properly initializing the controller

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

  final List<TableForm> _tables = [];
  var tableList = <TableModel>[].obs;

  @override
  void initState() {
    super.initState();
    _addTable(); // Add initial table row
    widget.tableController.fetchTables(); // Fetch tables from the API
  }

  @override
  void dispose() {
    _numberOfTablesController.dispose();
    _perTableCapacityController.dispose();
    _maxGuestsPerReservationController.dispose();
    super.dispose();
  }

  // void _addTable() {
  //   setState(() {
  //     _tables.add({
  //       'name': TextEditingController(),
  //       'capacity': TextEditingController(),
  //       'status': 'active', // default
  //       'reservation_status': 'available', // default
  //     });
  //   });
  // }

  void _addTable() {
    setState(() {
      _tables.add(
        TableForm(
          name: TextEditingController(),
          capacity: TextEditingController(),
        ),
      );
    });
  }

  void _removeTable(int index) {
    setState(() {
      _tables[index].dispose();
      _tables.removeAt(index);
    });
  }

  // void _removeTable(int index) {
  //   setState(() {
  //     _tables[index]['name']?.dispose();
  //     _tables[index]['capacity']?.dispose();
  //     _tables.removeAt(index);
  //   });
  // }

  Widget _buildTableList() {
    return Obx(() {
      if (widget.tableController.tables.isEmpty) {
        return const CircularProgressIndicator();
      }
      return SizedBox(
        height: 200, // Set this to whatever height fits your design
        child: ListView.builder(
          itemCount: widget.tableController.tables.length,
          itemBuilder: (context, index) {
            final table = widget.tableController.tables[index];
            return ListTile(
              title: Text(table.name),
              subtitle: Text(
                'Capacity: ${table.capacity}, Status: ${table.status}, Reservation Status: ${table.reservationStatus}',
              ),
            );
          },
        ),
      );
    });
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ), // Default border color
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      filled: true, // Enable filling of the background color
      fillColor: const Color(0xFFF8FAFC),
      // Set the background color
    );
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

              // Display fetched table list before the add table section
              _buildSectionTitle('Existing Tables', Icons.table_chart),
              const SizedBox(height: 16),
              _buildTableList(),
              const SizedBox(height: 32),
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
                  // InkWell(
                  //   onTap: _addTable,
                  //   borderRadius: BorderRadius.circular(20),
                  //   child: Container(
                  //     padding: const EdgeInsets.all(4),
                  //     decoration: BoxDecoration(
                  //       color:
                  //           AppColors.primaryColor, // Blue color for add button
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: const Icon(
                  //       Icons.add,
                  //       color: Colors.white,
                  //       size: 20,
                  //     ),
                  //   ),
                  // ),
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
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Table Name
                                  Expanded(
                                    child: _buildSmallTextField(
                                      'Table ${index + 1}',
                                      _tables[index].name,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Capacity
                                  Expanded(
                                    child: _buildSmallTextField(
                                      'Capacity',
                                      _tables[index].capacity,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Remove button
                                  InkWell(
                                    onTap: () => _removeTable(index),
                                    child: const Icon(
                                      Icons.close,
                                      color: Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: const [
                                  Expanded(
                                    child: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Reservation Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 24), // For the remove icon
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _tables[index].status,
                                      items: ['active', 'inactive']
                                          .map(
                                            (val) => DropdownMenuItem(
                                              value: val,
                                              child: Text(val),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _tables[index].status = val!;
                                        });
                                      },
                                      decoration: _dropdownDecoration(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _tables[index].reservationStatus,
                                      items:
                                          [
                                                'available',
                                                'unavailable', // <-- lowercase version
                                              ]
                                              .map(
                                                (val) => DropdownMenuItem(
                                                  value: val,
                                                  child: Text(val),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _tables[index].reservationStatus =
                                              val!;
                                        });
                                      },
                                      decoration: _dropdownDecoration(),
                                    ),
                                  ),

                                  // Reservation Status Dropdown
                                  const SizedBox(width: 8),
                                ],
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
          onPressed: () async {
            await widget.tableController.saveTables(
              _tables.map((t) => t.toModel()).toList(),
            );

            // Clear all table fields after saving
            for (var table in _tables) {
              table.name.clear();
              table.capacity.clear();
              table.status = 'active';
              table.reservationStatus = 'available';
            }
            setState(() {
              _tables.clear();
              _addTable(); // Optionally add a fresh empty row
            });

            print('Save button pressed!');
          },

          // onPressed: () async {
          //   await tableController.saveTables;
          //   print('Save button pressed!');
          //   print('Automatic Table Assignment: $_automaticTableAssignment');
          //   print(
          //     'Manage Table Assignment Manually: $_manageTableAssignmentManually',
          //   );
          //   print('Number of Tables: ${_numberOfTablesController.text}');
          //   print('Per Table Capacity: ${_perTableCapacityController.text}');
          //   print(
          //     'Maximum Guests Per Reservation: ${_maxGuestsPerReservationController.text}',
          //   );
          //   for (int i = 0; i < _tables.length; i++) {
          //     print(
          //       'Table ${i + 1} Name: ${_tables[i]['name']?.text}, Capacity: ${_tables[i]['capacity']?.text}',
          //     );
          //   }
          // },
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

class TableForm {
  final TextEditingController name;
  final TextEditingController capacity;
  String status;
  String reservationStatus;

  TableForm({
    required this.name,
    required this.capacity,
    this.status = 'active',
    this.reservationStatus = 'available',
  });

  TableModel toModel() {
    return TableModel(
      name: name.text,
      capacity: capacity.text,
      status: status,
      reservationStatus: reservationStatus,
    );
  }

  void dispose() {
    name.dispose();
    capacity.dispose();
  }
}
