import 'package:get/get.dart';

class signController extends GetxController {
  var isPasswordVisible = false.obs;
  var agreedToTerms = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleTermsAgreement(bool? value) {
    agreedToTerms.value = value ?? false;
  }
}
