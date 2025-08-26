import 'dart:convert';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:http/http.dart' as http;

class TableApiController {
  final String apiUrl =
      "http://10.10.13.26:9001/owner/table/?lean=EN"; // Replace with the correct API URL

  final String bearerToken =
      " eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU2MjIyNTYxLCJpYXQiOjE3NTYyMDgxNjEsImp0aSI6IjdkNWQxNTlhMjdhNTQwYTg5MzllNThhY2VlOTZkNDVjIiwidXNlcl9pZCI6Ijc1IiwiaWQiOjc1LCJlbWFpbCI6InBvbG9rQGdtYWlsLmNvbSIsInJvbGUiOiJPd25lciIsInJlc3RhdXJhbnRfaWQiOjY3fQ.uAd4XwEPYS24QVQhIHBqOqp2hsLbrx6aD_uHlfRMZnU"; // Replace with your token

  /// Pretty printer for long/JSON responses
  void _printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // chunks of 800 chars
    for (final match in pattern.allMatches(text)) {
      debugPrint(match.group(0));
    }
  }

  Future<Map<String, dynamic>> createReservation({
    required String customerName,
    required String phoneNumber,
    required int guestNo,
    required String date, // format: yyyy-MM-dd
    required String fromTime, // format: HH:mm:ss
    required String toTime, // format: HH:mm:ss
    required int tableId,
    String? email,
    String status = "pending", // default
  }) async {
    final url = Uri.parse("http://10.10.13.26:9001/owner/reservations/create/");

    final headers = {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU2MjIyNTYxLCJpYXQiOjE3NTYyMDgxNjEsImp0aSI6IjdkNWQxNTlhMjdhNTQwYTg5MzllNThhY2VlOTZkNDVjIiwidXNlcl9pZCI6Ijc1IiwiaWQiOjc1LCJlbWFpbCI6InBvbG9rQGdtYWlsLmNvbSIsInJvbGUiOiJPd25lciIsInJlc3RhdXJhbnRfaWQiOjY3fQ.uAd4XwEPYS24QVQhIHBqOqp2hsLbrx6aD_uHlfRMZnU",
    };

    final body = jsonEncode({
      "customer_name": customerName,
      "phone_number": phoneNumber,
      "guest_no": guestNo,
      "date": date,
      "from_time": fromTime,
      "to_time": toTime,
      "table": tableId,
      "email": email ?? "",
      "status": status,
    });

    // 🔹 Print debug request
    print("➡️ POST $url");
    print("📌 Headers: $headers");
    print("📌 Body: $body");

    final response = await http.post(url, headers: headers, body: body);

    // 🔹 Print debug response
    print("⬅️ Status Code: ${response.statusCode}");
    print("⬅️ Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Failed to create reservation: ${response.body}");
    }
  }

  /// Fetch the table list from the API
  Future<List<Map<String, dynamic>>> fetchTables() async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    };

    try {
      debugPrint('--- Fetching Tables ---');
      debugPrint('Request URL: $apiUrl');
      debugPrint('Headers: $headers');

      final startTime = DateTime.now();
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      final duration = DateTime.now().difference(startTime);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Time: ${duration.inMilliseconds} ms');

      if (response.body.isNotEmpty) {
        try {
          final decoded = json.decode(response.body);
          final prettyJson = const JsonEncoder.withIndent(
            '  ',
          ).convert(decoded);
          _printWrapped('Response Body (pretty):\n$prettyJson');
        } catch (_) {
          _printWrapped('Raw Response Body:\n${response.body}');
        }
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load tables. Code: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('Error fetching tables: $e');
      debugPrintStack(stackTrace: st, label: 'Stack Trace');
      throw Exception('Error fetching tables: $e');
    }
  }
}

class ReservationApiController {
  final String baseUrl = "${Urls.baseUrl}/owner/reservations/create/";
  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU2MjIyNTYxLCJpYXQiOjE3NTYyMDgxNjEsImp0aSI6IjdkNWQxNTlhMjdhNTQwYTg5MzllNThhY2VlOTZkNDVjIiwidXNlcl9pZCI6Ijc1IiwiaWQiOjc1LCJlbWFpbCI6InBvbG9rQGdtYWlsLmNvbSIsInJvbGUiOiJPd25lciIsInJlc3RhdXJhbnRfaWQiOjY3fQ.uAd4XwEPYS24QVQhIHBqOqp2hsLbrx6aD_uHlfRMZnU"; // inject dynamically if you have auth

  Future<Map<String, dynamic>> createReservation({
    required String customerName,
    required String phoneNumber,
    required int guestNo,
    required String date, // format: yyyy-MM-dd
    required String fromTime, // format: HH:mm:ss
    required String toTime, // format: HH:mm:ss
    required int tableId,
    String? email,
    String status = "pending", // default
  }) async {
    final url = Uri.parse("http://10.10.13.26:9001/owner/reservations/create/");

    // Ensure the date is in the correct format (yyyy-MM-dd)
    // You can modify the date string formatting logic if necessary
    print("Date: $date");

    final headers = {
      "Content-Type": "application/json", // Correct Content-Type header
      "Authorization": "Bearer $token",
    };

    // final body = jsonEncode({
    //   "customer_name": customerName,
    //   "phone_number": phoneNumber,
    //   "guest_no": guestNo,
    //   "date": date, // Ensure the date is in 'yyyy-MM-dd' format
    //   "from_time": fromTime,
    //   "to_time": toTime,
    //   "table": tableId,
    //   "email": email ?? "",
    //   "status": status,
    // });

    final body = jsonEncode({
      "customer_name": 'customerName',
      "phone_number": '51485',
      "guest_no": '4',
      "date": '2025-07-14', // Ensure the date is in 'yyyy-MM-dd' format
      "from_time": '01:00:00',
      "to_time": '02:00:00',
      "table": 25,
      "email": 'zJf6wb26lJo3@lsLllBOJSoFfTMiPUubKkXVh.wn' ?? "",
      "status": 'finished',
    });

    // Debugging: print the request headers and body
    print("Request Headers: $headers");
    print("Request Body: $body");

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Debugging: print the response status code and body
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create reservation: ${response.body}");
      }
    } catch (e) {
      // Handle any exceptions
      print("Error: $e");
      throw Exception("Failed to create reservation: $e");
    }
  }
}
