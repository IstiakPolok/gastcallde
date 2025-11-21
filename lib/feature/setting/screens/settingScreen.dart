import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/setting/screens/ReportIssue.dart';
import 'package:gastcallde/feature/setting/screens/ReservationSettings.dart';
import 'package:gastcallde/feature/setting/screens/callforward.dart';
import 'package:get/get.dart';

import '../controllers/RestaurantSettingsController.dart';
import '../controllers/AssistantController.dart';
import '../controllers/WeeklyScheduleController.dart';

class settingScreen extends StatelessWidget {
  settingScreen({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text(' ')) : null,
      drawer: isMobile
          ? ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return CustomDrawer(
                  selectedIndex: 7,
                  onItemSelected: (index) {
                    _selectedIndexNotifier.value = index;
                  },
                );
              },
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return CustomNavigationRail(
                    selectedIndex: 8,
                    onDestinationSelected: (index) {
                      _selectedIndexNotifier.value = index;
                    },
                  );
                },
              ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  // You can switch views here based on selectedIndex
                  return SettingsScreen();
                  // Assuming callDashboard is the widget for call logs
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final RestaurantSettingsController restaurantController = Get.put(
    RestaurantSettingsController(),
  );
  final AssistantController assistantController = Get.put(
    AssistantController(),
  );
  final WeeklyScheduleController scheduleController = Get.put(
    WeeklyScheduleController(),
  );
  late TabController _tabController;

  final TextEditingController _addressController = TextEditingController();
  bool _isUpdatingAddress = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Initialize address controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (restaurantController.address.value.isNotEmpty) {
        _addressController.text = restaurantController.address.value;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return 'Not set';
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light background color
      appBar: AppBar(
        toolbarHeight: 70, // Reduced height for title and subtitle
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Live Overview of your restaurant\'s',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Call Forwarding'),
                Tab(text: 'Reservation Settings'),
                Tab(text: 'Admin Support'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSettingsTab(),
          CallForwardingScreen(), // Assuming you have a CallForwardingScreen widget
          ReservationSettingsScreen(),
          ReportIssue(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('AI Voice Settings'),
        Obx(() {
          if (assistantController.isLoading.value) {
            return _buildCard(
              children: [const Center(child: CircularProgressIndicator())],
            );
          }

          return _buildCard(
            children: [
              _buildSettingRow(
                'Choose voice',
                'Select AI voice for restaurant calls',
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://static.vecteezy.com/system/resources/previews/032/176/197/non_2x/business-avatar-profile-black-icon-man-of-user-symbol-in-trendy-flat-style-isolated-on-male-profile-people-diverse-face-for-social-network-or-web-vector.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assistantController.assistantId.value == 0
                                ? 'No AI Assistant'
                                : assistantController.getVoiceDisplayName(
                                    assistantController.voice.value,
                                  ),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            assistantController.assistantId.value == 0
                                ? 'Not assigned from admin'
                                : 'AI Voice Assistant',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (assistantController.assistantId.value != 0)
                      IconButton(
                        icon: Obx(
                          () => Icon(
                            assistantController.isPlaying.value
                                ? Icons.stop_circle
                                : Icons.play_circle_fill,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () async {
                          if (assistantController.isPlaying.value) {
                            await assistantController.stopVoicePreview();
                          } else {
                            await assistantController.playVoicePreview(
                              assistantController.voice.value,
                            );
                          }
                        },
                      ),
                    if (assistantController.assistantId.value != 0)
                      DropdownButton<String>(
                        value: assistantController.voice.value.isEmpty
                            ? null
                            : assistantController.voice.value.toLowerCase(),
                        hint: const Text('Select Voice'),
                        onChanged: (newVoice) async {
                          if (newVoice != null) {
                            final success = await assistantController
                                .updateVoiceSettings(
                                  newVoice,
                                  assistantController.speed.value,
                                );
                            if (success) {
                              Get.snackbar(
                                'Success',
                                'Voice updated to ${assistantController.getVoiceDisplayName(newVoice)}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Failed to update voice',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                        items: assistantController.voiceOptions.entries.map((
                          entry,
                        ) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          if (assistantController.assistantId.value == 0) {
            return const SizedBox.shrink();
          }
          return _buildCard(
            children: [
              _buildSettingRow(
                'Voice speed',
                'Adjust the speaking speed of AI voice',
                Column(
                  children: [
                    Slider(
                      value: assistantController.speed.value,
                      min: 0.7,
                      max: 1.2,
                      divisions: 5,
                      label: assistantController.speed.value.toStringAsFixed(1),
                      activeColor: AppColors.primaryColor,
                      inactiveColor: Colors.grey[300],
                      onChanged: (newValue) {
                        assistantController.speed.value = newValue;
                      },
                      onChangeEnd: (newValue) async {
                        final success = await assistantController
                            .updateVoiceSettings(
                              assistantController.voice.value,
                              newValue,
                            );
                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Voice speed updated to ${newValue.toStringAsFixed(1)}x',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to update voice speed',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                    Text(
                      '${assistantController.speed.value.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),

        // Call Transfer Section
        // _buildSectionTitle('Call Transfer'),
        // _buildCard(
        //   children: [
        //     Text(
        //       'Transfer call AI to restaurant staff when',
        //       style: TextStyle(color: Colors.grey[600]),
        //     ),
        //     const SizedBox(height: 8),
        //     TextField(
        //       controller: TextEditingController(text: _callTransferText),
        //       onChanged: (value) {
        //         setState(() {
        //           _callTransferText = value;
        //         });
        //       },
        //       maxLines: 4,
        //       decoration: InputDecoration(
        //         hintText: 'Type here',
        //         fillColor: const Color(0xFFF8F9FB),
        //         filled: true,
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(12.0),
        //           borderSide: BorderSide.none,
        //         ),
        //         contentPadding: const EdgeInsets.all(12.0),
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 24),

        _buildSectionTitle('Restaurant Address'),
        _buildCard(
          children: [
            Obx(() {
              if (restaurantController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                      ),
                      hintText: restaurantController.address.value.isEmpty
                          ? 'Enter restaurant address'
                          : restaurantController.address.value,
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isUpdatingAddress
                          ? null
                          : () async {
                              setState(() {
                                _isUpdatingAddress = true;
                              });

                              final newAddress = _addressController.text.trim();

                              if (newAddress.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Address cannot be empty',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                setState(() {
                                  _isUpdatingAddress = false;
                                });
                                return;
                              }

                              final success = await restaurantController
                                  .updateRestaurantAddress(newAddress);

                              setState(() {
                                _isUpdatingAddress = false;
                              });

                              if (success) {
                                Get.snackbar(
                                  'Success',
                                  'Restaurant address updated successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Failed to update address',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isUpdatingAddress
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update Address',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),

        const SizedBox(height: 24),

        // Business hours Section
        // _buildSectionTitle('Business hours'),
        // _buildCard(
        //   children: [
        //     Row(
        //       children: [
        //         Expanded(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               const Text(
        //                 'Opening Time',
        //                 style: TextStyle(
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w500,
        //                   color: Colors.black87,
        //                 ),
        //               ),
        //               const SizedBox(height: 8),
        //               InkWell(
        //                 onTap: () async {
        //                   final TimeOfDay? picked = await showTimePicker(
        //                     context: context,
        //                     initialTime: _openingTime ?? TimeOfDay.now(),
        //                   );
        //                   if (picked != null) {
        //                     setState(() {
        //                       _openingTime = picked;
        //                     });
        //                   }
        //                 },
        //                 child: Container(
        //                   padding: const EdgeInsets.symmetric(
        //                     horizontal: 12.0,
        //                     vertical: 14.0,
        //                   ),
        //                   decoration: BoxDecoration(
        //                     color: const Color(0xFFF8F9FB),
        //                     borderRadius: BorderRadius.circular(12.0),
        //                     border: Border.all(color: Colors.grey[300]!),
        //                   ),
        //                   child: Row(
        //                     children: [
        //                       const Icon(Icons.access_time, color: Colors.grey),
        //                       const SizedBox(width: 10),
        //                       Expanded(
        //                         child: Text(
        //                           _openingTime != null
        //                               ? _openingTime!.format(context)
        //                               : restaurantController
        //                                     .openingTime
        //                                     .value
        //                                     .isEmpty
        //                               ? 'Select opening time'
        //                               : restaurantController.formatTime(
        //                                   restaurantController
        //                                       .openingTime
        //                                       .value,
        //                                 ),
        //                           style: const TextStyle(
        //                             fontSize: 14,
        //                             color: Colors.black,
        //                           ),
        //                         ),
        //                       ),
        //                       const Icon(
        //                         Icons.keyboard_arrow_down,
        //                         color: Colors.grey,
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         const SizedBox(width: 16),
        //         Expanded(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               const Text(
        //                 'Closing Time',
        //                 style: TextStyle(
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w500,
        //                   color: Colors.black87,
        //                 ),
        //               ),
        //               const SizedBox(height: 8),
        //               InkWell(
        //                 onTap: () async {
        //                   final TimeOfDay? picked = await showTimePicker(
        //                     context: context,
        //                     initialTime: _closingTime ?? TimeOfDay.now(),
        //                   );
        //                   if (picked != null) {
        //                     setState(() {
        //                       _closingTime = picked;
        //                     });
        //                   }
        //                 },
        //                 child: Container(
        //                   padding: const EdgeInsets.symmetric(
        //                     horizontal: 12.0,
        //                     vertical: 14.0,
        //                   ),
        //                   decoration: BoxDecoration(
        //                     color: const Color(0xFFF8F9FB),
        //                     borderRadius: BorderRadius.circular(12.0),
        //                     border: Border.all(color: Colors.grey[300]!),
        //                   ),
        //                   child: Row(
        //                     children: [
        //                       const Icon(Icons.access_time, color: Colors.grey),
        //                       const SizedBox(width: 10),
        //                       Expanded(
        //                         child: Text(
        //                           _closingTime != null
        //                               ? _closingTime!.format(context)
        //                               : restaurantController
        //                                     .closingTime
        //                                     .value
        //                                     .isEmpty
        //                               ? 'Select closing time'
        //                               : restaurantController.formatTime(
        //                                   restaurantController
        //                                       .closingTime
        //                                       .value,
        //                                 ),
        //                           style: const TextStyle(
        //                             fontSize: 14,
        //                             color: Colors.black,
        //                           ),
        //                         ),
        //                       ),
        //                       const Icon(
        //                         Icons.keyboard_arrow_down,
        //                         color: Colors.grey,
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //     const SizedBox(height: 12),
        //     SizedBox(
        //       width: double.infinity,
        //       child: ElevatedButton(
        //         onPressed: _isUpdatingBusinessHours
        //             ? null
        //             : () async {
        //                 // Demo success - show immediately without validation
        //                 Get.snackbar(
        //                   'Success',
        //                   'Business hours updated successfully',
        //                   snackPosition: SnackPosition.BOTTOM,
        //                   backgroundColor: Colors.green,
        //                   colorText: Colors.white,
        //                   duration: const Duration(seconds: 3),
        //                 );

        //                 // Original code commented out for demo
        //                 // if (_openingTime == null || _closingTime == null) {
        //                 //   Get.snackbar(
        //                 //     'Error',
        //                 //     'Please select both opening and closing times',
        //                 //     snackPosition: SnackPosition.BOTTOM,
        //                 //     backgroundColor: Colors.red,
        //                 //     colorText: Colors.white,
        //                 //   );
        //                 //   return;
        //                 // }

        //                 // setState(() {
        //                 //   _isUpdatingBusinessHours = true;
        //                 // });

        //                 // // Convert TimeOfDay to HH:mm:ss format
        //                 // final openingTimeStr =
        //                 //     '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}:00';
        //                 // final closingTimeStr =
        //                 //     '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}:00';

        //                 // final success = await restaurantController
        //                 //     .updateBusinessHours(
        //                 //       openingTimeStr,
        //                 //       closingTimeStr,
        //                 //     );

        //                 // setState(() {
        //                 //   _isUpdatingBusinessHours = false;
        //                 // });

        //                 // if (success) {
        //                 //   Get.snackbar(
        //                 //     'Success',
        //                 //     'Business hours updated successfully',
        //                 //     snackPosition: SnackPosition.BOTTOM,
        //                 //     backgroundColor: Colors.green,
        //                 //     colorText: Colors.white,
        //                 //   );
        //                 // } else {
        //                 //   Get.snackbar(
        //                 //     'Error',
        //                 //     'Failed to update business hours',
        //                 //     snackPosition: SnackPosition.BOTTOM,
        //                 //     backgroundColor: Colors.red,
        //                 //     colorText: Colors.white,
        //                 //   );
        //                 // }
        //               },
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: AppColors.primaryColor,
        //           padding: const EdgeInsets.symmetric(vertical: 12),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //         ),
        //         child: _isUpdatingBusinessHours
        //             ? const SizedBox(
        //                 height: 20,
        //                 width: 20,
        //                 child: CircularProgressIndicator(
        //                   color: Colors.white,
        //                   strokeWidth: 2,
        //                 ),
        //               )
        //             : const Text(
        //                 'Update Business Hours',
        //                 style: TextStyle(fontSize: 14, color: Colors.white),
        //               ),
        //       ),
        //     ),

        //     // SizedBox(
        //     //   width: double.infinity,
        //     //   child: ElevatedButton(
        //     //     onPressed: _isUpdatingBusinessHours
        //     //         ? null
        //     //         : () async {
        //     //             if (_openingTime == null || _closingTime == null) {
        //     //               Get.snackbar(
        //     //                 'Error',
        //     //                 'Please select both opening and closing times',
        //     //                 snackPosition: SnackPosition.BOTTOM,
        //     //                 backgroundColor: Colors.red,
        //     //                 colorText: Colors.white,
        //     //               );
        //     //               return;
        //     //             }

        //     //             setState(() {
        //     //               _isUpdatingBusinessHours = true;
        //     //             });

        //     //             // Convert TimeOfDay to HH:mm:ss format
        //     //             final openingTimeStr =
        //     //                 '${_openingTime!.hour.toString().padLeft(2, '0')}:${_openingTime!.minute.toString().padLeft(2, '0')}:00';
        //     //             final closingTimeStr =
        //     //                 '${_closingTime!.hour.toString().padLeft(2, '0')}:${_closingTime!.minute.toString().padLeft(2, '0')}:00';

        //     //             final success = await restaurantController
        //     //                 .updateBusinessHours(
        //     //                   openingTimeStr,
        //     //                   closingTimeStr,
        //     //                 );

        //     //             setState(() {
        //     //               _isUpdatingBusinessHours = false;
        //     //             });

        //     //             if (success) {
        //     //               Get.snackbar(
        //     //                 'Success',
        //     //                 'Business hours updated successfully',
        //     //                 snackPosition: SnackPosition.BOTTOM,
        //     //                 backgroundColor: Colors.green,
        //     //                 colorText: Colors.white,
        //     //               );
        //     //             } else {
        //     //               Get.snackbar(
        //     //                 'Error',
        //     //                 'Failed to update business hours',
        //     //                 snackPosition: SnackPosition.BOTTOM,
        //     //                 backgroundColor: Colors.red,
        //     //                 colorText: Colors.white,
        //     //               );
        //     //             }
        //     //           },
        //     //     style: ElevatedButton.styleFrom(
        //     //       backgroundColor: AppColors.primaryColor,
        //     //       padding: const EdgeInsets.symmetric(vertical: 12),
        //     //       shape: RoundedRectangleBorder(
        //     //         borderRadius: BorderRadius.circular(8),
        //     //       ),
        //     //     ),
        //     //     child: _isUpdatingBusinessHours
        //     //         ? const SizedBox(
        //     //             height: 20,
        //     //             width: 20,
        //     //             child: CircularProgressIndicator(
        //     //               color: Colors.white,
        //     //               strokeWidth: 2,
        //     //             ),
        //     //           )
        //     //         : const Text(
        //     //             'Update Business Hours',
        //     //             style: TextStyle(fontSize: 14, color: Colors.white),
        //     //           ),
        //     //   ),
        //     // ),
        //   ],
        // ),
        const SizedBox(height: 24),

        // Weekly Schedule Section
        _buildSectionTitle('Weekly Schedule'),
        Obx(() {
          if (scheduleController.isLoading.value) {
            return _buildCard(
              children: [const Center(child: CircularProgressIndicator())],
            );
          }

          return _buildCard(
            children: [
              const Text(
                'Set opening and closing hours for each day of the week',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...scheduleController.weeklySchedule.keys.map((day) {
                final dayCapitalized = day[0].toUpperCase() + day.substring(1);
                final schedule = scheduleController.weeklySchedule[day]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayCapitalized,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      schedule['opening'] ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  scheduleController.updateTime(
                                    day,
                                    'opening',
                                    picked,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FB),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Obx(
                                        () => Text(
                                          scheduleController
                                                      .weeklySchedule[day]!['opening'] !=
                                                  null
                                              ? scheduleController
                                                    .weeklySchedule[day]!['opening']!
                                                    .format(context)
                                              : 'Opening',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                scheduleController
                                                        .weeklySchedule[day]!['opening'] !=
                                                    null
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'to',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      schedule['closing'] ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  scheduleController.updateTime(
                                    day,
                                    'closing',
                                    picked,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FB),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Obx(
                                        () => Text(
                                          scheduleController
                                                      .weeklySchedule[day]!['closing'] !=
                                                  null
                                              ? scheduleController
                                                    .weeklySchedule[day]!['closing']!
                                                    .format(context)
                                              : 'Closing',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                scheduleController
                                                        .weeklySchedule[day]!['closing'] !=
                                                    null
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              final success = await scheduleController
                                  .saveDaySchedule(day);

                              if (success) {
                                Get.snackbar(
                                  'Success',
                                  '$dayCapitalized schedule updated successfully',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Failed to update $dayCapitalized schedule',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              // SizedBox(
              //   width: double.infinity,
              //   child: Obx(
              //     () => ElevatedButton(
              //       onPressed: scheduleController.isSaving.value
              //           ? null
              //           : () async {
              //               final success = await scheduleController
              //                   .saveWeeklySchedule();

              //               if (success) {
              //                 Get.snackbar(
              //                   'Success',
              //                   'Weekly schedule saved successfully',
              //                   snackPosition: SnackPosition.BOTTOM,
              //                   backgroundColor: Colors.green,
              //                   colorText: Colors.white,
              //                   duration: const Duration(seconds: 3),
              //                 );
              //               } else {
              //                 Get.snackbar(
              //                   'Error',
              //                   'Failed to save weekly schedule',
              //                   snackPosition: SnackPosition.BOTTOM,
              //                   backgroundColor: Colors.red,
              //                   colorText: Colors.white,
              //                   duration: const Duration(seconds: 3),
              //                 );
              //               }
              //             },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: AppColors.primaryColor,
              //         padding: const EdgeInsets.symmetric(vertical: 12),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //       ),
              //       child: scheduleController.isSaving.value
              //           ? const SizedBox(
              //               height: 20,
              //               width: 20,
              //               child: CircularProgressIndicator(
              //                 color: Colors.white,
              //                 strokeWidth: 2,
              //               ),
              //             )
              //           : const Text(
              //               'Save Weekly Schedule',
              //               style: TextStyle(fontSize: 14, color: Colors.white),
              //             ),
              //     ),
              //   ),
              // ),
            ],
          );
        }),

        const SizedBox(height: 24),

        // Special promotions Section
        // _buildSectionTitle('Special promotions'),
        // _buildCard(
        //   children: [
        //     Text(
        //       'AI will mention during calls',
        //       style: TextStyle(color: Colors.grey[600]),
        //     ),
        //     const SizedBox(height: 8),
        //     TextField(
        //       controller: TextEditingController(text: _specialPromotionsText),
        //       onChanged: (value) {
        //         setState(() {
        //           _specialPromotionsText = value;
        //         });
        //       },
        //       maxLines: 4,
        //       decoration: InputDecoration(
        //         hintText: 'Type here',
        //         fillColor: const Color(0xFFF8F9FB),
        //         filled: true,
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(12.0),
        //           borderSide: BorderSide.none,
        //         ),
        //         contentPadding: const EdgeInsets.all(12.0),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, String subtitle, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        control,
      ],
    );
  }
}
