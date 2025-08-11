import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/reservastion/widgets/ReservationForm.dart';
import 'package:gastcallde/feature/reservastion/widgets/gridViewTableView.dart';
import 'package:get/get.dart';

class ReservationScreen extends StatelessWidget {
  ReservationScreen({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: isMobile
          ? AppBar(title: const Text('Reservations Overview'))
          : null,
      drawer: isMobile
          ? ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return CustomDrawer(
                  selectedIndex: 3,
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
                    selectedIndex: 3,
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
                  return RestaurantDashboard(); // Assuming ReservationDashboard is the widget for Reservation logs
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantDashboard extends StatelessWidget {
  RestaurantDashboard({super.key});

  final ValueNotifier<bool> isListView = ValueNotifier<bool>(true);

  final List<String> dataList = List.generate(20, (index) => 'Item $index');

  // Mock data for the table
  static const List<Map<String, dynamic>> _tableData = [
    {
      'table': 'Table01',
      'time': '6:30 pm - 8:00 pm',
      'person': 5,
      'name': 'Rash Marchant',
      'phone': '+98 7478 33',
      'status': 'Walk-in',
    },
    {
      'table': 'Table02',
      'time': '6:30 pm - 8:00 pm',
      'person': 5,
      'name': 'Toma kdfhg',
      'phone': '+98 7478 33',
      'status': 'Reserved',
    },
    {
      'table': 'Table03',
      'time': '6:30 pm - 8:00 pm',
      'person': 5,
      'name': 'Thfkj ksgfiu',
      'phone': '+98 7478 33',
      'status': 'Cancel',
    },
    {
      'table': 'Table03',
      'time': '6:30 pm - 8:00 pm',
      'person': 5,
      'name': 'Rjhbflud Biusefriu',
      'phone': '+98 7478 33',
      'status': 'Finished',
    },
    {
      'table': 'Table03',
      'time': '6:30 pm - 8:00 pm',
      'person': 5,
      'name': 'Ehsofn Gsjkf',
      'phone': '+98 7478 33',
      'status': 'Walk-in',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          // Navigate to the OrderEntryScreen
          Get.to(ReservationFormPage());
        },
        tooltip: 'Add new order',
        child: const Icon(Icons.add),
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context),
              const SizedBox(height: 20),

              // Responsive Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Tablet layout: cards in a row
                    return const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Guests',
                            value: '84',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Reservation',
                            value: '12',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _SummaryCard(title: 'Walk-In', value: '10'),
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout: cards in a column
                    return const Column(
                      children: [
                        _SummaryCard(title: 'Total Guests', value: '84'),
                        SizedBox(height: 16),
                        _SummaryCard(title: 'Reservation', value: '12'),
                        SizedBox(height: 16),
                        _SummaryCard(title: 'Walk-In', value: '10'),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  const Text(
                    'Table Reservation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: isListView,
                          builder: (context, isListViewActive, child) {
                            return ElevatedButton(
                              onPressed: () {
                                isListView.value = true; // Set to ListView
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: isListViewActive
                                    ? AppColors.primaryColor
                                    : Colors.grey[300],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                ),
                                child: Text(
                                  'List View',
                                  style: TextStyle(
                                    color: isListViewActive
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        ValueListenableBuilder<bool>(
                          valueListenable: isListView,
                          builder: (context, isListViewActive, child) {
                            return ElevatedButton(
                              onPressed: () {
                                isListView.value = false; // Set to GridView
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: !isListViewActive
                                    ? AppColors.primaryColor
                                    : Colors.grey[300],
                              ),

                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                ),
                                child: Text(
                                  'Grid View',
                                  style: TextStyle(
                                    color: !isListViewActive
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  ValueListenableBuilder<bool>(
                    valueListenable: isListView,
                    builder: (context, isListViewActive, child) {
                      return Container(
                        // Adjust container height
                        // Green when GridView is active
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // First text to show which view is active

                              // Conditional Column: Different content for ListView vs GridView
                              if (isListViewActive)
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // _buildTableView(),
                                      const SizedBox(height: 20),

                                      _buildTableStatus(),
                                      const SizedBox(height: 20),

                                      // Search bar and 'All Status' button
                                      _buildSearchBar(context),
                                      const SizedBox(height: 20),

                                      // Responsive Table
                                      _buildDataTable(context),
                                    ],
                                  ),
                                )
                              else
                                Column(children: [TableReservationGrid()]),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // View toggle and Table Status
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the main header
  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;
    return isMobile
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reservations & Walk-Ins',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Live Overview of your restaurant's",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.chevron_left, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Today',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          '15 July, 2025',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  // SizedBox(height: 10),
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //     Get.to(ReservationFormPage());
                  //   },
                  //   icon: const Icon(Icons.add, size: 20),
                  //   label: const Text('Add Reservation'),
                  //   style: ElevatedButton.styleFrom(
                  //     foregroundColor: Colors.white,
                  //     backgroundColor: AppColors.primaryColor,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 16,
                  //       vertical: 12,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reservations & Walk-Ins',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Live Overview of your restaurant's",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                    child: const Row(
                      children: [
                        Icon(Icons.chevron_left, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Today',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          '15 July, 2025',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //     Get.to(ReservationFormPage());
                  //   },
                  //   icon: const Icon(Icons.add, size: 20),
                  //   label: const Text('Add Reservation'),
                  //   style: ElevatedButton.styleFrom(
                  //     foregroundColor: Colors.white,
                  //     backgroundColor: AppColors.primaryColor,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 16,
                  //       vertical: 12,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          );
  }

  // Helper method to build the view toggle and table status
  Widget _buildTableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List/Grid view toggle
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ToggleButtons(
            isSelected: const [true, false],
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
            selectedColor: Colors.white,
            fillColor: AppColors.primaryColor,
            borderColor: Colors.transparent,
            selectedBorderColor: Colors.transparent,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'List View',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Grid View',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            onPressed: (index) {},
          ),
        ),
      ],
    );
  }

  Widget _buildTableStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List/Grid view toggle

        // Table Status row
        const Text(
          'Table Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 1; i <= 10; i++)
                _TableStatusTag(label: 'Table $i', isActive: i <= 2),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build search bar and filter button
  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sort_by_alpha, size: 20),
          label: const Text('All Status'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Helper method to build the responsive data table
  Widget _buildDataTable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust table layout based on screen width
          if (constraints.maxWidth > 600) {
            // Wider screen: use a DataTable
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Table')),
                  DataColumn(label: Text('Time')),
                  DataColumn(label: Text('Person')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Status')),
                ],
                rows: _tableData.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['table'] as String)),
                      DataCell(Text(item['time'] as String)),
                      DataCell(
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(item['person'].toString()),
                          ],
                        ),
                      ),
                      DataCell(Text(item['name'] as String)),
                      DataCell(Text(item['phone'] as String)),
                      DataCell(_StatusTag(status: item['status'] as String)),
                    ],
                  );
                }).toList(),
              ),
            );
          } else {
            // Narrower screen: use a ListView of custom list items
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tableData.length,
              itemBuilder: (context, index) {
                final item = _tableData[index];
                return _MobileTableItem(item: item);
              },
            );
          }
        },
      ),
    );
  }
}

// A custom stateless widget for the summary cards
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.people, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// A custom stateless widget for the table status tags
class _TableStatusTag extends StatelessWidget {
  const _TableStatusTag({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(label),
        backgroundColor: isActive ? AppColors.primaryColor : Colors.white,
        side: BorderSide(
          color: isActive
              ? AppColors.primaryColor
              : Colors.grey.withOpacity(0.3),
        ),
        labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// A custom stateless widget for the status tags within the table
class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status});

  final String status;

  Color _getColor() {
    switch (status) {
      case 'Walk-in':
        return Colors.blue[100]!;
      case 'Reserved':
        return Colors.green[100]!;
      case 'Cancel':
        return Colors.red[100]!;
      case 'Finished':
        return Colors.green[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case 'Walk-in':
        return Colors.blue[800]!;
      case 'Reserved':
        return Colors.green[800]!;
      case 'Cancel':
        return Colors.red[800]!;
      case 'Finished':
        return Colors.green[800]!;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: _getTextColor(), fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Custom widget for mobile table view
class _MobileTableItem extends StatelessWidget {
  const _MobileTableItem({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Table: ${item['table']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _StatusTag(status: item['status'] as String),
              ],
            ),
            const SizedBox(height: 8),
            Text('Time: ${item['time']}'),
            const SizedBox(height: 4),
            Text('Name: ${item['name']}'),
            const SizedBox(height: 4),
            Text('Phone: ${item['phone']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text('Person: ${item['person']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
