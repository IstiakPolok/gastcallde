import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../../core/network_caller/endpoints.dart';

class DeliveryInfoController extends GetxController {
  var deliveryAreas = [].obs;
  var isLoading = false.obs;

  /// =============================
  /// Fetch Delivery Areas
  /// =============================
  Future<void> fetchDeliveryAreas() async {
    print("\n🛰️ [FETCH] Starting to fetch delivery areas...");
    try {
      isLoading(true);
      final token = await SharedPreferencesHelper.getAccessToken();
      print("🔑 Access Token: $token");

      final url = '${Urls.baseUrl}/owner/areas/';
      print("🌐 Request URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        deliveryAreas.value = jsonDecode(response.body);
        print(
          "✅ Delivery areas fetched successfully (${deliveryAreas.length} items)",
        );
      } else {
        print("❌ Failed to fetch delivery areas: ${response.statusCode}");
        Get.snackbar('Error', 'Failed to fetch delivery areas');
      }
    } catch (e) {
      print("🔥 Exception in fetchDeliveryAreas: $e");
      Get.snackbar('Error', 'Something went wrong while fetching areas');
    } finally {
      isLoading(false);
      print("🏁 [FETCH] Completed fetching areas\n");
    }
  }

  /// =============================
  /// Add Delivery Area
  /// =============================
  Future<void> addDeliveryArea({
    required String postalCode,
    required String estimatedTime,
    required String deliveryFee,
  }) async {
    print("\n🚀 [ADD] Starting to add delivery area...");
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      print("🔑 Access Token: $token");

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

      print("📝 Request Body (Form Data): $body");
      print("📝 JSON Encoded Body: ${jsonEncode(body)}");
      print("🌐 Request URL: ${Urls.addDeliveryArea}");

      final response = await http.post(
        Uri.parse(Urls.addDeliveryArea),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Delivery area added successfully");
        Get.snackbar("Success", "Delivery area added successfully");
        await fetchDeliveryAreas(); // refresh list
      } else {
        print("❌ Failed to add delivery area: ${response.body}");
        Get.snackbar("Error", "Failed to add delivery area");
      }
    } catch (e) {
      print("🔥 Exception in addDeliveryArea: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      print("🏁 [ADD] Completed addDeliveryArea\n");
    }
  }

  /// =============================
  /// Update Delivery Area
  /// =============================
  Future<void> updateDeliveryArea({
    required int id,
    required String postalCode,
    required String estimatedTime,
    required String deliveryFee,
  }) async {
    print("\n✏️ [UPDATE] Starting to update delivery area with ID: $id");
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      print("🔑 Access Token: $token");

      if (token == null) {
        print("⚠️ No token found. Cannot update delivery area.");
        Get.snackbar("Error", "User not authenticated");
        return;
      }

      final body = {
        "postalcode": postalCode,
        "estimated_delivery_time": estimatedTime,
        "delivery_fee": deliveryFee,
      };

      final url = '${Urls.baseUrl}/owner/areas/$id/';
      print("📝 Request Body (Form Data): $body");
      print("📝 JSON Encoded Body: ${jsonEncode(body)}");
      print("🌐 Request URL: $url");

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Delivery area updated successfully");
        Get.snackbar("Success", "Delivery area updated successfully");
        await fetchDeliveryAreas(); // refresh list
      } else {
        print("❌ Failed to update delivery area: ${response.body}");
        Get.snackbar("Error", "Failed to update delivery area");
      }
    } catch (e) {
      print("🔥 Exception in updateDeliveryArea: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      print("🏁 [UPDATE] Completed updateDeliveryArea\n");
    }
  }

  /// =============================
  /// Delete Delivery Area
  /// =============================
  Future<void> deleteDeliveryArea(int id) async {
    print("\n🗑️ [DELETE] Starting to delete delivery area with ID: $id");
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = '${Urls.baseUrl}/owner/areas/$id/';
      print("🌐 Request URL: $url");
      print("🔑 Token: $token");

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 204) {
        deliveryAreas.removeWhere((area) => area['id'] == id);
        print("✅ Delivery area deleted successfully (ID: $id)");
        Get.snackbar('Success', 'Area deleted successfully');
      } else {
        print(
          "❌ Failed to delete area (${response.statusCode}): ${response.body}",
        );
        Get.snackbar('Error', 'Failed to delete area (${response.statusCode})');
      }
    } catch (e) {
      print("🔥 Exception in deleteDeliveryArea: $e");
      Get.snackbar('Error', 'Something went wrong while deleting');
    } finally {
      print("🏁 [DELETE] Completed deleteDeliveryArea\n");
    }
  }
}
