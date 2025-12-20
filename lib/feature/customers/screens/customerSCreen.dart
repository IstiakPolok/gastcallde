import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/feature/customers/screens/CustomerDetailsScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class Customerscreen extends StatelessWidget {
  Customerscreen({super.key});

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
                  selectedIndex: 5,
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
                    selectedIndex: 5,
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
                  return CustomerSectionScreen();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerSectionScreen extends StatefulWidget {
  const CustomerSectionScreen({super.key});

  @override
  State<CustomerSectionScreen> createState() => _CustomerSectionScreenState();
}

class _CustomerSectionScreenState extends State<CustomerSectionScreen> {
  DateTime selectedDate = DateTime.now();
  RxBool isLoading = true.obs;
  RxList<Map<String, String>> customerData = <Map<String, String>>[].obs;

  final String baseUrl = Urls.baseUrl;
  TextEditingController searchController = TextEditingController();
  RxList<Map<String, String>> filteredData = <Map<String, String>>[].obs;

  @override
  void initState() {
    super.initState();
    fetchAllCustomers(); // Fetch all customers on initial load

    searchController.addListener(() {
      final query = searchController.text;
      if (query.isEmpty) {
        fetchAllCustomers(); // Fetch all when search is cleared
      } else {
        searchCustomers(query); // Search API when user types
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void changeDate(int deltaDays) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: deltaDays));
    });
    fetchAllCustomers();
  }

  Future<void> fetchAllCustomers() async {
    isLoading.value = true;
    print("Fetching all customers (summary API)"); // debug

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      print("Access token: $token"); // debug

      if (token == null) {
        Get.snackbar('error'.tr, 'user_not_authenticated'.tr);
        print("Token is null, stopping fetch."); // debug
        isLoading.value = false;
        return;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/owner/customers/summary/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("HTTP status code: ${response.statusCode}"); // debug
      print("Response body: ${response.body}"); // debug

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        print("Parsed JSON data: $jsonData"); // debug

        customerData.value = jsonData.map<Map<String, String>>((item) {
          final mostRecent = item['most_recent_last'];
          String date = '';
          String time = '';
          String type = '';
          if (mostRecent != null) {
            if (mostRecent['created_at'] != null) {
              final createdAt = mostRecent['created_at'].toString();
              if (createdAt.length >= 16) {
                date = createdAt.substring(0, 10);
                time = createdAt.substring(11, 16);
              }
            }
            if (mostRecent['type'] != null) {
              type = mostRecent['type'].toString();
            }
          }
          return {
            'name': (item['name'] ?? '').toString(),
            'phone': (item['phone'] ?? '').toString(),
            'email': (item['email'] ?? '').toString(),
            'address': (item['address'] ?? '').toString(),
            'date': date,
            'time': time,
            'type': type,
            'noOfCall': (item['total_create']?.toString() ?? '0'),
            'lastOrders': '', // Not available in this API
          };
        }).toList();

        // Sort alphabetically by name
        customerData.value.sort(
          (a, b) =>
              a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()),
        );

        // Initially, filteredData shows all results
        filteredData.value = List.from(customerData);

        print("Final customerData list: ${customerData.value}"); // debug
      } else {
        Get.snackbar(
          'error'.tr,
          "${'failed_fetch_data'.tr}: ${response.statusCode}",
        );
        customerData.value = [];
        print("Failed to fetch data."); // debug
      }
    } catch (e) {
      Get.snackbar('error'.tr, "${'something_went_wrong'.tr}: $e");
      customerData.value = [];
      print("Exception caught: $e"); // debug
    } finally {
      isLoading.value = false;
      print("Fetch completed. isLoading: ${isLoading.value}"); // debug
    }
  }

  Future<void> searchCustomers(String query) async {
    isLoading.value = true;
    print("Searching customers (summary API) with query: $query"); // debug

    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        Get.snackbar('error'.tr, 'user_not_authenticated'.tr);
        isLoading.value = false;
        return;
      }

      final url = Uri.parse(
        "$baseUrl/owner/customers/summary/",
      ).replace(queryParameters: {'phone': query});

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Search HTTP status code: ${response.statusCode}"); // debug
      print("Search Response body: ${response.body}"); // debug

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        print("Search results: $jsonData"); // debug

        filteredData.value = jsonData.map<Map<String, String>>((item) {
          final mostRecent = item['most_recent_last'];
          String date = '';
          String time = '';
          String type = '';
          if (mostRecent != null) {
            if (mostRecent['created_at'] != null) {
              final createdAt = mostRecent['created_at'].toString();
              if (createdAt.length >= 16) {
                date = createdAt.substring(0, 10);
                time = createdAt.substring(11, 16);
              }
            }
            if (mostRecent['type'] != null) {
              type = mostRecent['type'].toString();
            }
          }
          return {
            'name': (item['name'] ?? '').toString(),
            'phone': (item['phone'] ?? '').toString(),
            'email': (item['email'] ?? '').toString(),
            'address': (item['address'] ?? '').toString(),
            'date': date,
            'time': time,
            'type': type,
            'noOfCall': (item['total_create']?.toString() ?? '0'),
            'lastOrders': '',
          };
        }).toList();

        // Sort search results alphabetically by name
        filteredData.value.sort(
          (a, b) =>
              a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()),
        );

        print("Search filtered results: ${filteredData.value}"); // debug
      } else {
        filteredData.value = [];
        print("Search failed with status: ${response.statusCode}"); // debug
      }
    } catch (e) {
      print("Search exception: $e"); // debug
      filteredData.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate =
        selectedDate.day == DateTime.now().day &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.year == DateTime.now().year
        ? "today".tr
        : "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80, // Increased height for better spacing
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'customer_section'.tr,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'live_overview_restaurant'.tr,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),

        // actions: [
        //   Column(
        //     crossAxisAlignment: CrossAxisAlignment.end,
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 12,
        //           vertical: 8,
        //         ),
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           borderRadius: BorderRadius.circular(10),
        //           boxShadow: [
        //             BoxShadow(
        //               color: Colors.grey.withOpacity(0.1),
        //               spreadRadius: 1,
        //               blurRadius: 5,
        //               offset: const Offset(0, 3),
        //             ),
        //           ],
        //         ),
        //         child: Row(
        //           children: [
        //             IconButton(
        //               icon: const Icon(Icons.chevron_left),
        //               onPressed: () => changeDate(-1),
        //             ),
        //             const SizedBox(width: 8),
        //             Text(
        //               displayDate,
        //               style: const TextStyle(color: Colors.grey),
        //             ),
        //             const SizedBox(width: 8),
        //             IconButton(
        //               icon: const Icon(Icons.chevron_right),
        //               onPressed: () => changeDate(1),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar and buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'search_by_phone'.tr,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                        ),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(width: 10),
                // ElevatedButton.icon(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.white, // Background color
                //     foregroundColor: Colors.teal, // Text and icon color
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10.0),
                //       side: BorderSide(color: Colors.grey.shade300),
                //     ),
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 15,
                //       vertical: 15,
                //     ),
                //     elevation: 0,
                //   ),
                //   icon: const Icon(Icons.filter_list),
                //   label: const Text(''), // Empty text to just show icon
                // ),
                // const SizedBox(width: 10),
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.teal, // Background color
                //     foregroundColor: Colors.white, // Text color
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10.0),
                //     ),
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 15,
                //     ),
                //     elevation: 0,
                //   ),
                //   child: const Text('Order'),
                // ),
              ],
            ),
            const SizedBox(height: 20),
            // Table Headers (for larger screens)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'name'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'phone'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'type'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'date'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'email'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'address'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'action'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            // Customer info in cards for mobile
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: filteredData.length,

                  // itemCount: customerData.length,
                  itemBuilder: (context, index) {
                    final data = filteredData[index];
                    // final data = customerData[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth <= 600) {
                          // Mobile layout: Show customer info in a Card
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${'name'.tr}: ${data['name']}"),
                                  Text("${'phone'.tr}: ${data['phone']}"),
                                  Text("${'type'.tr}: ${data['type']}"),
                                  Text("${'email'.tr}: ${data['email']}"),
                                  Text("${'address'.tr}: ${data['address']}"),
                                  Text("${'date'.tr}: ${data['date']}"),
                                  Text("${'time'.tr}: ${data['time']}"),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final result = await Get.to(
                                          () => CustomerDetailsScreen(),
                                          arguments: {'phone': data['phone']},
                                        );
                                        // Refresh customer list when returning
                                        if (result == true) {
                                          fetchAllCustomers();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                          side: const BorderSide(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'view'.tr,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Desktop layout: Use existing row layout
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(data['name']!)),
                                Expanded(flex: 2, child: Text(data['phone']!)),
                                Expanded(
                                  flex: 2,
                                  child: Text(data['Last Service type'] ?? ''),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${'date'.tr}: ${data['date']!}'),
                                      Text('${'time'.tr}: ${data['time']!}'),
                                    ],
                                  ),
                                ),
                                Expanded(flex: 3, child: Text(data['email']!)),
                                Expanded(
                                  flex: 2,
                                  child: Text(data['address']!),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final result = await Get.to(
                                        () => CustomerDetailsScreen(),
                                        arguments: {'phone': data['phone']},
                                      );
                                      // Refresh customer list when returning
                                      if (result == true) {
                                        fetchAllCustomers();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        side: const BorderSide(
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.remove_red_eye_outlined,
                                          size: 18,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'view'.tr,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
