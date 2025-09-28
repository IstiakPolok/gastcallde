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
}
