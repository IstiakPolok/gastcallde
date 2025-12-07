import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/reservastion/controllers/addTableReservationController.dart';
import 'package:gastcallde/feature/reservastion/screens/reservationScreen.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

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
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<bool> _selectedFromTime = List.generate(10, (_) => false);
  final List<bool> _selectedToTime = List.generate(10, (_) => false);
  List<Map<String, dynamic>> tableList = [];
  bool isLoading = false;
  bool isLoadingCustomer = false;
  final TableApiController _tableApiController = TableApiController();
  int? _selectedTableId;
  String _selectedCountryCode = '+49';

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

  Future<void> _fetchCustomerInfo() async {
    if (_phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a phone number');
      return;
    }

    setState(() {
      isLoadingCustomer = true;
    });

    try {
      final fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';
      print('Fetching customer info for phone: $fullPhoneNumber');
      final customerData = await _tableApiController.fetchCustomerByPhone(
        fullPhoneNumber,
      );
      print('Customer data received: $customerData');

      final customerInfo = customerData['customerInfo'];

      // Auto-fill the form fields
      _nameController.text = customerInfo['name'] ?? '';
      _emailController.text = customerInfo['email'] ?? '';

      // Get address and allergy from the first order if available
      if (customerData['orders'] != null &&
          (customerData['orders'] as List).isNotEmpty) {
        final firstOrder = customerData['orders'][0];
        print('First order found: $firstOrder');
        _addressController.text = firstOrder['address'] ?? '';
        _allergyController.text = firstOrder['allergy'] ?? '';
      } else {
        print('No orders found for this customer.');
      }

      Get.snackbar(
        'Success',
        'Customer information loaded successfully',
        backgroundColor: AppColors.primaryColor.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error fetching customer info: $e');
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      Get.snackbar(
        'Info',
        errorMessage,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoadingCustomer = false;
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
    _addressController.dispose();
    _allergyController.dispose();
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
                Text(
                  'available_tables'.tr,
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
              onPressed: _submitReservation,
              child: Text('confirm_now'.tr),
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
                          Text(
                            'available_tables'.tr,
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
                            onPressed: _submitReservation,
                            child: Text('confirm_now'.tr),
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
      title: 'information'.tr,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'customer_name'.tr,
              hint: 'type_here'.tr,
              icon: Icons.person_outline,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_android, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'phone_num'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountryCode = '+${country.phoneCode}';
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountryCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '123 456 7890',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isLoadingCustomer ? null : _fetchCustomerInfo,
                      icon: isLoadingCustomer
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.search, size: 18),
                      label: Text('fetch'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'email'.tr,
              hint: 'User2025@gmail.com',
              icon: Icons.email_outlined,
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                // Improved email validation
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'number_of_people'.tr,
              hint: 'type_here'.tr,
              icon: Icons.group_outlined,
              controller: _peopleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of people';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'address'.tr,
              hint: 'type_here'.tr,
              icon: Icons.location_on_outlined,
              controller: _addressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'allergies'.tr,
              hint: 'type_here'.tr,
              icon: Icons.medical_services_outlined,
              controller: _allergyController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter allergy information';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'date'.tr,
              controller: _dateController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectionSection() {
    return _SectionCard(
      title: 'choose_time'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'from'.tr,
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
          Text(
            'to_time'.tr,
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
      title: 'reserve_a_table'.tr,
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
    String? Function(String?)? validator,
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
          validator: validator,
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
    String? Function(String?)? validator,
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
          validator: validator,
          readOnly: true,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.arrow_drop_down),
            hintText: 'select_a_date'.tr,
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
        title: Text(
          'reservation_form'.tr,
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

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTableId == null) {
      Get.snackbar('Error', 'Please select a table');
      return;
    }

    int fromIndex = _selectedFromTime.indexWhere((e) => e);
    int toIndex = _selectedToTime.indexWhere((e) => e);

    if (fromIndex == -1 || toIndex == -1) {
      Get.snackbar('Error', 'Please select both from and to time');
      return;
    }

    // Validate that to_time is after from_time
    if (toIndex <= fromIndex) {
      Get.snackbar(
        'Error',
        'End time must be after start time',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    EasyLoading.show();
    try {
      final api = ReservationApiController();

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

      String fromTime = times[fromIndex];
      String toTime = times[toIndex];

      final fullPhoneNumber = '$_selectedCountryCode${_phoneController.text}';

      final result = await api.createReservation(
        customerName: _nameController.text,
        phoneNumber: fullPhoneNumber,
        guestNo: int.tryParse(_peopleController.text) ?? 1,
        date: _dateController.text,
        fromTime: fromTime,
        toTime: toTime,
        tableId: _selectedTableId!,
        email: _emailController.text,
        address: _addressController.text,
        allergy: _allergyController.text,
      );

      Get.snackbar(
        "Success",
        "Reservation Created: ID ${result['id']}",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      Get.to(() => ReservationScreen());
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: ")) {
        errorMessage = errorMessage.replaceFirst("Exception: ", "");
      }

      // Truncate very long error messages to prevent UI overflow
      if (errorMessage.length > 200) {
        if (errorMessage.contains('SMTPRecipientsRefused')) {
          errorMessage = 'Invalid email address. Please check and try again.';
        } else if (errorMessage.contains('<!DOCTYPE html>')) {
          errorMessage =
              'Server error occurred. Please check your input and try again.';
        } else {
          errorMessage = errorMessage.substring(0, 200) + '...';
        }
      }

      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        maxWidth: 400,
      );
    } finally {
      EasyLoading.dismiss();
    }
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
