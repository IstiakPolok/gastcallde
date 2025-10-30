import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class RestaurantSettingsController extends GetxController {
  // Loading state
  RxBool isLoading = true.obs;

  // General user fields
  RxString email = ''.obs;
  RxString role = ''.obs;
  RxBool approved = false.obs;

  // Restaurant fields
  RxInt restaurantId = 0.obs;
  RxString restaurantName = ''.obs;
  RxString address = ''.obs;
  RxString phoneNumber1 = ''.obs;
  RxString twilioNumber = ''.obs;
  RxString openingTime = ''.obs;
  RxString closingTime = ''.obs;
  RxInt ownerId = 0.obs;
  RxString website = ''.obs;
  RxString iban = ''.obs;
  RxString taxNumber = ''.obs;
  RxString image = ''.obs;
  RxInt totalVapiMinutes = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurantSettings();
  }

  Future<void> fetchRestaurantSettings() async {
    try {
      isLoading.value = true;
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        Get.snackbar("Error", "Token not found");
        return;
      }

      final url = Uri.parse("${Urls.baseUrl}/owner/profile/?lean=EN");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        /// Debug print full response
        print("🔍 Full API Response: $data");

        // Map top-level fields
        email.value = data['email'] ?? '';
        role.value = data['role'] ?? '';
        approved.value = data['approved'] ?? false;

        final restaurant = data['restaurant'] ?? {};
        restaurantId.value = restaurant['id'] ?? 0;
        restaurantName.value = restaurant['resturent_name'] ?? '';
        address.value = restaurant['address'] ?? '';
        phoneNumber1.value = restaurant['phone_number_1'] ?? '';
        twilioNumber.value = restaurant['twilio_number'] ?? '';
        openingTime.value = restaurant['opening_time'] ?? '';
        closingTime.value = restaurant['closing_time'] ?? '';
        ownerId.value = restaurant['owner'] ?? 0;
        website.value = restaurant['website'] ?? '';
        iban.value = restaurant['iban'] ?? '';
        taxNumber.value = restaurant['tax_number'] ?? '';
        image.value = restaurant['image'] ?? '';
        totalVapiMinutes.value = restaurant['total_vapi_minutes'] ?? 0;

        /// Debug print mapped fields
        print("✅ Email: ${email.value}");
        print("✅ Role: ${role.value}");
        print("✅ Approved: ${approved.value}");
        print("🏪 Restaurant ID: ${restaurantId.value}");
        print("🏪 Name: ${restaurantName.value}");
        print("📍 Address: ${address.value}");
        print("📞 Phone: ${phoneNumber1.value}");
        print("📞 Twilio: ${twilioNumber.value}");
        print("🕒 Opening Time: ${openingTime.value}");
        print("🕒 Closing Time: ${closingTime.value}");
        print("👤 Owner ID: ${ownerId.value}");
        print("🌐 Website: ${website.value}");
        print("🏦 IBAN: ${iban.value}");
        print("💰 Tax Number: ${taxNumber.value}");
        print("🖼 Image: ${image.value}");
        print("⏱ Total VAPI Minutes: ${totalVapiMinutes.value}");
      } else {
        Get.snackbar("Error", "Failed to fetch restaurant info");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return 'Not set';
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : (hour > 12 ? hour - 12 : hour); // convert 24h to 12h
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<bool> updatePhoneNumber(
    String newPhoneNumber,
    String forwardMode,
  ) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        Get.snackbar("Error", "Token not found");
        return false;
      }

      print('Updating phone number to: $newPhoneNumber');
      print('Updating forward mode to: $forwardMode');

      final response = await http.patch(
        Uri.parse('${Urls.baseUrl}/owner/resturant/'),
        headers: {'Authorization': 'Bearer $token'},
        body: {'phone_number_1': newPhoneNumber, 'forword_mode': forwardMode},
      );

      print('Update Phone API Status Code: ${response.statusCode}');
      print('Update Phone API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update local value
        phoneNumber1.value = data['phone_number_1'] ?? newPhoneNumber;
        print('Successfully updated phone number and forward mode');
        return true;
      } else {
        print('Failed to update phone number: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating phone number: $e');
      return false;
    }
  }

  Future<bool> updateRestaurantAddress(String newAddress) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        Get.snackbar("Error", "Token not found");
        return false;
      }

      print('Updating restaurant address to: $newAddress');

      final response = await http.patch(
        Uri.parse('${Urls.baseUrl}/owner/resturant/'),
        headers: {'Authorization': 'Bearer $token'},
        body: {'address': newAddress},
      );

      print('Update Address API Status Code: ${response.statusCode}');
      print('Update Address API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update local value
        address.value = data['address'] ?? newAddress;
        print('Successfully updated restaurant address');
        return true;
      } else {
        print('Failed to update address: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  Future<bool> updateBusinessHours(
    String openingTime,
    String closingTime,
  ) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        Get.snackbar("Error", "Token not found");
        return false;
      }

      print(
        '🕒 Attempting to update business hours: $openingTime - $closingTime',
      );
      print('📍 Endpoint: ${Urls.baseUrl}/owner/resturant/');

      final response = await http.patch(
        Uri.parse('${Urls.baseUrl}/owner/resturant/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'opening_time': openingTime,
          'closing_time': closingTime,
        }),
      );

      print('📡 Update Business Hours API Status Code: ${response.statusCode}');
      print('📦 Update Business Hours API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update local values
        this.openingTime.value = data['opening_time'] ?? openingTime;
        this.closingTime.value = data['closing_time'] ?? closingTime;
        print('✅ Successfully updated business hours');
        print('✅ New opening time: ${this.openingTime.value}');
        print('✅ New closing time: ${this.closingTime.value}');
        return true;
      } else {
        print('❌ Failed to update business hours: ${response.statusCode}');
        print('❌ Error details: ${response.body}');

        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Error data: $errorData');
          if (errorData is Map && errorData.containsKey('detail')) {
            Get.snackbar(
              'Update Failed',
              errorData['detail'].toString(),
              snackPosition: SnackPosition.BOTTOM,
            );
          } else if (errorData is Map &&
              errorData.containsKey('opening_time')) {
            Get.snackbar(
              'Update Failed',
              'Opening time: ${errorData['opening_time']}',
              snackPosition: SnackPosition.BOTTOM,
            );
          } else if (errorData is Map &&
              errorData.containsKey('closing_time')) {
            Get.snackbar(
              'Update Failed',
              'Closing time: ${errorData['closing_time']}',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } catch (e) {
          print('⚠️ Could not parse error response: $e');
        }

        return false;
      }
    } catch (e) {
      print('🚨 Exception updating business hours: $e');
      Get.snackbar(
        'Error',
        'Network error: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
