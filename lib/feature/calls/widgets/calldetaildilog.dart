import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/calls/screens/callScreen.dart';

class CallDetailsDialog extends StatelessWidget {
  const CallDetailsDialog(this.entry, {super.key});

  final CallEntry entry;
  final bool _isCallbackScheduled = false;

  @override
  Widget build(BuildContext context) {
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
                  ElevatedButton(
                    onPressed: () {},
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
            ['Name', (entry.customer)],
            ['Phone', (entry.phone)],
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          titleIcon: Icons.access_time,
          title: 'Call Information',
          info: [
            ['Date', (entry.date)],
            ['Time', (entry.time)],
            ['Duration', (entry.duration)],
            ['Type', (entry.type)],
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
              child: const Text(
                'The customer said for two large burger The customer said for two large burger The customer said for two large burger...',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.play_circle_outline, color: Color(0xFF6B7280)),
                SizedBox(width: 4),
                Text(
                  'Play (2:30)',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            Row(
              children: [
                Switch(
                  value: _isCallbackScheduled,
                  onChanged: null,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF139783),
                  inactiveThumbColor: const Color(0xFF9CA3AF),
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Schedule a callback',
                  style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
                ),
              ],
            ),
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
