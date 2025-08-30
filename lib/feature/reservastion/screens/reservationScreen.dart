import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/reservastion/controllers/reservationDashController.dart';
import 'package:gastcallde/feature/reservastion/widgets/ReservationForm.dart';
import 'package:gastcallde/feature/reservastion/widgets/gridViewTableView.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

class RestaurantDashboard extends StatefulWidget {
  RestaurantDashboard({super.key});

  @override
  _RestaurantDashboardState createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> {
  late Future<List<Reservation>> reservations;
  late Future<List<TableStatus>> tableStatuses;
  late Future<Map<String, dynamic>>
  reservationStats; // Ensure this is initialized
  final ValueNotifier<bool> isListView = ValueNotifier<bool>(true);
  DateTime selectedDate = DateTime.now();

  // @override
  // void initState() {
  //   super.initState();
  //   String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   reservations = fetchReservations(todayDate); // Fetch reservations for today
  // }

  @override
  void initState() {
    super.initState();
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    reservationStats = fetchReservationStats(
      DateFormat('yyyy-MM-dd').format(selectedDate),
    );
    reservations = fetchReservations(
      DateFormat('yyyy-MM-dd').format(selectedDate),
    );
    tableStatuses = fetchTableStatus(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  void changeDate(int dayOffset) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: dayOffset));
      reservationStats = fetchReservationStats(
        DateFormat('yyyy-MM-dd').format(selectedDate),
      );
      reservations = fetchReservations(
        DateFormat('yyyy-MM-dd').format(selectedDate),
      ); // Re-fetch reservations for the new date
    });
  }

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
              _HeaderSection(
                selectedDate: selectedDate, // Pass the parent's selectedDate
                onDateChange: changeDate,
              ), // Pass the `changeDate` callback to update the date
              const SizedBox(height: 20),

              // Responsive Summary Cards
              FutureBuilder<Map<String, dynamic>>(
                future: reservationStats,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading indicator while fetching data
                  } else if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Total Guests',
                                  value: data['total_guests'].toString(),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Reservations',
                                  value: data['total_reservations'].toString(),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Walk-Ins',
                                  value: data['total_walk_in'].toString(),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _SummaryCard(
                                title: 'Total Guests',
                                value: data['total_guests'].toString(),
                              ),
                              const SizedBox(height: 16),
                              _SummaryCard(
                                title: 'Reservations',
                                value: data['total_reservations'].toString(),
                              ),
                              const SizedBox(height: 16),
                              _SummaryCard(
                                title: 'Walk-Ins',
                                value: data['total_walk_in'].toString(),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  } else {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Total Guests',
                                  value: '0',
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Reservations',
                                  value: '0',
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _SummaryCard(
                                  title: 'Walk-Ins',
                                  value: '0',
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              _SummaryCard(title: 'Total Guests', value: '0'),
                              const SizedBox(height: 16),
                              _SummaryCard(title: 'Reservations', value: '0'),
                              const SizedBox(height: 16),
                              _SummaryCard(title: 'Walk-Ins', value: '0'),
                            ],
                          );
                        }
                      },
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (isListViewActive)
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      FutureBuilder<List<TableStatus>>(
                                        future: tableStatuses,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                              'Error: ${snapshot.error}',
                                            );
                                          } else if (snapshot.hasData) {
                                            final tableStatuses =
                                                snapshot.data!;
                                            return _buildTableStatus(
                                              tableStatuses,
                                            ); // Display the table status
                                          } else {
                                            return const Text(
                                              'No table status data found',
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      // Fetch and display the data
                                      FutureBuilder<List<Reservation>>(
                                        future: reservations,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                              'Error: ${snapshot.error}',
                                            );
                                          } else if (snapshot.hasData) {
                                            List<Reservation> data =
                                                snapshot.data!;
                                            return _buildDataTable(data);
                                          } else {
                                            return const Text(
                                              'No reservations found',
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              else
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TableReservationGrid(
                                        selectedDate: selectedDate,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the main header

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

  Widget _buildTableStatus(List<TableStatus> tableStatuses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              for (var tableStatus in tableStatuses)
                _TableStatusTag(
                  label: tableStatus.tableName,
                  isActive: tableStatus.status == 'active',
                  reservationStatus: tableStatus.reservationStatus,
                ),
            ],
          ),
        ),
      ],
    );
  }
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
Widget _buildDataTable(List<Reservation> data) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
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
              rows: data.map((reservation) {
                return DataRow(
                  cells: [
                    DataCell(Text(reservation.tableName)),
                    DataCell(
                      Text('${reservation.fromTime} - ${reservation.toTime}'),
                    ),
                    DataCell(Text(reservation.guestNo.toString())),
                    DataCell(Text(reservation.customerName)),
                    DataCell(Text(reservation.phoneNumber)),
                    DataCell(_StatusTag(status: reservation.status)),
                  ],
                );
              }).toList(),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final reservation = data[index];
              return _MobileTableItem(reservation: reservation);
            },
          );
        }
      },
    ),
  );
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

class _TableStatusTag extends StatelessWidget {
  const _TableStatusTag({
    required this.label,
    required this.isActive,
    required this.reservationStatus,
  });

  final String label;
  final bool isActive;
  final String reservationStatus;

  Color _getColor() {
    if (reservationStatus == 'available') {
      return AppColors.primaryColor; // Use primary color if available
    } else {
      return Colors.grey[200]!; // Default color if not available
    }
  }

  Color _getTextColor() {
    if (reservationStatus == 'available') {
      return Colors.white; // White text for available
    } else {
      return Colors.black; // Black text for unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(label),
        backgroundColor: _getColor(),
        side: BorderSide(
          color: isActive
              ? AppColors.primaryColor
              : Colors.grey.withOpacity(0.3),
        ),
        labelStyle: TextStyle(color: _getTextColor()),
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
  const _MobileTableItem({required this.reservation});

  final Reservation reservation; // Changed to Reservation model

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
                  'Table: ${reservation.tableName}', // Accessing reservation table name
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _StatusTag(
                  status: reservation.status,
                ), // Accessing status from Reservation
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${reservation.fromTime} - ${reservation.toTime}',
            ), // Accessing time range
            const SizedBox(height: 4),
            Text(
              'Name: ${reservation.customerName}',
            ), // Accessing customer name
            const SizedBox(height: 4),
            Text('Phone: ${reservation.phoneNumber}'), // Accessing phone number
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Person: ${reservation.guestNo}',
                ), // Accessing number of guests
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Function(int) onDateChange;
  final DateTime selectedDate;

  const _HeaderSection({
    super.key,
    required this.onDateChange,
    required this.selectedDate,
  });

  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    String displayDate =
        (selectedDate.year == DateTime.now().year &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.day == DateTime.now().day)
        ? 'Today'
        : formattedDate;

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
                  const SizedBox(height: 10),
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
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            onDateChange(-1);
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          displayDate,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            onDateChange(1);
                          },
                        ),
                      ],
                    ),
                  ),
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
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            onDateChange(-1);
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          displayDate,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            onDateChange(1);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
