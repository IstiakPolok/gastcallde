import 'dart:convert';

import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TableModel {
  final int? id;
  final String name;
  final String capacity;
  final String status;
  final String reservationStatus;

  TableModel({
    this.id,
    required this.name,
    required this.capacity,
    required this.status,
    required this.reservationStatus,
  });

  Map<String, String> toRequestFields() {
    return {
      'table_name': name,
      'total_set': capacity,
      'status': status,
      'reservation_status': reservationStatus,
    };
  }

  // Factory method to convert JSON to TableModel
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      name: json['table_name'],
      capacity: json['total_set'].toString(),
      status: json['status'],
      reservationStatus: json['reservation_status'],
    );
  }
}

class TableController extends GetxController {
  var tables = <TableModel>[].obs; // Observable list of TableModel

  Future<void> fetchTables() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'EN';
    final String? token = await SharedPreferencesHelper.getAccessToken();
    try {
      print("Fetching tables from API...");

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/owner/table/?lean=$code'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> tableData = json.decode(response.body);

        print("Decoded table data: $tableData");

        // Update the observable table list
        tables.assignAll(
          tableData.map((table) => TableModel.fromJson(table)).toList(),
        );

        print("Tables updated successfully. Total tables: ${tables.length}");
      } else {
        print("Failed to load tables: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching tables: $e");
    }
  }

  // Save the tables to the server
  Future<void> saveTables(List<TableModel> newTables) async {
    print("Starting to save ${newTables.length} tables...");
    final String? token = await SharedPreferencesHelper.getAccessToken();
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'EN';

    for (var table in newTables) {
      print(
        "Saving table: ${table.name}, Capacity: ${table.capacity}, Status: ${table.status}, Reservation Status: ${table.reservationStatus}",
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Urls.createTable + code),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll(table.toRequestFields());

      try {
        final response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          print(
            "✅ Table ${table.name} created successfully. Status Code: ${response.statusCode}",
          );
        } else {
          print(
            "❌ Failed to create table ${table.name}. Status Code: ${response.statusCode}",
          );
        }
      } catch (e) {
        print("❌ Error while creating table ${table.name}: $e");
      }
    }

    print("Finished saving tables.");
  }

  // Add tables locally to the observable list
  void addTables(List<TableModel> newTables) {
    print("Adding ${newTables.length} new tables locally...");
    tables.assignAll(newTables);
    print("Tables saved locally: ${newTables.map((t) => t.name).toList()}");
  }

  // Delete a table by ID
  Future<bool> deleteTable(int tableId) async {
    print("Starting to delete table with ID: $tableId");
    final String? token = await SharedPreferencesHelper.getAccessToken();

    try {
      final response = await http.delete(
        Uri.parse('${Urls.baseUrl}/owner/table/delete/$tableId/'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Delete response status code: ${response.statusCode}");
      print("Delete response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Table $tableId deleted successfully");
        // Remove the table from the local list
        tables.removeWhere((table) => table.id == tableId);
        return true;
      } else {
        print(
          "❌ Failed to delete table $tableId. Status Code: ${response.statusCode}",
        );
        return false;
      }
    } catch (e) {
      print("❌ Error while deleting table $tableId: $e");
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTables(); // Fetch tables when the controller is initialized
  }
}
