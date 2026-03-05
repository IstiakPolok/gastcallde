import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:get/get.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/calls/screens/callScreen.dart';
import 'package:http/http.dart' as http;

class CallDetailsDialog extends StatefulWidget {
  const CallDetailsDialog(this.entry, {super.key});
  final CallEntry entry;
  final bool _isCallbackScheduled = false;

  @override
  State<CallDetailsDialog> createState() => _CallDetailsDialogState();
}

class _CallDetailsDialogState extends State<CallDetailsDialog> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    print(
      "🔧 CallDetailsDialog initState called for call ID: ${widget.entry.id}",
    );
    print("📞 Customer: ${widget.entry.customer}");
    print("🎵 Recording URL: ${widget.entry.recording}");
    audioPlayer = AudioPlayer();
    print("✅ AudioPlayer initialized");
  }

  @override
  void dispose() {
    print(
      "🧹 CallDetailsDialog dispose called for call ID: ${widget.entry.id}",
    );
    audioPlayer.dispose();
    print("✅ AudioPlayer disposed");
    super.dispose();
  }

  Future<void> markCallback(CallEntry entry) async {
    print("📞 markCallback() called for call ID: ${entry.id}");

    if (entry.callback) {
      print("⚠️ Callback already marked, skipping...");
      return;
    }

    print("🔑 Fetching access token...");
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null) {
      print("❌ No token found, cannot mark callback");
      return;
    }
    print("✅ Token found");

    final url = "${Urls.baseUrl}/owner/user-call/callback/${entry.id}/";
    print("🌐 API URL: $url");

    try {
      print("📤 Sending PATCH request to mark callback...");
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"callback": true}),
      );

      print("📥 Response status code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          entry.callback = true; // UI updates immediately
        });
        print("✅ Callback marked successfully for call id: ${entry.id}");
      } else {
        print(
          "❌ Failed to mark callback | Status: ${response.statusCode} | Response: ${response.body}",
        );
      }
    } catch (e) {
      print("🔥 Exception while marking callback: $e");
    }
  }

  void _togglePlay() async {
    print(
      "🎵 _togglePlay() called | Current state: ${isPlaying ? 'Playing' : 'Stopped'}",
    );

    if (isPlaying) {
      print("⏸️ Stopping audio playback...");
      await audioPlayer.stop();
      print("✅ Audio stopped");
    } else if (widget.entry.recording.isNotEmpty) {
      print("▶️ Starting audio playback...");
      print("🎵 Recording URL: ${widget.entry.recording}");
      try {
        await audioPlayer.setSource(UrlSource(widget.entry.recording));
        print("✅ Audio source set");
        await audioPlayer.resume();
        print("✅ Audio playback started");
      } catch (e) {
        print("🔥 Error playing audio: $e");
      }
    } else {
      print("⚠️ No recording available to play");
    }

    setState(() {
      isPlaying = !isPlaying;
    });
    print("🔄 New playback state: ${isPlaying ? 'Playing' : 'Stopped'}");
  }

  @override
  Widget build(BuildContext context) {
    print("🎨 Building CallDetailsDialog for call ID: ${widget.entry.id}");
    final entry = widget.entry;
    return Dialog(
      backgroundColor: const Color(0xFFF6F8FB),
      insetPadding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              decoration: const BoxDecoration(color: AppColors.primaryColor),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.white),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'call_details'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        entry.customer,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (!entry.callback)
                    ElevatedButton(
                      onPressed: () async {
                        await markCallback(entry);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF139783),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                      ),
                      child: Text('callback'.tr),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "done".tr,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // Main Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    return SingleChildScrollView(
                      child: isMobile
                          ? Column(
                              children: [
                                _buildLeftColumn(),
                                const SizedBox(height: 16),
                                _buildRightColumn(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: _buildLeftColumn()),
                                const SizedBox(width: 16),
                                Expanded(flex: 1, child: _buildRightColumn()),
                              ],
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Left column content
  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildCard(
          titleIcon: Icons.person,
          title: 'customer_information'.tr,
          info: [
            ['name'.tr, (widget.entry.customer)],
            ['phone'.tr, (widget.entry.phone)],
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          titleIcon: Icons.access_time,
          title: 'call_information'.tr,
          info: [
            ['date'.tr, (widget.entry.date)],
            ['time'.tr, (widget.entry.time)],
            ['duration'.tr, (widget.entry.duration)],
            ['type'.tr, (widget.entry.type)],
          ],
        ),
      ],
    );
  }

  /// Right column content
  Widget _buildRightColumn() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'call_summary'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                widget.entry.summary.isNotEmpty
                    ? widget.entry.summary
                    : 'no_summary_available'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Inside your _buildRightColumn() before return

            // --- Audio Player UI ---
            StreamBuilder<Duration>(
              stream: audioPlayer.onPositionChanged,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: audioPlayer.onDurationChanged,
                  builder: (context, snapshot) {
                    final total = snapshot.data ?? Duration.zero;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          min: 0,
                          max: total.inSeconds.toDouble(),
                          value: position.inSeconds
                              .clamp(0, total.inSeconds)
                              .toDouble(),
                          activeColor: AppColors.primaryColor,
                          onChanged: (value) async {
                            await audioPlayer.seek(
                              Duration(seconds: value.toInt()),
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatTime(position),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _formatTime(total),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            if (widget.entry.recording.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: _togglePlay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isPlaying ? "Pause" : "Play"),
              ),
            ],

            // if (widget.entry.recording.isNotEmpty)
            //   ElevatedButton.icon(
            //     onPressed: _togglePlay,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
            //     label: Text(isPlaying ? "Stop Recording" : "Play Recording"),
            //   ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Switch(
            //       value: _isCallbackScheduled,
            //       onChanged: null,
            //       activeColor: Colors.white,
            //       activeTrackColor: const Color(0xFF139783),
            //       inactiveThumbColor: const Color(0xFF9CA3AF),
            //       inactiveTrackColor: const Color(0xFFE5E7EB),
            //     ),
            //     const SizedBox(width: 8),
            //     const Text(
            //       'Schedule a callback',
            //       style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  /// Reusable info card
  Widget _buildCard({
    required IconData titleIcon,
    required String title,
    required List<List<String>> info,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color.fromARGB(134, 229, 231, 235)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(titleIcon, color: const Color(0xFF4B5563), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...info.map(
              (pair) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pair[0],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    Text(
                      pair[1],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
