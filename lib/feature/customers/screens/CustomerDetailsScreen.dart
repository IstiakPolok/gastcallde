import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
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
  List<Map<String, dynamic>> reservations = [];
  List<Map<String, dynamic>> services = [];
  RxBool isLoading = true.obs;
  int? customerId;

  // Text controllers for edit dialog
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> updateCustomer() async {
    if (customerId == null) {
      Get.snackbar('error'.tr, 'customer_id_not_found'.tr);
      return;
    }

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        Get.snackbar('error'.tr, 'user_not_authenticated'.tr);
        return;
      }

      final url = Uri.parse("${Urls.baseUrl}/owner/customers/$customerId/");
      print("🌐 Debug: Updating customer at: $url");

      final body = jsonEncode({
        'customer_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("📡 Debug: Update response status: ${response.statusCode}");
      print("📦 Debug: Update response body: ${response.body}");

      if (response.statusCode == 200) {
        Get.back(); // Close dialog
        Get.snackbar(
          'success'.tr,
          'customer_updated_successfully'.tr,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
        // Refresh customer details
        fetchCustomerDetails();
      } else {
        Get.snackbar('error'.tr, 'failed_to_update_customer'.tr);
      }
    } catch (e) {
      print("🔥 Debug: Exception in updateCustomer: $e");
      Get.snackbar('error'.tr, "${'something_went_wrong'.tr}: $e");
    }
  }

  void _showEditDialog() {
    // Pre-fill the controllers with current data
    _nameController.text = customerInfo?['customer_name'] ?? '';
    _emailController.text = customerInfo?['email'] ?? '';
    _phoneController.text = customerInfo?['phone'] ?? '';
    _addressController.text = customerInfo?['address'] ?? '';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, color: AppColors.primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'edit_customer'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              _buildEditField(
                controller: _nameController,
                label: 'customer_name'.tr,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: _emailController,
                label: 'email'.tr,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: _phoneController,
                label: 'phone'.tr,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                controller: _addressController,
                label: 'address'.tr,
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: updateCustomer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'save'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
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
        "${Urls.baseUrl}/owner/customers/",
      ).replace(queryParameters: {'search': phone});
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

        // The API returns a list of customers matching the search
        if (data is List && data.isNotEmpty) {
          // Find the customer with exact phone match
          final matchingCustomer = data.firstWhere(
            (customer) => customer['phone'] == phone,
            orElse: () => data[0], // fallback to first result
          );

          print("👤 Debug: Matching customer: $matchingCustomer");

          // Now fetch the detailed order history for this specific customer
          await fetchCustomerOrders(matchingCustomer);
        } else {
          print("❌ Debug: No customers found in response");
          Get.snackbar('error'.tr, 'customer_not_found'.tr);
        }
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

  Future<void> fetchCustomerOrders(Map<String, dynamic> customer) async {
    // Store customer ID for edit functionality
    customerId = customer['id'];
    print("🆔 Debug: Customer ID stored: $customerId");

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) return;

      // Fetch orders for this customer using the endpoint
      final encodedPhone = Uri.encodeComponent(customer['phone'] ?? '');
      final orderUrl = Uri.parse(
        "${Urls.baseUrl}/owner/orders/by-phone/?phone=$encodedPhone",
      );
      print("🌐 Debug: Fetching orders from: $orderUrl");

      final orderResponse = await http.get(
        orderUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📡 Debug: Order response status: ${orderResponse.statusCode}");
      print("📦 Debug: Order response body: ${orderResponse.body}");

      if (orderResponse.statusCode == 200) {
        final orderData = jsonDecode(orderResponse.body);
        print("✅ Debug: Order data decoded: $orderData");

        setState(() {
          // Use customer data directly from the API response
          customerInfo = orderData['customer'] ?? {};
          // Also store the customer ID from the response if available
          if (customerInfo?['id'] != null) {
            customerId = customerInfo!['id'];
          }
          print("👤 Debug: Final customerInfo: $customerInfo");

          // Parse orders
          orderHistory = List<Map<String, dynamic>>.from(
            (orderData['orders'] ?? []).map((order) {
              return {
                'id': order['id'],
                'status': order['status'] ?? '-',
                'total_price': order['total_price'] ?? '0.00',
                'created_at': order['created_at'] ?? '',
                'address': order['address'] ?? '',
                'order_type': order['order_type'] ?? '',
                'order_items': (order['order_items'] ?? []).map((item) {
                  final itemJson = item['item_json'] ?? {};
                  return {
                    'id': item['id'],
                    'quantity': item['quantity'],
                    'price': item['price'],
                    'extras': item['extras'] ?? '',
                    'extras_price': item['extras_price'] ?? '',
                    'special_instructions': item['special_instructions'] ?? '',
                    'item_json': {
                      'id': itemJson['id'],
                      'item_name':
                          itemJson['item_name'] ?? itemJson['name'] ?? '',
                      'image': itemJson['image'] ?? '',
                      'price': itemJson['price'] ?? '',
                      'status': itemJson['status'] ?? '',
                      'category': itemJson['category'] ?? '',
                      'discount': itemJson['discount'] ?? '',
                      'description': itemJson['description'] ?? '',
                      'restaurant_id': itemJson['restaurant_id'] ?? '',
                      'preparation_time': itemJson['preparation_time'] ?? '',
                    },
                  };
                }).toList(),
                'isExpanded': false,
              };
            }),
          );

          // Parse reservations
          reservations = List<Map<String, dynamic>>.from(
            (orderData['reservations'] ?? []).map((reservation) {
              return {
                'id': reservation['id'],
                'date': reservation['date'] ?? '',
                'from_time': reservation['from_time'] ?? '',
                'to_time': reservation['to_time'] ?? '',
                'guest_no': reservation['guest_no'] ?? '',
                'status': reservation['status'] ?? '',
                'table_name': reservation['table_name']?['table_name'] ?? 'N/A',
                'comment': reservation['comment'] ?? '',
                'isExpanded': false,
              };
            }),
          );

          // Parse services
          services = List<Map<String, dynamic>>.from(
            (orderData['services'] ?? []).map((service) {
              return {
                'id': service['id'] ?? 0,
                'name': service['name'] ?? '',
                'description': service['description'] ?? '',
                'price': service['price'] ?? 0.0,
                'date': service['date'] ?? '',
              };
            }),
          );

          print("📋 Debug: Final orderHistory: $orderHistory");
          print("📅 Debug: Final reservations: $reservations");
          print("🛠️ Debug: Final services: $services");
        });
      } else {
        // If order fetch fails, just use basic customer info
        setState(() {
          customerInfo = {
            'customer_name': customer['customer_name'] ?? customer['name'],
            'email': customer['email'],
            'phone': customer['phone'],
            'address': customer['address'],
            'total_order': 0,
            'total_order_price': 0.0,
            'first_order_date': null,
            'last_order_date': null,
          };
          orderHistory = [];
          reservations = [];
          services = [];
        });
        print("⚠️ Debug: No orders found, using basic customer info only");
      }
    } catch (e, stacktrace) {
      print("🔥 Debug: Exception in fetchCustomerOrders: $e");
      print("🛠️ Debug: Stacktrace: $stacktrace");
      // Still set basic customer info even if order fetch fails
      setState(() {
        customerInfo = {
          'customer_name': customer['customer_name'] ?? customer['name'],
          'email': customer['email'],
          'phone': customer['phone'],
          'address': customer['address'],
          'total_order': 0,
          'total_order_price': 0.0,
          'first_order_date': null,
          'last_order_date': null,
        };
        orderHistory = [];
        reservations = [];
        services = [];
      });
    }
  }

  void toggleExpansion(int index) {
    setState(() {
      orderHistory[index]['isExpanded'] = !orderHistory[index]['isExpanded'];
    });
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '-';
    try {
      final dateStr = date.toString();
      if (dateStr.length >= 10) {
        return dateStr.substring(0, 10);
      }
      return dateStr;
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = Get.arguments?['phone'] ?? 'No phone';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () {
            Navigator.pop(
              context,
              true,
            ); // Return true to indicate refresh needed
          },
        ),
        title: Text(
          'customer_details'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, size: 20),
            ),
            onPressed: _showEditDialog,
            tooltip: 'edit_customer'.tr,
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (customerInfo == null) {
          return Center(child: Text('no_customer_data_found'.tr));
        }

        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),

                // Customer Information Card
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Card(
                        elevation: 8,
                        shadowColor: AppColors.primaryColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                AppColors.primaryColor.withOpacity(0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        customerInfo?['customer_name'] ??
                                            'unknown_customer'.tr,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: Color.lerp(
                                            AppColors.primaryColor,
                                            Colors.black,
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(Icons.edit, size: 20),
                                      ),
                                      onPressed: _showEditDialog,
                                      tooltip: 'edit_customer'.tr,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.email_outlined,
                                  'email'.tr,
                                  customerInfo?['email'] ?? '-',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.phone_outlined,
                                  'phone'.tr,
                                  customerInfo?['phone'] ?? '-',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.location_on_outlined,
                                  'address'.tr,
                                  customerInfo?['address'] ?? '-',
                                ),
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        Icons.shopping_bag_outlined,
                                        'total_orders'.tr,
                                        '${customerInfo?['total_order'] ?? 0}',
                                        AppColors.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        Icons.euro_outlined,
                                        'total_spent'.tr,
                                        '€${customerInfo?['total_order_price']?.toStringAsFixed(2) ?? '0.00'}',
                                        AppColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.calendar_today_outlined,
                                  'first_order'.tr,
                                  _formatDate(
                                    customerInfo?['first_order_date'],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.calendar_month_outlined,
                                  'last_order'.tr,
                                  _formatDate(customerInfo?['last_order_date']),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Card(
                        elevation: 8,
                        shadowColor: AppColors.primaryColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.teal.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Text(
                                            customerInfo?['customer_name'] ??
                                                'Unknown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 28,
                                              color: Color.lerp(
                                                AppColors.primaryColor,
                                                Colors.black,
                                                0.5,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.edit,
                                                size: 20,
                                              ),
                                            ),
                                            onPressed: _showEditDialog,
                                            tooltip: 'edit_customer'.tr,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(),
                                      const SizedBox(height: 16),
                                      _buildInfoRow(
                                        Icons.email_outlined,
                                        'email'.tr,
                                        customerInfo?['email'] ?? '-',
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.phone_outlined,
                                        'phone'.tr,
                                        customerInfo?['phone'] ?? '-',
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.location_on_outlined,
                                        'address'.tr,
                                        customerInfo?['address'] ?? '-',
                                      ),
                                      Row(
                                        children: [
                                          _buildStatCard(
                                            Icons.shopping_bag_outlined,
                                            'total_orders'.tr,
                                            '${customerInfo?['total_order'] ?? 0}',
                                            AppColors.primaryColor,
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatCard(
                                            Icons.euro_outlined,
                                            'total_spent'.tr,
                                            '€${customerInfo?['total_order_price']?.toStringAsFixed(2) ?? '0.00'}',
                                            AppColors.primaryColor,
                                          ),
                                          const SizedBox(width: 16),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.primaryColor
                                                    .withOpacity(0.2),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_outlined,
                                                  color: AppColors.primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'first_order'.tr,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDate(
                                                    customerInfo?['first_order_date'],
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'last_order'.tr,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDate(
                                                    customerInfo?['last_order_date'],
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(
                  'order_history'.tr,
                  Icons.receipt_long,
                  AppColors.primaryColor,
                ),
                const SizedBox(height: 16),

                // Order History List (using dynamic data)
                orderHistory.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'no_orders_found'.tr,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 600) {
                            // Mobile: Show orders as beautiful cards
                            return Column(
                              children: List.generate(orderHistory.length, (
                                index,
                              ) {
                                final order = orderHistory[index];
                                final isDelivered =
                                    order['status'] == 'Delivered';
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryColor.withOpacity(
                                          0.05,
                                        ),
                                        Colors.white,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.2,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => toggleExpansion(index),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    isDelivered
                                                        ? Icons
                                                              .check_circle_outline
                                                        : Icons
                                                              .pending_outlined,
                                                    color:
                                                        AppColors.primaryColor,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${'order'.tr} #${order['id']}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors
                                                              .grey
                                                              .shade800,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _formatDate(
                                                          order['created_at'],
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  order['isExpanded']
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .primaryColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    order['status'],
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "€${order['total_price']}",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (order['isExpanded']) ...[
                                              const SizedBox(height: 16),
                                              const Divider(),
                                              const SizedBox(height: 12),
                                              ...List<Map<String, dynamic>>.from(
                                                order['order_items'],
                                              ).map((item) {
                                                final itemData =
                                                    item['item_json'] ?? {};
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          image:
                                                              (itemData['image'] ??
                                                                      '')
                                                                  .isNotEmpty
                                                              ? DecorationImage(
                                                                  image: NetworkImage(
                                                                    itemData['image'],
                                                                  ),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : null,
                                                        ),
                                                        child:
                                                            (itemData['image'] ??
                                                                    '')
                                                                .isEmpty
                                                            ? Icon(
                                                                Icons.fastfood,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400,
                                                              )
                                                            : null,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          itemData['item_name'] ??
                                                              'Unknown Item',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "€${item['price'] ?? '0.00'}",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .grey
                                                              .shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          } else {
                            // Large screens: Enhanced table format
                            return Column(
                              children: [
                                // Table Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryColor.withOpacity(0.1),
                                        AppColors.primaryColor.withOpacity(
                                          0.05,
                                        ),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'order_id'.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'date'.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'status'.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'total'.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          ' '.tr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Table Body
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(12),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: orderHistory.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final order = entry.value;
                                      return _buildOrderRow(
                                        order['id'].toString(),
                                        _formatDate(order['created_at']),
                                        order['status'] ?? '-',
                                        '€${order['total_price']}',
                                        order['address'] ?? '',
                                        Colors.transparent,
                                        AppColors.primaryColor,
                                        index,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),

                // Reservations Section
                const SizedBox(height: 32),
                _buildSectionHeader(
                  'reservations'.tr,
                  Icons.event_seat,
                  AppColors.primaryColor,
                ),
                const SizedBox(height: 16),

                reservations.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'no_reservations_found'.tr,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: reservations.map((reservation) {
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
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
                                        "${'reservation_id'.tr}: ${reservation['id']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          reservation['status'] ?? 'N/A',
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text("${'date'.tr}: ${reservation['date']}"),
                                  Text(
                                    "${'time'.tr}: ${reservation['from_time']} - ${reservation['to_time']}",
                                  ),
                                  Text(
                                    "${'table'.tr}: ${reservation['table_name']}",
                                  ),
                                  Text(
                                    "${'guests'.tr}: ${reservation['guest_no']}",
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                // Services Section
                const SizedBox(height: 32),
                _buildSectionHeader(
                  'services'.tr,
                  Icons.room_service,
                  AppColors.primaryColor,
                ),
                const SizedBox(height: 16),

                services.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'no_services_found'.tr,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: services.map((service) {
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service['name'] ?? 'Unknown Service',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (service['description'] != null &&
                                      service['description'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        service['description'],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (service['date'] != null &&
                                          service['date'].isNotEmpty)
                                        Text(
                                          "${'date'.tr}: ${service['date']}",
                                        ),
                                      Text(
                                        "€${service['price']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color.lerp(color, Colors.black, 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color.lerp(color, Colors.black, 0.3), size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.lerp(color, Colors.black, 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetail(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(
    String orderId,
    String date,
    String status,
    String total,
    String address,
    Color statusBgColor,
    Color statusTextColor,
    int index,
  ) {
    final order = orderHistory[index];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => toggleExpansion(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '#$orderId',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        date,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        total,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Icon(
                        order['isExpanded']
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (order['isExpanded'])
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_items'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List<Map<String, dynamic>>.from(
                    order['order_items'] ?? [],
                  ).map((item) {
                    final itemData = item['item_json'] ?? {};
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                              image: (itemData['image'] ?? '').isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(itemData['image']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (itemData['image'] ?? '').isEmpty
                                ? Icon(
                                    Icons.fastfood,
                                    color: Colors.grey.shade400,
                                    size: 30,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemData['item_name'] ?? 'Unknown Item',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (itemData['description'] != null)
                                  Text(
                                    itemData['description'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            "€${item['price'] ?? '0.00'}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
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
                        color: AppColors.primaryColor,
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
