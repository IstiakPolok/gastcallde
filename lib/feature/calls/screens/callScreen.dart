import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/calls/widgets/calldetaildilog.dart';
import 'package:intl/intl.dart';

class callScreen extends StatelessWidget {
  callScreen({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: isMobile
          ? AppBar(title: const Text('Restaurant Overview'))
          : null,
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
  final String date;
  final String time;
  final String phone;
  final String customer;
  final String type;
  final String callbackStatus;
  final String duration;

  CallEntry({
    required this.date,
    required this.time,
    required this.phone,
    required this.customer,
    required this.type,
    required this.callbackStatus,
    required this.duration,
  });
}

// Sample data for the call log
final List<CallEntry> callLogs = [
  CallEntry(
    date: '02-07-25',
    time: '06:00 pm',
    phone: '9347 48908',
    customer: 'John Doe',
    type: 'Order',
    callbackStatus: 'Done',
    duration: '1:12 min',
  ),
  CallEntry(
    date: '02-07-25',
    time: '06:00 pm',
    phone: '9347 48908',
    customer: 'Jane Doe',
    type: 'Reservation',
    callbackStatus: 'Callback',
    duration: '1:12 min',
  ),
  CallEntry(
    date: '02-07-25',
    time: '06:00 pm',
    phone: '9347 48908',
    customer: 'Peter Pan',
    type: 'Customer Service',
    callbackStatus: 'Done',
    duration: '1:12 min',
  ),
  CallEntry(
    date: '02-07-25',
    time: '06:00 pm',
    phone: '9347 48908',
    customer: 'Mary Jane',
    type: 'Reservation',
    callbackStatus: 'Callback',
    duration: '1:12 min',
  ),
  CallEntry(
    date: '02-07-25',
    time: '06:00 pm',
    phone: '9347 48908',
    customer: 'Bruce Wayne',
    type: 'Order',
    callbackStatus: 'Done',
    duration: '1:12 min',
  ),
];

class callDashboard extends StatefulWidget {
  const callDashboard({super.key});

  @override
  State<callDashboard> createState() => _callDashboardState();
}

class _callDashboardState extends State<callDashboard> {
  String _selectedCallType = 'All Calls';
  String _selectedCallbackTab = 'All';
  DateTime _currentDate = DateTime.now();

  // Function to format the date to "15 July, 2025"
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM, yyyy').format(date);
  }

  // Function to handle the left arrow click (previous day)
  void _onPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(Duration(days: 1));
    });
  }

  void _showCardDetailsDialog(CallEntry entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Call Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Date: ${entry.date}'),
                Text('Time: ${entry.time}'),
                Text('Phone: ${entry.phone}'),
                Text('Customer: ${entry.customer}'),
                Text('Type: ${entry.type}'),
                Text('Callback Status: ${entry.callbackStatus}'),
                Text('Duration: ${entry.duration}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle the right arrow click (next day)
  void _onNextDay() {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: 1));
    });
  }

  // Function to filter the call logs based on selected filters
  List<CallEntry> _getFilteredCallLogs() {
    return callLogs.where((entry) {
      // Filter by callback status
      bool matchesCallbackStatus =
          _selectedCallbackTab == 'All' ||
          entry.callbackStatus == _selectedCallbackTab;

      // Filter by call type
      bool matchesCallType =
          _selectedCallType == 'All Calls' || entry.type == _selectedCallType;

      // Return true if both filters match
      return matchesCallbackStatus && matchesCallType;
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
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
          title,
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Calls',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              //color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _onPreviousDay, // Go to the previous day
                ),
                const Text(
                  'Today',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _onNextDay, // Go to the next day
                ),

                // Display the current date
                Text(
                  _formatDate(_currentDate),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text('Live Overview of your restaurant\'s'),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Call Type Tabs
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Call Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCallTypeButton('All Calls', Icons.phone),
                  _buildCallTypeButton(
                    'Customer Services',
                    Icons.support_agent,
                  ),
                  _buildCallTypeButton('Reservation', Icons.calendar_today),
                  _buildCallTypeButton('Order', Icons.shopping_bag),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Callback tabs and search bar
            Row(
              children: [
                _buildCallbackTab('All'),
                _buildCallbackTab('Done'),
                _buildCallbackTab('Callback'),
                const Spacer(),
                if (isTablet)
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
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

  // Widget to build the call log table (tablet) or list (phone)
  Widget _buildCallLog(bool isTablet) {
    List<CallEntry> filteredLogs =
        _getFilteredCallLogs(); // Get the filtered list of calls

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
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Date')),
                Expanded(flex: 2, child: Text('Phone')),
                Expanded(flex: 2, child: Text('Customer')),
                Expanded(flex: 1, child: Text('Type')),
                Expanded(flex: 2, child: Text('Call back')),
                Expanded(flex: 2, child: Text('Duration')),
                Expanded(flex: 1, child: Text('Action')),
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
        }).toList(),
      ],
    );
  }

  // Widget for a single row on a tablet
  Widget _buildTabletRow(CallEntry entry) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${entry.date}'),
              Text('${entry.time}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(flex: 2, child: Text(entry.phone)),
        Expanded(flex: 2, child: Text(entry.customer)),
        Expanded(flex: 1, child: Text(entry.type)),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            // decoration: BoxDecoration(
            //   color: entry.callbackStatus == 'Done'
            //       ? AppColors.primaryColor
            //       : Colors.orange.shade100,
            //   borderRadius: BorderRadius.circular(20),
            // ),
            child: Text(
              entry.callbackStatus,
              style: TextStyle(
                color: entry.callbackStatus == 'Done'
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(flex: 2, child: Text(entry.duration)),
        Expanded(
          flex: 0,
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CallDetailsDialog(entry),
              );
            },
            child: Text(
              'Details',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              // This prevents text from wrapping
              maxLines: 1, // Ensure it stays in one line
            ),
          ),
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
                  'Date: ${entry.date}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: ${entry.time}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: entry.callbackStatus == 'Done'
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                entry.callbackStatus,
                style: TextStyle(
                  color: entry.callbackStatus == 'Done'
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
        _buildPhoneDetailRow('Customer', entry.customer),
        _buildPhoneDetailRow('Phone', entry.phone),
        _buildPhoneDetailRow('Type', entry.type),
        _buildPhoneDetailRow('Duration', entry.duration),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Details',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
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
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value),
        ],
      ),
    );
  }
}
