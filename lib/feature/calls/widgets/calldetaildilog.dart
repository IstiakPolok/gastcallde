import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> markCallback(CallEntry entry) async {
    if (entry.callback) return;

    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null) return;

    final url = "${Urls.baseUrl}/owner/user-call/callback/${entry.id}/";
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"callback": true}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          entry.callback = true; // UI updates immediately
        });
        print("✅ Callback marked for call id: ${entry.id}");
      } else {
        print("❌ Failed to mark callback | Response: ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception while marking callback: $e");
    }
  }

  void _togglePlay() async {
    if (isPlaying) {
      await audioPlayer.stop();
    } else if (widget.entry.recording.isNotEmpty) {
      await audioPlayer.setSource(UrlSource(widget.entry.recording));
      await audioPlayer.resume();
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'Call Details',
                        style: TextStyle(
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
                      child: const Text('Callback'),
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
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.green),
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
          title: 'Customer Information',
          info: [
            ['Name', (widget.entry.customer)],
            ['Phone', (widget.entry.phone)],
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          titleIcon: Icons.access_time,
          title: 'Call Information',
          info: [
            ['Date', (widget.entry.date)],
            ['Time', (widget.entry.time)],
            ['Duration', (widget.entry.duration)],
            ['Type', (widget.entry.type)],
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
            const Text(
              'Call Summary',
              style: TextStyle(
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
                    : 'No summary available',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.entry.recording.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _togglePlay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isPlaying ? "Stop Recording" : "Play Recording"),
              ),
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
