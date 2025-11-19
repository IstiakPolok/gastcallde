import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class WeeklyScheduleController extends GetxController {
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Map to store schedule for each day
  final RxMap<String, Map<String, dynamic>> weeklySchedule =
      <String, Map<String, dynamic>>{
        'monday': {'id': null, 'opening': null, 'closing': null},
        'tuesday': {'id': null, 'opening': null, 'closing': null},
        'wednesday': {'id': null, 'opening': null, 'closing': null},
        'thursday': {'id': null, 'opening': null, 'closing': null},
        'friday': {'id': null, 'opening': null, 'closing': null},
        'saturday': {'id': null, 'opening': null, 'closing': null},
        'sunday': {'id': null, 'opening': null, 'closing': null},
      }.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeeklySchedule();
  }

  Future<void> fetchWeeklySchedule() async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();

      final response = await http.get(
        Uri.parse(Urls.weeklySchedule),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📅 Fetch Schedule Response: ${response.statusCode}');
      debugPrint('📅 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Update schedule with fetched data
        for (var schedule in data) {
          final day = schedule['day_of_week'].toString().toLowerCase();
          if (weeklySchedule.containsKey(day)) {
            weeklySchedule[day] = {
              'id': schedule['id'],
              'opening': _parseTimeOfDay(schedule['opening_time']),
              'closing': _parseTimeOfDay(schedule['closing_time']),
            };
          }
        }

        debugPrint('✅ Weekly schedule loaded successfully');
      } else {
        debugPrint('❌ Failed to fetch schedule: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching weekly schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update individual day schedule using PATCH
  Future<bool> updateDaySchedule(String day) async {
    try {
      final schedule = weeklySchedule[day];
      if (schedule == null || schedule['id'] == null) {
        debugPrint('❌ Cannot update $day: No ID found');
        return false;
      }

      if (schedule['opening'] == null || schedule['closing'] == null) {
        debugPrint('❌ Cannot update $day: Missing times');
        return false;
      }

      final token = await SharedPreferencesHelper.getAccessToken();
      final openingTime = _formatTimeOfDay(schedule['opening']);
      final closingTime = _formatTimeOfDay(schedule['closing']);

      final payload = {
        'day_of_week': day,
        'opening_time': openingTime,
        'closing_time': closingTime,
      };

      debugPrint('� Updating $day with PATCH: $payload');

      final response = await http.patch(
        Uri.parse('${Urls.weeklySchedule}${schedule['id']}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('📡 $day Update Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ $day updated successfully');
        return true;
      } else {
        debugPrint('❌ Failed to update $day: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating $day schedule: $e');
      return false;
    }
  }

  // Create new schedule for a day using POST
  Future<bool> createDaySchedule(String day) async {
    try {
      final schedule = weeklySchedule[day];
      if (schedule == null) {
        debugPrint('❌ Cannot create $day: No schedule data');
        return false;
      }

      if (schedule['opening'] == null || schedule['closing'] == null) {
        debugPrint('❌ Cannot create $day: Missing times');
        return false;
      }

      final token = await SharedPreferencesHelper.getAccessToken();
      final openingTime = _formatTimeOfDay(schedule['opening']);
      final closingTime = _formatTimeOfDay(schedule['closing']);

      final payload = {
        'day_of_week': day,
        'opening_time': openingTime,
        'closing_time': closingTime,
      };

      debugPrint('➕ Creating $day: $payload');

      final response = await http.post(
        Uri.parse(Urls.weeklySchedule),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      debugPrint('📡 $day Create Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        weeklySchedule[day]!['id'] = responseData['id'];
        debugPrint(
          '✅ $day created successfully with ID: ${responseData['id']}',
        );
        return true;
      } else {
        debugPrint('❌ Failed to create $day: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error creating $day schedule: $e');
      return false;
    }
  }

  // Save or update a single day's schedule
  Future<bool> saveDaySchedule(String day) async {
    final schedule = weeklySchedule[day];
    if (schedule == null) return false;

    if (schedule['id'] != null) {
      // Update existing using PATCH
      return await updateDaySchedule(day);
    } else {
      // Create new using POST
      return await createDaySchedule(day);
    }
  }

  // Legacy method for bulk save (kept for backward compatibility)
  Future<bool> saveWeeklySchedule() async {
    try {
      isSaving.value = true;
      bool allSuccess = true;

      for (var day in weeklySchedule.keys) {
        final schedule = weeklySchedule[day];
        if (schedule!['opening'] == null || schedule['closing'] == null) {
          continue; // Skip days without times set
        }

        final success = await saveDaySchedule(day);
        if (!success) {
          allSuccess = false;
        }
      }

      return allSuccess;
    } catch (e) {
      debugPrint('❌ Error saving weekly schedule: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  void updateTime(String day, String type, TimeOfDay time) {
    if (weeklySchedule.containsKey(day)) {
      weeklySchedule[day]![type] = time;
      weeklySchedule.refresh();
    }
  }
}
