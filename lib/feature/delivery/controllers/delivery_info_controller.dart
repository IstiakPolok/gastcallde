import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../../core/network_caller/endpoints.dart';

class DeliveryInfoController extends GetxController {
  var deliveryAreas = [].obs;
  var isLoading = false.obs;

  Future<void> fetchDeliveryAreas() async {
    try {
      isLoading(true);
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/owner/areas/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        deliveryAreas.value = jsonDecode(response.body);
      } else {
        Get.snackbar('Error', 'Failed to fetch delivery areas');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while fetching areas');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addDeliveryArea({
    required String postalCode,
    required String estimatedTime,
    required String deliveryFee,
  }) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      print("🔑 Token: $token");

      if (token == null) {
        print("⚠️ No token found. Cannot add delivery area.");
        Get.snackbar("Error", "User not authenticated");
        return;
      }

      final body = {
        "postalcode": postalCode,
        "estimated_delivery_time": estimatedTime,
        "delivery_fee": deliveryFee,
      };

      print("📤 Request Body (form data): $body");

      final response = await http.post(
        Uri.parse(Urls.addDeliveryArea),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded", // form data
        },
        body: body,
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Delivery area added successfully");
        Get.snackbar("Success", "Delivery area added successfully");
        fetchDeliveryAreas(); // Refresh list
      } else {
        print("❌ Failed to add delivery area");
        Get.snackbar("Error", "Failed to add delivery area");
      }
    } catch (e) {
      print("🔥 Error adding delivery area: $e");
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteDeliveryArea(int id) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final response = await http.delete(
        Uri.parse('${Urls.baseUrl}/owner/areas/$id/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        deliveryAreas.removeWhere((area) => area['id'] == id);
        Get.snackbar('Success', 'Area deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete area (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong while deleting');
    }
  }
}
