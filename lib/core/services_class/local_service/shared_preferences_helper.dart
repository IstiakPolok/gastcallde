import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _accessTokenKey = 'token';
  static const String _selectedRoleKey = 'selectedRole';
  static const String _categoriesKey = "categories";
  static const String _isWelcomeDialogShownKey =
      'isDriverVerificationDialogShown';

  // Save categories (id and name only)
  static Future<void> saveCategories(
    List<Map<String, String>> categories,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final categoriesJson = jsonEncode(categories);
    await prefs.setString(_categoriesKey, categoriesJson);
  }

  // Retrieve categories (id and name only)
  static Future<List<Map<String, String>>> getCategories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson != null) {
      return List<Map<String, String>>.from(jsonDecode(categoriesJson));
    }
    return [];
  }

  // Save access token
  static Future<void> saveToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool tokenSaved = await prefs.setString(_accessTokenKey, token);
      bool loginFlagSaved = await prefs.setBool('isLogin', true);

      print('Token saved: $tokenSaved'); // Should print true
      print('Login flag saved: $loginFlagSaved'); // Should print true
    } catch (e) {
      print('Error saving token to SharedPreferences: $e');
    }
  }

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  // Retrieve access token
  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Clear access token
  static Future<void> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey); // Clear the token
    await prefs.remove(_selectedRoleKey); // Clear the role
    await prefs.remove('isLogin'); // Clear the login status
  }

  // Retrieve selected role
  static Future<String?> getSelectedRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedRoleKey);
  }

  static Future<bool?> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }

  // Save the flag indicating the dialog has been shown
  static Future<void> setWelcomeDialogShown(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isWelcomeDialogShownKey, value);
  }

  // Retrieve the flag to check if the dialog has been shown
  static Future<bool> isWelcomeDialogShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isWelcomeDialogShownKey) ?? false;
  }

  // Key for showOnboard
  static const String _showOnboardKey = 'showOnboard';

  // Save the showOnboard flag
  static Future<void> setShowOnboard(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showOnboardKey, value);
  }

  // Retrieve the showOnboard flag
  static Future<bool> getShowOnboard() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showOnboardKey) ??
        false; // Default to false if not set
  }

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ??
        'me'; // Default to 'me' if not found
  }

  static Future<void> logoutUser() async {
    await clearAllData();
    // Get.offAll(() => LoginView());
  }

  // Save the User ID
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // Retrieve the User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
}
