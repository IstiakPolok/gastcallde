import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/menuManagement/screens/menuManagement.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For token

class AddFoodItemScreen extends StatelessWidget {
  AddFoodItemScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController preparationTimeController =
      TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  Future<void> createFoodItem() async {
    final String url = '${Urls.baseUrl}/owner/items/create/?lean=EN';
    final String? token = await SharedPreferencesHelper.getAccessToken();

    print("\n================= 🍔 CREATE FOOD ITEM =================");
    print("🔑 Token: $token");
    print("🌍 URL: $url");

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    };

    print("📌 Headers: $headers");

    // Prepare the request
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    // Add form fields
    request.fields['item_name'] = nameController.text;
    request.fields['status'] = statusController.text;
    request.fields['descriptions'] = descriptionController.text;
    request.fields['price'] = priceController.text;
    request.fields['category'] = categoryController.text;
    request.fields['discount'] = discountController.text;
    request.fields['preparation_time'] = preparationTimeController.text;

    print("\n📦 Request Fields:");
    request.fields.forEach((key, value) {
      print("   ➡️ $key: $value");
    });

    // If an image is selected
    if (imageController.text.isNotEmpty) {
      try {
        final imageFile = await http.MultipartFile.fromPath(
          'image',
          imageController.text,
        );
        request.files.add(imageFile);
        print("📷 Image File Added: ${imageController.text}");
      } catch (e) {
        print("⚠️ Image Error: $e");
      }
    } else {
      print("ℹ️ No image selected.");
    }

    try {
      print("\n🚀 Sending API Request...");
      final response = await request.send();

      print("✅ Response Status Code: ${response.statusCode}");

      final responseBody = await response.stream.bytesToString();
      print("📨 Response Body: $responseBody");

      if (response.statusCode == 201) {
        print("🎉 Food item added successfully!");
        Get.off(() => menuManagement());
      } else {
        print("❌ Failed to add food item. Code: ${response.statusCode}");
      }
    } catch (error) {
      print("🔥 Exception during API call: $error");
    }

    print("================= ✅ END CREATE FOOD ITEM =================\n");
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      'access_token',
    ); // Retrieve your access token from SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? screenWidth * 0.1 : 20.0,
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Description Section
            isTablet
                ? _buildAddDescriptionSection(isTablet)
                : _buildAddDescriptionSection(isTablet),
            const SizedBox(height: 30),

            // Name and Price Section
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextFieldSection(
                          'Name',
                          'Type here',
                          isTablet,
                          controller: nameController,
                        ),
                      ),
                      SizedBox(width: isTablet ? 30 : 0),
                      Expanded(
                        child: _buildTextFieldSection(
                          'Price',
                          'Type here',
                          isTablet,
                          controller: priceController,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextFieldSection(
                        'Name',
                        'Type here',
                        isTablet,
                        controller: nameController,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFieldSection(
                        'Price',
                        'Type here',
                        isTablet,
                        controller: priceController,
                      ),
                    ],
                  ),
            const SizedBox(height: 30),

            // Category and Status Section
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextFieldSection(
                          'Category',
                          'Type here',
                          isTablet,
                          controller: categoryController,
                        ),
                      ),
                      // Expanded(
                      //   child: _buildDropdownSection('Category', [
                      //     'Appetizers',
                      //     'Main Course',
                      //     'Desserts',
                      //     'Drinks',
                      //   ], isTablet),
                      // ),
                      SizedBox(width: isTablet ? 30 : 0),
                      Expanded(
                        child: _buildDropdownSection(
                          'Status',
                          ['Available', 'Unavailable'],
                          isTablet,
                          statusController,
                        ),
                      ),

                      // Expanded(
                      //   child: _buildDropdownSection('Status', [
                      //     'Available',
                      //     'Unavailable',
                      //   ], isTablet),
                      // ),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextFieldSection(
                        'Category',
                        'Type here',
                        isTablet,
                        controller: categoryController,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdownSection(
                        'Status',
                        ['Available', 'Not Available'],
                        isTablet,
                        statusController,
                      ),
                    ],
                  ),
            const SizedBox(height: 30),

            // Add Item Button
            Center(
              child: SizedBox(
                width: isTablet ? 300 : double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    createFoodItem();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Add Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Add Description Section
  Widget _buildAddDescriptionSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Description',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: isTablet ? 200 : 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Type here',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isTablet ? 16 : 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
            ),
            controller: descriptionController,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Generic text input section for name, price, etc.
  Widget _buildTextFieldSection(
    String title,
    String hintText,
    bool isTablet, {
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isTablet ? 16 : 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSection(
    String title,
    List<String> items,
    bool isTablet,
    TextEditingController controller,
  ) {
    // Ensure controller has a value (default first item)
    if (controller.text.isEmpty) {
      controller.text = items.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              isExpanded: true,
              value: controller.text,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.black87,
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.text = newValue; // ✅ updates the API field
                }
              },
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
