import 'package:flutter/material.dart';
import 'package:gastcallde/feature/reservastion/controllers/TableReservationGridcontroller.dart';
import 'package:gastcallde/feature/setting/controllers/WeeklyScheduleController.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ...existing imports...

class TableReservationGrid extends StatelessWidget {
  final DateTime selectedDate;
  const TableReservationGrid({super.key, required this.selectedDate});

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate);

  // Helper function to get day of week key
  String getDayOfWeekKey() {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[selectedDate.weekday - 1];
  }

  // Helper function to get color based on status
  Color getStatusColor(String status) {
    switch (status) {
      case 'Walk-In':
        return Colors.blue[100]!;
      case 'Res':
        return Colors.teal[100]!;
      case 'Cancel':
        return Colors.red[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  // Helper to parse time string to DateTime (assumes format 'HH:mm:ss')
  DateTime parseTime(String time) {
    final parts = time.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  // Helper to get slot index for a given time
  int getSlotIndex(String time, List<String> slots) {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i] == time) return i;
    }
    return -1;
  }

  // Helper function to build a reservation cell
  Widget buildReservationCell(
    Reservation reservation,
    int slotSpan,
    double slotWidth,
  ) {
    String status = reservation.status;
    int guestCount = reservation.guestNo;
    String customerName = reservation.customerName ?? 'N/A';
    String fromTime = reservation.fromTime;
    String toTime = reservation.toTime;

    // Calculate width accounting for margins between cells
    // Each cell has margin of 2 on all sides, so 4 pixels between cells
    double totalWidth = (slotWidth * slotSpan) + ((slotSpan - 1) * 4);

    return Stack(
      children: [
        Container(
          width: totalWidth,
          height: 70,
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            // color: getStatusColor(status),
            color: Colors.teal[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  customerName.isNotEmpty ? customerName : 'N/A',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$guestCount guests',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                // Text(
                //   status,
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                // ),
                // Text(
                //   '$fromTime - $toTime',
                //   textAlign: TextAlign.center,
                //   style: const TextStyle(fontSize: 10),
                // ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(status),
            ),
          ),
        ),
      ],
    );
  }

  // Generate time slots from opening to closing time in 15-minute intervals
  List<String> generateTimeSlots(TimeOfDay? opening, TimeOfDay? closing) {
    List<String> slots = [];

    // Default to 06:00 - 15:00 if times are not set
    int startHour = opening?.hour ?? 6;
    int startMinute = opening?.minute ?? 0;
    int endHour = closing?.hour ?? 15;
    int endMinute = closing?.minute ?? 0;

    // Convert to minutes for easier comparison
    int currentMinutes = startHour * 60 + startMinute;
    int endMinutes = endHour * 60 + endMinute;

    while (currentMinutes <= endMinutes) {
      int hour = currentMinutes ~/ 60;
      int minute = currentMinutes % 60;

      slots.add(
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00',
      );

      currentMinutes += 15; // 15-minute intervals
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    // Get the WeeklyScheduleController instance
    final scheduleController = Get.isRegistered<WeeklyScheduleController>()
        ? Get.find<WeeklyScheduleController>()
        : Get.put(WeeklyScheduleController());

    return Obx(() {
      // Get the day of week for the selected date
      final dayKey = getDayOfWeekKey();
      final schedule = scheduleController.weeklySchedule[dayKey];

      // Get opening and closing times for the day
      final TimeOfDay? opening = schedule?['opening'] as TimeOfDay?;
      final TimeOfDay? closing = schedule?['closing'] as TimeOfDay?;

      final timeSlots = generateTimeSlots(opening, closing);
      const double slotWidth = 100;

      return FutureBuilder<List<TableReservationItem>>(
        future: fetchTableReservations(formattedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('no_data_found'.tr));
          }

          final tableReservations = snapshot.data!;
          final tableNames = tableReservations.map((t) => t.tableName).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // Time slots header for X-axis
                Row(
                  children: [
                    const SizedBox(width: 100), // Empty corner for table names
                    ...timeSlots.map((time) {
                      return Container(
                        width: slotWidth,
                        height: 40,
                        margin: const EdgeInsets.all(2),
                        alignment: Alignment.center,
                        child: Text(
                          time,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ],
                ),
                // Table rows
                ...tableReservations.map((table) {
                  // Build a map of slot index to reservation
                  Map<int, Reservation> slotToReservation = {};
                  for (var res in table.reservations) {
                    int start = getSlotIndex(res.fromTime, timeSlots);
                    int end = getSlotIndex(res.toTime, timeSlots);
                    if (start != -1 && end != -1) {
                      // Reservation occupies from start up to (but not including) end
                      for (int i = start; i < end; i++) {
                        slotToReservation[i] = res;
                      }
                    }
                  }

                  List<Widget> rowCells = [];
                  rowCells.add(
                    Container(
                      width: 100,
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        table.tableName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );

                  int i = 0;
                  while (i < timeSlots.length) {
                    if (slotToReservation.containsKey(i)) {
                      // Only show reservation info at the first slot of the reservation
                      Reservation res = slotToReservation[i]!;
                      int start = getSlotIndex(res.fromTime, timeSlots);
                      int end = getSlotIndex(res.toTime, timeSlots);
                      int span = end - start;
                      if (i == start) {
                        rowCells.add(
                          buildReservationCell(res, span, slotWidth),
                        );
                        i += span;
                      } else {
                        // Skip cells covered by the reservation
                        i++;
                      }
                    } else {
                      rowCells.add(
                        Container(
                          width: slotWidth,
                          height: 70,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: getStatusColor('available'),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                      i++;
                    }
                  }

                  return Row(children: rowCells);
                }),
              ],
            ),
          );
        },
      );
    });
  }
}
