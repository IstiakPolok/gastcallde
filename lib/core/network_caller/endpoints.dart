class Urls {
  // static const String baseUrl = 'https://sacred-renewing-dove.ngrok-free.app';
  // static const String baseUrl = 'http://10.10.13.26:9002';
  static const String baseUrl = 'https://api.trusttaste.ai';

  static const String login = '$baseUrl/login/?lean=';
  static const String register = '$baseUrl/register/?lean=';
  static const String sendOtp = '$baseUrl/send-otp/';
  static const String verifyOtp = '$baseUrl/verify-otp/';
  static const String uploadmenu = '$baseUrl/owner/extract-menu/';
  static const String getSubscriptionPlan = '$baseUrl/packages/?lean=';
  static const String createTable = '$baseUrl/owner/table/create/?lean=';
  static const String createReservation = '$baseUrl/owner/reservations/create/';
  static const String tableList = '$baseUrl/owner/table/?lean=';
  static const String getReservationList = '$baseUrl/owner/reservations/?date=';
  static const String getReservationstats =
      '$baseUrl/owner/reservation-stats/?date=';
  static const String updateTableStatus =
      '$baseUrl/owner/update-table-status/?date=';
  static const String getTablegridReservations =
      '$baseUrl/owner/table-reservations/?date=';

  static const String subscriptionUrl =
      '$baseUrl/subscription/create-checkout-session/';

  static const String updateProfile = '$baseUrl/auth/profile';
  static const String updateProfileImage = '$baseUrl/auth/update/profile-image';
  static const String getProfile = '$baseUrl/auth/profile';
  static const String deleteProfile = '$baseUrl/users/';
  static const String createGroup = '$baseUrl/group/create';
  static const String myGrouplist = '$baseUrl/group/my-groups';
  static const String groupAddMember = '$baseUrl/group/add';
  static const String refreshToken = '$baseUrl/token/refresh/';
  static const String getDeliveryAreas = '$baseUrl/owner/areas/';
  static const String addDeliveryArea = '$baseUrl/owner/areas/';
  static const String weeklySchedule = '$baseUrl/owner/open-close-times/';
}
