import 'package:flutter/material.dart';

class TableReservationGrid extends StatelessWidget {
  const TableReservationGrid({super.key});

  Widget buildReservationCell({
    required String name,
    required int personCount,
    required String status,
  }) {
    Color bgColor;
    Color textColor = Colors.black;
    Widget statusWidget;

    switch (status) {
      case 'Walk-In':
        bgColor = Colors.blue[100]!;
        statusWidget = Text('Walk-In', style: TextStyle(color: Colors.blue));
        break;
      case 'Res':
        bgColor = Colors.teal[100]!;
        statusWidget = Text('Res', style: TextStyle(color: Colors.teal));
        break;
      case 'Cancel':
        bgColor = Colors.teal[100]!;
        statusWidget = Text('Cancel', style: TextStyle(color: Colors.red));
        break;
      default:
        bgColor = Colors.grey[200]!;
        statusWidget = const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Person : $personCount"),
          Align(alignment: Alignment.bottomRight, child: statusWidget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FixedColumnWidth(100),
          1: FixedColumnWidth(150),
          2: FixedColumnWidth(150),
          3: FixedColumnWidth(150),
          4: FixedColumnWidth(150),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Tables",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (int i = 0; i < 4; i++)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "11:00 am",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          // Table 01
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Table 01\nPA : 9",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              buildReservationCell(
                name: "Sandra Schmidt",
                personCount: 3,
                status: "Walk-In",
              ),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          // Table 02
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Table 02\nPA : 3",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          // Table 03
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Table 03\nPA : 6",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              buildReservationCell(
                name: "Ara Schmidt",
                personCount: 3,
                status: "Res",
              ),
              const SizedBox(),
              buildReservationCell(
                name: "Sandra Schmidt",
                personCount: 3,
                status: "Res",
              ),
              const SizedBox(),
            ],
          ),
          // Table 04
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Table 04\nPA : 2",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          // Table 05
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Table 05\nPA : 2",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(),
              buildReservationCell(
                name: "Bmidt",
                personCount: 3,
                status: "Cancel",
              ),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
          // Table 06
          TableRow(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Table 06\nPA : 3",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
