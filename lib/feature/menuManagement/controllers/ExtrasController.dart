import 'dart:convert';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/menuManagement/models/ExtraModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ExtrasController extends GetxController {
  var extras = <Extra>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExtras();
  }

  Future<void> fetchExtras() async {
    try {
      isLoading(true);
      final String url = '${Urls.baseUrl}/owner/extras/';
      final String? token = await SharedPreferencesHelper.getAccessToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        extras.value = data.map((json) => Extra.fromJson(json)).toList();
      } else {
        Get.snackbar('Error', 'Failed to fetch extras');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> addExtra(String title, String price) async {
    try {
      final String url = '${Urls.baseUrl}/owner/extras/';
      final String? token = await SharedPreferencesHelper.getAccessToken();

      final headers = {
        'Authorization': 'Bearer $token',
        // 'Content-Type': 'multipart/form-data', // http.post with body map uses form-urlencoded by default which might be what is needed or multipart
      };

      // The API doc says formData, so we can use a map for body
      final body = {'extras': title, 'extras_price': price};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        fetchExtras();
        return true;
      } else {
        Get.snackbar('Error', 'Failed to add extra: ${response.body}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateExtra(int id, String title, String price) async {
    try {
      final String url = '${Urls.baseUrl}/owner/extras/$id/';
      final String? token = await SharedPreferencesHelper.getAccessToken();

      final headers = {'Authorization': 'Bearer $token'};

      final body = {'extras': title, 'extras_price': price};

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        fetchExtras();
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update extra: ${response.body}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }

  Future<bool> deleteExtra(int id) async {
    try {
      final String url = '${Urls.baseUrl}/owner/extras/$id/';
      final String? token = await SharedPreferencesHelper.getAccessToken();

      final headers = {'Authorization': 'Bearer $token'};

      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 204 || response.statusCode == 200) {
        fetchExtras();
        return true;
      } else {
        Get.snackbar('Error', 'Failed to delete extra');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }
}
