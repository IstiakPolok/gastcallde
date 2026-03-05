import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;

class TableReservationItem {
  final String tableName;
  final List<Reservation> reservations;

  TableReservationItem({required this.tableName, required this.reservations});

  factory TableReservationItem.fromJson(Map<String, dynamic> json) {
    var reservationsFromJson = json['reservations'] as List;
    List<Reservation> reservationList = reservationsFromJson
        .map((e) => Reservation.fromJson(e))
        .toList();

    return TableReservationItem(
      tableName: json['table_name'],
      reservations: reservationList,
    );
  }
}

class Reservation {
  final String? customerName;
  final int guestNo;
  final String fromTime;
  final String toTime;
  final String status;

  Reservation({
    this.customerName,
    required this.guestNo,
    required this.fromTime,
    required this.toTime,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      customerName: json['customer_name'],
      guestNo: json['guest_no'],
      fromTime: json['from_time'],
      toTime: json['to_time'],
      status: json['status'],
    );
  }
}

Future<List<TableReservationItem>> fetchTableReservations(String date) async {
  final String? token = await SharedPreferencesHelper.getAccessToken();
  print("🔑 Token: $token");
  final String url = Urls.getTablegridReservations + date;
  print("🌍 Request URL: $url");

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print("📡 Status Code: ${response.statusCode}");
    print("📥 Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("✅ Parsed Data Length: ${data.length}");
      debugPrint(
        "✅ Parsed Data: $data",
        wrapWidth: 1024,
      ); // pretty prints long JSON
      return data.map((json) => TableReservationItem.fromJson(json)).toList();
    } else {
      print("❌ Error Response: ${response.body}");
      throw Exception('Failed to load table reservations');
    }
  } catch (e, stack) {
    print("⚠️ Exception: $e");
    print("📌 Stack Trace: $stack");
    rethrow;
  }
}
