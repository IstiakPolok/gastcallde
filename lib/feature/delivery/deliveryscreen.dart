import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:get/get.dart';

import 'controllers/delivery_info_controller.dart';

class DeliveryScreen extends StatelessWidget {
  DeliveryScreen({super.key});

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
                  selectedIndex: 6,
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
                    selectedIndex: 6,
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
                  return const DeliveryInfoScreen();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryInfoScreen extends StatelessWidget {
  const DeliveryInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DeliveryInfoController controller = Get.put(DeliveryInfoController());
    controller.fetchDeliveryAreas(); // Fetch data on screen load

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.deliveryAreas.isEmpty) {
          return const Center(child: Text('No delivery areas found.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Information',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Delivery Areas (Postal Codes / PLZ)',
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddAddressDialog(context, controller);
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text('Add Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      ...controller.deliveryAreas.map((area) {
                        return Column(
                          children: [
                            _buildDataRow(
                              postalCode: area['postalcode'] ?? '-',
                              deliveryTime:
                                  "${area['estimated_delivery_time']} mins",
                              fee: "${area['delivery_fee']} Tk",
                              id: area['id'],
                              controller: controller,
                              context: context,
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Postal Code (PLZ)',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Estimated Delivery Time',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Delivery Fee',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Action',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required String postalCode,
    required String deliveryTime,
    required String fee,
    required int id,
    required DeliveryInfoController controller,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              postalCode,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              deliveryTime,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              fee,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  Icons.edit_outlined,
                  onTap: () {
                    // TODO: edit action
                  },
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Icons.delete_outline,
                  onTap: () {
                    _showDeleteConfirmation(context, controller, id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog(
    BuildContext context,
    DeliveryInfoController controller,
  ) {
    final postalCodeController = TextEditingController();
    final estimatedTimeController = TextEditingController();
    final deliveryFeeController = TextEditingController();

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 24.0,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Area Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Delivery Areas (Postal Codes / PLZ)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: postalCodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Postal Code",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: estimatedTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Estimated Delivery Time (mins)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: deliveryFeeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Delivery Fee",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final postal = postalCodeController.text.trim();
                            final time = estimatedTimeController.text.trim();
                            final fee = deliveryFeeController.text.trim();

                            if (postal.isEmpty || time.isEmpty || fee.isEmpty) {
                              Get.snackbar("Error", "Please fill all fields");
                              return;
                            }

                            Get.back();
                            await controller.addDeliveryArea(
                              postalCode: postal,
                              estimatedTime: time,
                              deliveryFee: fee,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Add"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 18.0, color: Colors.grey.shade600),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    DeliveryInfoController controller,
    int id,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this delivery area?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // close dialog
              await controller.deleteDeliveryArea(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
