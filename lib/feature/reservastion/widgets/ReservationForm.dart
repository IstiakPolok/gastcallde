import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/custom_button.dart';
import 'package:gastcallde/feature/reservastion/controllers/addTableReservationController.dart';
import 'package:gastcallde/feature/reservastion/screens/reservationScreen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ReservationFormPage extends StatefulWidget {
  const ReservationFormPage({super.key});

  @override
  State<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends State<ReservationFormPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();

  final List<bool> _selectedFromTime = List.generate(10, (_) => false);
  final List<bool> _selectedToTime = List.generate(10, (_) => false);
  List<Map<String, dynamic>> tableList = [];
  bool isLoading = false;
  final TableApiController _tableApiController = TableApiController();
  int? _selectedTableId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // ✅ Store as yyyy-MM-dd
    _dateController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    _fetchTables();
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return weekdays[weekday - 1];
  }

  Future<void> _fetchTables() async {
    setState(() {
      isLoading = true;
    });

    try {
      final tables = await _tableApiController.fetchTables();
      setState(() {
        tableList = tables;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tables: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        // ✅ Format as yyyy-MM-dd
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInformationSection(),
          const SizedBox(height: 24),
          _buildTimeSelectionSection(),
          const SizedBox(height: 24),
          _buildSummarySection(),
          const SizedBox(height: 24),

          const SizedBox(height: 16),
          if (isLoading)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                const Text(
                  'Available Tables:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  itemCount: tableList.length,
                  itemBuilder: (context, index) {
                    final table = tableList[index];
                    final isSelected = _selectedTableId == table['id'];

                    return ListTile(
                      title: Text(table['table_name']),
                      subtitle: Text('Seats: ${table['total_set']}'),
                      tileColor: isSelected
                          ? Colors.blue[100]
                          : null, // highlight selection
                      onTap: () {
                        setState(() {
                          _selectedTableId = table['id'];
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Confirm now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildInformationSection()),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    //_buildSummarySection(),
                    const SizedBox(height: 24),

                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          SizedBox(height: 30),
                          const Text(
                            'Available Tables:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            height: 300, // Adjust as you want
                            child: Container(
                              padding: const EdgeInsets.all(
                                16.0,
                              ), // Add padding for internal spacing
                              decoration: BoxDecoration(
                                // Set background color (light grey in this case)
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Rounded corners
                                border: Border.all(
                                  color: Colors.grey, // Border color
                                  width: 2, // Border width
                                ),
                              ),
                              child: ListView.builder(
                                itemCount: tableList.length,
                                itemBuilder: (context, index) {
                                  final table = tableList[index];
                                  final isSelected =
                                      _selectedTableId == table['id'];

                                  return ListTile(
                                    title: Text(
                                      table['table_name'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Seats: ${table['total_set']}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    tileColor: isSelected
                                        ? AppColors.primaryColor
                                        : null, // highlight selection
                                    onTap: () {
                                      print(
                                        'Selected table: ${table['table_name']}',
                                      );
                                      setState(() {
                                        _selectedTableId = table['id'];
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              EasyLoading.show();
                              try {
                                final api = ReservationApiController();

                                // extract selected "from" & "to" time
                                String fromTime = "";
                                String toTime = "";
                                final times = [
                                  '06:00:00',
                                  '07:00:00',
                                  '08:00:00',
                                  '09:00:00',
                                  '10:00:00',
                                  '11:00:00',
                                  '12:00:00',
                                  '13:00:00',
                                  '14:00:00',
                                  '15:00:00',
                                ];
                                int fromIndex = _selectedFromTime.indexWhere(
                                  (e) => e,
                                );
                                int toIndex = _selectedToTime.indexWhere(
                                  (e) => e,
                                );
                                if (fromIndex != -1) {
                                  fromTime = times[fromIndex];
                                }
                                if (toIndex != -1) toTime = times[toIndex];

                                // dummy pick first table (or let user choose later)
                                final int selectedTable = tableList.isNotEmpty
                                    ? tableList[0]['id']
                                    : 0;

                                final result = await api.createReservation(
                                  customerName: _nameController.text,
                                  phoneNumber: _phoneController.text,
                                  guestNo:
                                      int.tryParse(_peopleController.text) ?? 1,
                                  date: _dateController
                                      .text, // ensure yyyy-MM-dd when sending to API
                                  fromTime: fromTime,
                                  toTime: toTime,
                                  tableId:
                                      _selectedTableId ??
                                      0, // use selected table
                                  email: _emailController.text,
                                );

                                Get.snackbar(
                                  "Success",
                                  "Reservation Created: ID ${result['id']}",
                                );
                              } catch (e) {
                                Get.snackbar("Error", e.toString());
                              }
                              EasyLoading.dismiss();
                              Get.to(ReservationScreen());
                            },
                            child: const Text('Confirm now'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          _buildTimeSelectionSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInformationSection() {
    return _SectionCard(
      title: 'Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Customer name',
            hint: 'Type here',
            icon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Phone num',
            hint: '+895 3467 458',
            icon: Icons.phone_android,
            controller: _phoneController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Email',
            hint: 'User2025@gmail.com',
            icon: Icons.email_outlined,
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Number of people',
            hint: 'Type here',
            icon: Icons.group_outlined,
            controller: _peopleController,
          ),
          const SizedBox(height: 16),
          _buildDateField(label: 'Date', controller: _dateController),
        ],
      ),
    );
  }

  Widget _buildTimeSelectionSection() {
    return _SectionCard(
      title: 'Choose Time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'From',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _TimeSelector(
            selectedTimes: _selectedFromTime,
            onSelected: (index) {
              setState(() {
                for (int i = 0; i < _selectedFromTime.length; i++) {
                  _selectedFromTime[i] = i == index;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'To',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _TimeSelector(
            selectedTimes: _selectedToTime,
            onSelected: (index) {
              setState(() {
                for (int i = 0; i < _selectedToTime.length; i++) {
                  _selectedToTime[i] = i == index;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return _SectionCard(
      title: 'Reserve a table',
      child: Column(
        children: const [
          _SummaryRow(icon: Icons.person_outline, text: 'Jorge Doe'),
          SizedBox(height: 8),
          _SummaryRow(icon: Icons.group_outlined, text: '3 person'),
          SizedBox(height: 8),
          _SummaryRow(icon: Icons.calendar_month, text: 'Friday, 17 July 2025'),
          SizedBox(height: 8),
          _SummaryRow(icon: Icons.access_time_outlined, text: '04:00 - 06:00'),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                12,
              ), // Rounded corners for the border
              borderSide: BorderSide(
                color: Colors.blue,
                width: 1,
              ), // Blue border
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.calendar_month, size: 18),
            SizedBox(width: 8),
            Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.arrow_drop_down),
            hintText: 'Select a date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                12,
              ), // Rounded corners for the border
              borderSide: BorderSide(
                color: Colors.blue,
                width: 1,
              ), // Blue border
            ),
          ),
          onTap: () => _selectDate(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Reservation Form',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            return _buildTabletLayout();
          } else {
            return _buildPhoneLayout();
          }
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24, thickness: 1, color: Colors.grey),
            child,
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SummaryRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)],
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final List<bool> selectedTimes;
  final Function(int) onSelected;
  const _TimeSelector({required this.selectedTimes, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final List<String> times = [
      '06:00',
      '07:00',
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List.generate(times.length, (index) {
        return ElevatedButton(
          onPressed: () => onSelected(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedTimes[index]
                ? AppColors.primaryColor
                : Colors.grey[200],
            foregroundColor: selectedTimes[index] ? Colors.white : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(times[index]),
        );
      }),
    );
  }
}
