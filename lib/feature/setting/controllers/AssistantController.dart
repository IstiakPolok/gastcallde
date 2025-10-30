import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class AssistantController extends GetxController {
  var isLoading = true.obs;
  var assistantId = 0.obs;
  var voice = ''.obs;
  var speed = 1.0.obs;
  var isPlaying = false.obs;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    fetchAssistantInfo();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> fetchAssistantInfo() async {
    try {
      isLoading.value = true;
      final String? token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        print('Token is null');
        return;
      }

      final response = await http.get(
        Uri.parse('${Urls.baseUrl}/owner/my/assistant/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Assistant API Status Code: ${response.statusCode}');
      print('Assistant API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        assistantId.value = data['id'] ?? 0;
        voice.value = data['voice'] ?? 'matilda';
        // Handle both int and double from API
        final speedValue = data['speed'];
        speed.value = (speedValue is int)
            ? speedValue.toDouble()
            : (speedValue is double)
            ? speedValue
            : 1.0;
        print('Loaded assistant: voice=${voice.value}, speed=${speed.value}');
      } else {
        print('Failed to load assistant info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching assistant info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateVoiceSettings(String voiceId, double speedValue) async {
    try {
      final String? token = await SharedPreferencesHelper.getAccessToken();

      if (token == null) {
        print('Token is null');
        return false;
      }

      final body = jsonEncode({'speed': speedValue, 'voice_id': voiceId});

      print('Updating voice with: $body');

      final response = await http.post(
        Uri.parse('${Urls.baseUrl}/owner/assistance/update-voice/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Update API Status Code: ${response.statusCode}');
      print('Update API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update local values with proper type conversion
        voice.value = data['voice']['voiceId'] ?? voiceId;
        speed.value = (data['voice']['speed'] is int)
            ? (data['voice']['speed'] as int).toDouble()
            : (data['voice']['speed'] as double);
        print('Successfully updated voice settings');
        return true;
      } else {
        print('Failed to update voice settings: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating voice settings: $e');
      return false;
    }
  }

  // Voice options with display names
  Map<String, String> get voiceOptions => {
    'andrea': 'Andrea',
    'burt': 'Burt',
    'drew': 'Drew',
    'joseph': 'Joseph',
    'marissa': 'Marissa',
    'mark': 'Mark',
    'matilda': 'Matilda',
    'mrb': 'MRB',
    'myra': 'Myra',
    'paul': 'Paul',
    'paula': 'Paula',
    'phillip': 'Phillip',
    'ryan': 'Ryan',
    'sarah': 'Sarah',
    'steve': 'Steve',
  };

  String getVoiceDisplayName(String voiceId) {
    return voiceOptions[voiceId.toLowerCase()] ?? voiceId;
  }

  // Get voice file path for preview
  String getVoiceFilePath(String voiceId) {
    return 'assets/voices/${voiceId.toLowerCase()}.mp3';
  }

  // Play voice preview
  Future<void> playVoicePreview(String voiceId) async {
    try {
      isPlaying.value = true;
      final filePath = getVoiceFilePath(voiceId);

      await _audioPlayer.stop(); // Stop any currently playing audio
      await _audioPlayer.play(
        AssetSource('voices/${voiceId.toLowerCase()}.mp3'),
      );

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((event) {
        isPlaying.value = false;
      });

      print('Playing voice preview: $filePath');
    } catch (e) {
      print('Error playing voice preview: $e');
      isPlaying.value = false;
      // Fallback: show message if file doesn't exist
      Get.snackbar(
        'Voice Preview',
        'Voice sample not available. Please add ${voiceId.toLowerCase()}.mp3 to assets/voices/',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Stop voice preview
  Future<void> stopVoicePreview() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
    } catch (e) {
      print('Error stopping voice preview: $e');
    }
  }
}
