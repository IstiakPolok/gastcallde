import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/feature/calls/widgets/calldetaildilog.dart';
import 'package:http/http.dart' as http show get;
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class callScreen extends StatelessWidget {
  callScreen({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: isMobile ? AppBar(title: Text('calls_overview'.tr)) : null,
      drawer: isMobile
          ? ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return CustomDrawer(
                  selectedIndex: 1,
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
                    selectedIndex: 1,
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
                  return callDashboard(); // Assuming callDashboard is the widget for call logs
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CallEntry {
  final int id;
  final String date;
  final String time;
  final String phone;
  final String customer;
  final String type;
  bool callback;
  final String duration;
  final String summary;
  final String recording;

  CallEntry({
    required this.id,
    required this.date,
    required this.time,
    required this.phone,
    required this.customer,
    required this.type,
    required this.callback,
    required this.duration,
    required this.summary,
    required this.recording,
  });

  String get callbackStatus => callback ? "done" : "callback";
}

class callDashboard extends StatefulWidget {
  const callDashboard({super.key});

  @override
  State<callDashboard> createState() => _callDashboardState();
}

class _callDashboardState extends State<callDashboard> {
  String _selectedCallType = 'all_calls';
  String _selectedCallbackTab = 'all';
  DateTime _currentDate = DateTime.now();
  List<CallEntry> _apiCallLogs = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    fetchCalls();

    _searchController.addListener(() {
      _searchQuery.value = _searchController.text.trim().toLowerCase();
      setState(() {}); // refresh UI on search change
    });
  }

  Future<void> fetchCalls() async {
    print("📞 fetchCalls() called...");

    setState(() {
      _isLoading = true;
    });
    print("⏳ Loading state set to TRUE");

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      print("🔑 Token fetched: ${token != null ? '✅ Found' : '❌ Not Found'}");

      if (token == null) {
        print('⚠️ No token found, aborting API call...');
        setState(() => _isLoading = false);
        return;
      }

      final formattedDate =
          "${_currentDate.year}-${_currentDate.month.toString().padLeft(2, '0')}-${_currentDate.day.toString().padLeft(2, '0')}";
      print("📅 Fetching calls for date: $formattedDate");

      final url = "${Urls.baseUrl}/owner/user-calls/?date=$formattedDate";
      print("🌐 API URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📥 Response received | Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print("✅ Successfully decoded JSON | Total calls: ${jsonList.length}");

        final List<CallEntry> parsedCalls = jsonList.map((item) {
          try {
            final dateTime =
                DateTime.tryParse(item['created_at'] ?? '') ??
                DateTime.now(); // fallback to now if parsing fails
            final formattedDate =
                "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year.toString().substring(2)}";
            final formattedTime =
                "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

            final entry = CallEntry(
              date: formattedDate,
              time: formattedTime,
              id: item['id'],
              phone: item['phone'] ?? '-',
              customer: item['customer_name'] ?? 'Unknown',
              type: item['type'] ?? '-',
              callback: item['callback'] ?? false,
              duration:
                  "${double.tryParse(item['duration_seconds'].toString())?.toStringAsFixed(1) ?? '0'} sec",
              summary: item['summary'] ?? 'No summary available',
              recording: item['recording'] ?? '',
            );

            print(
              "📌 Parsed Call: ${entry.customer} | ${entry.phone} | ${entry.time}",
            );
            return entry;
          } catch (e) {
            print("⚠️ Error parsing item: $item | Error: $e");
            return CallEntry(
              id: 0,
              date: "-",
              time: "-",
              phone: "-",
              customer: "Unknown",
              type: "-",
              callback: false,
              duration: "-",
              summary: "-",
              recording: "",
            );
          }
        }).toList();

        setState(() {
          _apiCallLogs = parsedCalls;
        });

        print("📊 State updated with ${parsedCalls.length} calls");
      } else {
        print("❌ Failed to fetch calls | Response: ${response.body}");
        setState(() => _apiCallLogs = []);
      }
    } catch (e, stack) {
      print("🔥 Exception during fetchCalls: $e");
      print("📜 Stack Trace:\n$stack");
      setState(() => _apiCallLogs = []);
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("✅ Loading state set to FALSE");
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  void _showCardDetailsDialog(CallEntry entry, String? recordingUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('call_details'.tr),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${'date'.tr}: ${entry.date}'),
                Text('${'time'.tr}: ${entry.time}'),
                Text('${'customer'.tr}: ${entry.customer}'),
                Text('${'type'.tr}: ${entry.type}'),
                Text('${'callback_status'.tr}: ${entry.callbackStatus.tr}'),
                Text('${'duration'.tr}: ${entry.duration}'),
                if (recordingUrl != null)
                  TextButton(
                    onPressed: () {
                      // open link with url_launcher
                    },
                    child: Text("🔊 ${'play_recording'.tr}"),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr),
            ),
          ],
        );
      },
    );
  }

  void _onPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
    fetchCalls();
  }

  void _onNextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
    fetchCalls();
  }

  List<CallEntry> _getFilteredCallLogs() {
    return _apiCallLogs.where((entry) {
      // Filter by callback status
      bool matchesCallbackStatus =
          _selectedCallbackTab == 'all' ||
          entry.callbackStatus == _selectedCallbackTab;

      // Filter by call type
      bool matchesCallType = false;
      switch (_selectedCallType) {
        case 'all_calls':
          matchesCallType = true;
          break;
        case 'customer_services':
          matchesCallType = entry.type.toLowerCase().contains('service');
          break;
        case 'reservation':
          matchesCallType = entry.type.toLowerCase().contains('reservation');
          break;
        case 'order':
          matchesCallType = entry.type.toLowerCase().contains('order');
          break;
        default:
          matchesCallType = true;
      }

      // Filter by search query (phone or customer)
      bool matchesSearch =
          _searchQuery.value.isEmpty ||
          entry.phone.toLowerCase().contains(_searchQuery.value) ||
          entry.customer.toLowerCase().contains(_searchQuery.value);

      return matchesCallbackStatus && matchesCallType && matchesSearch;
    }).toList();
  }

  // Function to build the call type buttons
  Widget _buildCallTypeButton(String title, IconData icon) {
    bool isSelected = _selectedCallType == title;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _selectedCallType = title;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primaryColor
              : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          title.tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Function to build the callback status tabs
  Widget _buildCallbackTab(String title) {
    bool isSelected = _selectedCallbackTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCallbackTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title.tr,
          style: TextStyle(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen size for responsiveness
    bool isTablet = MediaQuery.of(context).size.width > 600;
    DateTime now = DateTime.now();
    bool isToday =
        _currentDate.year == now.year &&
        _currentDate.month == now.month &&
        _currentDate.day == now.day;
    String displayDate = isToday
        ? 'today'.tr
        : DateFormat('dd MMM yyyy').format(_currentDate);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'calls'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Get screen width to decide layout
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isCompact = screenWidth < 400;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () => _onPreviousDay(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayDate,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () => _onNextDay(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            Row(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'live_overview'.tr,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Call Type Tabs
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'call_type'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCallTypeButton('all_calls', Icons.phone),
                  _buildCallTypeButton(
                    'customer_services',
                    Icons.support_agent,
                  ),
                  _buildCallTypeButton('reservation', Icons.calendar_today),
                  _buildCallTypeButton('order', Icons.shopping_bag),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildCallbackTab('all'),
                _buildCallbackTab('done'),
                _buildCallbackTab('callback'),
                const Spacer(),
                if (isTablet)
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _searchController, // add controller
                      decoration: InputDecoration(
                        hintText: 'search'.tr,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery.value = value.trim().toLowerCase();
                        setState(() {}); // refresh UI when search changes
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Call log table/list with filtered logs
            _buildCallLog(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildCallLog(bool isTablet) {
    List<CallEntry> filteredLogs =
        _getFilteredCallLogs(); // Get the filtered list of calls

    if (filteredLogs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Text(
            _searchQuery.value.isNotEmpty
                ? 'no_search_results_found'.tr
                : 'no_calls_available'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Table header for tablets
        if (isTablet)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('date'.tr)),
                Expanded(flex: 2, child: Text('phone'.tr)),
                Expanded(flex: 2, child: Text('customer'.tr)),
                Expanded(flex: 2, child: Text('type'.tr)),
                Expanded(flex: 2, child: Text('callback'.tr)),
                Expanded(flex: 2, child: Text('duration'.tr)),
                Expanded(flex: 1, child: Text('action'.tr)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        // Display the filtered call logs
        ...filteredLogs.map((entry) {
          return Card(
            color: Colors.black.withOpacity(0.02),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isTablet
                  ? _buildTabletRow(entry)
                  : _buildPhoneColumn(entry),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTabletRow(CallEntry entry) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.date),
              Text(entry.time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(flex: 2, child: Text(entry.phone)),
        Expanded(flex: 2, child: Text(entry.customer)),
        Expanded(flex: 2, child: Text(entry.type)),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            // decoration: BoxDecoration(
            //   color: entry.callbackStatus == 'done'
            //       ? AppColors.primaryColor
            //       : Colors.orange.shade100,
            //   borderRadius: BorderRadius.circular(20),
            // ),
            child: Text(
              entry.callbackStatus.tr,
              style: TextStyle(
                color: entry.callbackStatus == 'Done'
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(flex: 2, child: Text(entry.duration)),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'view_details'.tr,
              icon: Icon(
                Icons.visibility_outlined,
                color: AppColors.primaryColor, // match your theme
                size: 20,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => CallDetailsDialog(entry),
                );
              },
            ),
          ),
          // Instead of Expanded(flex: 1, ...)
        ),
      ],
    );
  }

  // Widget for a single column on a phone
  Widget _buildPhoneColumn(CallEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'date'.tr}: ${entry.date}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${'time'.tr}: ${entry.time}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: entry.callbackStatus == 'done'
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                entry.callbackStatus.tr,
                style: TextStyle(
                  color: entry.callbackStatus == 'done'
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildPhoneDetailRow('customer', entry.customer),
        _buildPhoneDetailRow('phone', entry.phone),
        _buildPhoneDetailRow('type', entry.type),
        _buildPhoneDetailRow('duration', entry.duration),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CallDetailsDialog(entry),
              );
            },
            child: Text(
              'details'.tr,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for phone view details
  Widget _buildPhoneDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label.tr, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value),
        ],
      ),
    );
  }
}
