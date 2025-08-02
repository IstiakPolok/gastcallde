import 'package:get/get.dart';

class RoleSelectController extends GetxController {
  // List of all options
  final List<String> options = [
    'Substance counselor',
    'Career counseling',
    'Life coach',
    'Therapist',
    'Personal growth',
    'Counselling',
    'Trauma therapist',
    'Mentor for youth',
    'Family counseling',
    'Parent counseling',
    'Couples counseling',
    'Marriage counseling',
    'Build confidence',
    'Rehabilitation counseling',
    'Tutoring adults',
    'Identity counseling',
    'Tutoring kids',
    'Stay motivated',
    'Self love',
    'Build character',
    'Build Discipline',
    'Build accountability',
    'VETERAN/GOV',
  ];

  // Observable set to track selected options
  var selectedOptions = <String>{}.obs;

  void toggleOption(String option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
    } else {
      selectedOptions.add(option);
    }
  }
}
