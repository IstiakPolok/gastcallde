class Urls {
  static const String baseUrl = 'http://10.10.13.26:9001';

  static const String login = '$baseUrl/login/?lean=';
  static const String register = '$baseUrl/register/?lean=';
  static const String sendOtp = '$baseUrl/send-otp/';
  static const String verifyOtp = '$baseUrl/verify-otp/';
  static const String uploadmenu = '$baseUrl/owner/extract-menu/';
  static const String getSubscriptionPlan = '$baseUrl/packages/?lean=';
  static const String createTable = '$baseUrl/owner/table/create/?lean=';

  static const String updateProfile = '$baseUrl/auth/profile';
  static const String updateProfileImage = '$baseUrl/auth/update/profile-image';
  static const String getProfile = '$baseUrl/auth/profile';
  static const String deleteProfile = '$baseUrl/users/';
  static const String createGroup = '$baseUrl/group/create';
  static const String myGrouplist = '$baseUrl/group/my-groups';
  static const String groupAddMember = '$baseUrl/group/add';
}
