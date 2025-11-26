import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  Map<String, dynamic>? customerInfo;
  List<Map<String, dynamic>> orderHistory = [];
  RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  Future<void> fetchCustomerDetails() async {
    setState(() {
      isLoading.value = true;
    });

    final phone = Get.arguments?['phone'];
    print("📞 Debug: Phone argument received: $phone");
    if (phone == null) {
      Get.snackbar('error'.tr, 'no_phone_provided'.tr);
      return;
    }

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      print("🔑 Debug: Access token: $token");
      if (token == null) {
        Get.snackbar('error'.tr, 'user_not_authenticated'.tr);
        return;
      }

      final url = Uri.parse(
        "${Urls.baseUrl}/owner/orders/by-phone/?phone=$phone",
      );
      print("🌐 Debug: Fetching customer details from: $url");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📡 Debug: Response status: ${response.statusCode}");
      print("📦 Debug: Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Debug: Decoded JSON: $data");

        setState(() {
          customerInfo = data['customerInfo'] ?? {};
          print("👤 Debug: customerInfo: $customerInfo");

          orderHistory = List<Map<String, dynamic>>.from(
            (data['orders'] ?? []).map((order) {
              print("🛒 Debug: Parsing order: $order");
              return {
                'id': order['id'],
                'status': order['status'],
                'total_price': order['total_price'],
                'created_at': order['created_at'],
                'order_items': order['order_items'] ?? [],
                'isExpanded': false,
              };
            }),
          );

          print("📋 Debug: Final orderHistory: $orderHistory");
        });
      } else {
        print(
          "❌ Debug: Failed to fetch details, status: ${response.statusCode}",
        );
        Get.snackbar('error'.tr, 'failed_fetch_customer_details'.tr);
      }
    } catch (e, stacktrace) {
      print("🔥 Debug: Exception: $e");
      print("🛠️ Debug: Stacktrace: $stacktrace");
      Get.snackbar('error'.tr, "${'something_went_wrong'.tr}: $e");
    } finally {
      isLoading.value = false;
      print("⏳ Debug: Loading set to false");
    }
  }

  void toggleExpansion(int index) {
    setState(() {
      orderHistory[index]['isExpanded'] = !orderHistory[index]['isExpanded'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final phone = Get.arguments?['phone'] ?? 'No phone';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'customer_details'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // Remove shadow
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (customerInfo == null) {
          return Center(child: Text('no_customer_data_found'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'view_manage_customer_info'.tr,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Customer Information Card
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Inside build -> LayoutBuilder (Customer Info Card)
                            Text(
                              customerInfo?['name'] ?? 'unknown_customer'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),

                            const SizedBox(height: 8),
                            Text(
                              "${'email'.tr}: ${customerInfo?['email'] ?? '-'}",
                            ),
                            Text(
                              "${'phone'.tr}: ${customerInfo?['phone'] ?? '-'}",
                            ),
                            Text(
                              "${'address'.tr}: ${orderHistory?[0]?['address'] ?? '-'}",
                            ),
                            Text(
                              "${'joined'.tr}: ${customerInfo?['first_order_create_date'] ?? '-'}",
                            ),

                            const SizedBox(height: 20),
                            Text(
                              "${'first_order'.tr}: ${(customerInfo?['first_order_create_date'] ?? '').toString().substring(0, 10)}",
                            ),
                            Text(
                              "${'last_order'.tr}: ${(customerInfo?['last_order_date'] ?? '').toString().substring(0, 10)}",
                            ),
                            Text(
                              "${'total_orders'.tr}: ${customerInfo?['total_order'] ?? 0}",
                            ),
                            Text(
                              "${'total_spent'.tr}: \$${customerInfo?['total_order_price'] ?? 0}",
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  customerInfo?['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${'email'.tr}: ${customerInfo?['email']}",
                                ),
                                Text(
                                  "${'phone'.tr}: ${customerInfo?['phone']}",
                                ),
                                Text(
                                  "${'address'.tr}: ${customerInfo?['address']}",
                                ),
                                Text(
                                  "${'joined'.tr}: ${customerInfo?['joined']}",
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "${'first_order'.tr}: ${(customerInfo?['first_order_create_date'] ?? '').toString().substring(0, 10)}",
                                ),
                                Text(
                                  "${'last_order'.tr}: ${(customerInfo?['last_order_date'] ?? '').toString().substring(0, 10)}",
                                ),
                                Text(
                                  "${'total_orders'.tr}: ${customerInfo?['total_order'] ?? 0}",
                                ),
                                Text(
                                  "${'total_spent'.tr}: \$${customerInfo?['total_order_price'] ?? 0}",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),

              Text(
                'order_history'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 15),

              // Order History List (using dynamic data)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile: Show orders as cards with expanded details on click
                    return Column(
                      children: List.generate(orderHistory.length, (index) {
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${'order_id'.tr}: ${orderHistory[index]['id']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        orderHistory[index]['isExpanded']
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                      ),
                                      onPressed: () {
                                        toggleExpansion(index);
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  "${'date'.tr}: ${orderHistory[index]['created_at']}",
                                ),
                                Text(
                                  "${'status'.tr}: ${orderHistory[index]['status']}",
                                  style: TextStyle(
                                    color:
                                        orderHistory[index]['status'] ==
                                            'Delivered'
                                        ? Colors.teal.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${'total'.tr}: ${orderHistory[index]['total_price']}",
                                ),
                                if (orderHistory[index]['isExpanded'])
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...List<Map<String, dynamic>>.from(
                                        orderHistory[index]['order_items'],
                                      ).map((item) {
                                        final itemData =
                                            item['item_json'] ?? {};
                                        return MenuItemCard(
                                          imagePath:
                                              (itemData['image'] ?? '')
                                                  .isNotEmpty
                                              ? itemData['image']
                                              : 'https://via.placeholder.com/150',
                                          itemName:
                                              itemData['item_name'] ??
                                              'Unknown Item',
                                          price: "\$${item['price'] ?? '0.00'}",
                                          hasCheckbox: false,
                                        );
                                      }),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  } else {
                    // Large screens: Use table format
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: orderHistory.map((order) {
                          return _buildOrderRow(
                            order['id'].toString(),
                            order['created_at'] ?? '-',
                            order['status'] ?? '-',
                            order['total_price'].toString(),
                            order['status'] == 'Delivered'
                                ? Colors.teal.shade100
                                : Colors.red.shade100,
                            order['status'] == 'Delivered'
                                ? Colors.teal.shade700
                                : Colors.red.shade700,
                            orderHistory.indexOf(
                              order,
                            ), // Pass the index for toggling
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrderRow(
    String orderId,
    String date,
    String status,
    String total,
    Color statusBgColor,
    Color statusTextColor,
    int index, // Add index to track the specific order
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with order details
          Row(
            children: <Widget>[
              Expanded(flex: 2, child: Text(orderId)),
              Expanded(flex: 2, child: Text(date)),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusTextColor, fontSize: 12),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 2, child: Text(total)),
              Expanded(
                flex: 1,
                child: TextButton.icon(
                  onPressed: () {
                    toggleExpansion(index);
                  },
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  label: Text(
                    'view'.tr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.zero, // optional: reduce padding if you want
                    minimumSize: Size(50, 30), // optional: control button size
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),

          // Conditionally display expanded details
          if (orderHistory[index]['isExpanded'])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List<Map<String, dynamic>>.from(
                  orderHistory[index]['order_items'] ?? [],
                ).map((item) {
                  final itemData = item['item_json'] ?? {};
                  return MenuItemCard(
                    imagePath: (itemData['image'] ?? '').isNotEmpty
                        ? itemData['image']
                        : 'https://via.placeholder.com/150', // ✅ fallback
                    itemName: itemData['item_name'] ?? 'Unknown Item',
                    price: "\$${item['price'] ?? '0.00'}",
                    hasCheckbox: false,
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final String imagePath;
  final String itemName;
  final String price;
  final bool hasCheckbox;

  const MenuItemCard({
    super.key,
    required this.imagePath,
    required this.itemName,
    required this.price,
    this.hasCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding:
            screenWidth <
                600 // Check for small screens (mobile)
            ? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0)
            : const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  // Adjust text size for smaller screens
                  Text(
                    itemName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth < 600
                          ? 14
                          : 16, // Smaller font on mobile
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Handle overflow on small screens
                  ),
                  if (hasCheckbox)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons
                            .check_box_outline_blank, // Or Icons.check_box for filled
                        size: screenWidth < 600
                            ? 16
                            : 18, // Smaller icon on mobile
                        color: Colors.teal,
                      ),
                    ),
                ],
              ),
            ),
            // Adjust price text size for smaller screens
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth < 600
                    ? 16
                    : 18, // Smaller price text on mobile
                color: const Color(0xFF1A237E), // A dark blue color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
