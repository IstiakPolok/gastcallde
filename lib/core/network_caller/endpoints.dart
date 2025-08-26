class Urls {
  static const String baseUrl = 'http://10.10.13.26:9002';
  static const String login = '$baseUrl/login';
  static const String updateProfile = '$baseUrl/auth/profile';
  static const String updateProfileImage = '$baseUrl/auth/update/profile-image';
  static const String getProfile = '$baseUrl/auth/profile';
  static const String deleteProfile = '$baseUrl/users/';
  static const String createGroup = '$baseUrl/group/create';
  static const String myGrouplist = '$baseUrl/group/my-groups';
  static const String groupAddMember = '$baseUrl/group/add';
}
