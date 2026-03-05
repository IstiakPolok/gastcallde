import 'dart:convert';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Reservation {
  final int id;
  final String? customerName;
  final String? phoneNumber;
  final int guestNo;
  final String status;
  final String date;
  final String fromTime;
  final String toTime;
  final int table;
  final String? email;
  final String? tableName;

  Reservation({
    required this.id,
    this.customerName,
    this.phoneNumber,
    required this.guestNo,
    required this.status,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.table,
    this.email,
    this.tableName,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      customerName: json['customer_name'],
      phoneNumber: json['phone_number'],
      guestNo: json['guest_no'],
      status: json['status'],
      date: json['date'],
      fromTime: json['from_time'],
      toTime: json['to_time'],
      table: json['table'],
      email: json['email'],
      tableName: json['table_name']?['table_name'],
    );
  }
}

class TableStatus {
  final int id;
  final String tableName;
  final String status;
  final String reservationStatus;
  final int totalSet;

  TableStatus({
    required this.id,
    required this.tableName,
    required this.status,
    required this.reservationStatus,
    required this.totalSet,
  });

  factory TableStatus.fromJson(Map<String, dynamic> json) {
    return TableStatus(
      id: json['id'],
      tableName: json['table_name'],
      status: json['status'],
      reservationStatus: json['reservation_status'],
      totalSet: json['total_set'],
    );
  }
}

Future<List<Reservation>> fetchReservations(String date) async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString('language_code') ?? 'EN';

  final String? token = await SharedPreferencesHelper.getAccessToken();

  // Debug print for token and language code
  print('Token: $token');
  print('Language Code: $code');

  final String url = "${Urls.getReservationList}$date";

  print('Fetching reservations from URL: $url'); // Debugging the URL

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token', // Use the actual token
      'Accept': 'application/json',
    },
  );

  print('Response status: ${response.statusCode}'); // Debugging the status code
  print('Response body: ${response.body}'); // Debugging the response body

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON data
    List<dynamic> data = json.decode(response.body);
    // Debugging the parsed data
    print('Parsed Data: $data');
    return data.map((item) => Reservation.fromJson(item)).toList();
  } else {
    // If the server did not return a 200 OK response, throw an exception
    print('Failed to load reservations. Status Code: ${response.statusCode}');
    throw Exception('Failed to load reservations');
  }
}

Future<Map<String, dynamic>> fetchReservationStats(String date) async {
  final String? token = await SharedPreferencesHelper.getAccessToken();
  final String url =
      '${Urls.getReservationstats}$date'; // Replace with your API URL
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token', // Use the actual token
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON data
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load reservation stats');
  }
}

Future<List<TableStatus>> fetchTableStatus(String date) async {
  final String? token = await SharedPreferencesHelper.getAccessToken();
  print("🔑 Token: $token");
  print("🌍 URL: ${Urls.updateTableStatus + date}");

  try {
    final response = await http.get(
      Uri.parse(Urls.updateTableStatus + date),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print("📡 Status Code: ${response.statusCode}");
    print("📥 Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print("✅ Parsed table status Data: $data");
      return data.map((json) => TableStatus.fromJson(json)).toList();
    } else {
      print("❌ Error Response: ${response.body}");
      throw Exception('Failed to load table status');
    }
  } catch (e, stack) {
    print("⚠️ Exception: $e");
    print("📌 Stack Trace: $stack");
    rethrow;
  }
}
