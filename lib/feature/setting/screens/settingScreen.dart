import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/calls/widgets/calldetaildilog.dart';
import 'package:gastcallde/feature/setting/screens/ReportIssue.dart';
import 'package:gastcallde/feature/setting/screens/ReservationSettings.dart';
import 'package:gastcallde/feature/setting/screens/callforward.dart';
import 'package:intl/intl.dart';

class settingScreen extends StatelessWidget {
  settingScreen({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: isMobile
          ? AppBar(title: const Text('Restaurant Overview'))
          : null,
      drawer: isMobile
          ? ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return CustomDrawer(
                  selectedIndex: 6,
                  onItemSelected: (index) {
                    _selectedIndexNotifier.value = index;
                  },
                );
              },
            )
          : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  return CustomNavigationRail(
                    selectedIndex: 6,
                    onDestinationSelected: (index) {
                      _selectedIndexNotifier.value = index;
                    },
                  );
                },
              ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
                  // You can switch views here based on selectedIndex
                  return SettingsScreen();
                  // Assuming callDashboard is the widget for call logs
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _voiceSpeed = 0.5;
  double _ambientNoise = 0.5;
  String _callTransferText = '';
  String _specialPromotionsText = '';
  String _selectedVoice = 'Alisaya'; // Initial voice selection
  final List<String> _voiceOptions = [
    'Alisaya',
    'Sophia',
    'John',
    'Emma',
  ]; // List of voice options

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light background color
      appBar: AppBar(
        toolbarHeight: 150, // Increased height for title and subtitle
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Live Overview of your restaurant\'s',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Call Forwarding'),
                Tab(text: 'Reservation Settings'),
                Tab(text: 'Admin Support'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSettingsTab(),
          CallForwardingScreen(), // Assuming you have a CallForwardingScreen widget
          ReservationSettingsScreen(),
          ReportIssue(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('AI Voice Settings'),
        _buildCard(
          children: [
            _buildSettingRow(
              'Choose voice',
              'Live Overview of your restaurant\'s',
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://static.vecteezy.com/system/resources/previews/032/176/197/non_2x/business-avatar-profile-black-icon-man-of-user-symbol-in-trendy-flat-style-isolated-on-male-profile-people-diverse-face-for-social-network-or-web-vector.jpg',
                        ), // Placeholder image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedVoice, // Display the selected voice
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'English Girl - young',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Add your play functionality here
                    },
                  ),
                  DropdownButton<String>(
                    value: _selectedVoice,
                    onChanged: (newVoice) {
                      setState(() {
                        _selectedVoice = newVoice!; // Update selected voice
                      });
                    },
                    items: _voiceOptions.map((String voice) {
                      return DropdownMenuItem<String>(
                        value: voice,
                        child: Text(voice),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          children: [
            _buildSettingRow(
              'Voice speed',
              'Live Overview of your restaurant\'s',
              Slider(
                value: _voiceSpeed,
                min: 0.0,
                max: 1.0,
                activeColor: AppColors.primaryColor,
                inactiveColor: Colors.grey[300],
                onChanged: (newValue) {
                  setState(() {
                    _voiceSpeed = newValue;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // _buildCard(
        //   children: [
        //     _buildSettingRow(
        //       'Ambient noise',
        //       'Live Overview of your restaurant\'s',
        //       Slider(
        //         value: _ambientNoise,
        //         min: 0.0,
        //         max: 1.0,
        //         activeColor: AppColors.primaryColor,
        //         inactiveColor: Colors.grey[300],
        //         onChanged: (newValue) {
        //           setState(() {
        //             _ambientNoise = newValue;
        //           });
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 24),

        // Call Transfer Section
        _buildSectionTitle('Call Transfer'),
        _buildCard(
          children: [
            Text(
              'Transfer call AI to restaurant staff when',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _callTransferText),
              onChanged: (value) {
                setState(() {
                  _callTransferText = value;
                });
              },
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type here',
                fillColor: const Color(0xFFF8F9FB),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Restaurant Address Section
        _buildSectionTitle('Restaurant Address'),
        _buildCard(
          children: [
            _buildDropdownField(
              icon: Icons.location_on_outlined,
              text: '122, Location, Main City-Nagpur, city\nLand park street',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Business hours Section
        _buildSectionTitle('Business hours'),
        _buildCard(
          children: [
            _buildDropdownField(icon: Icons.access_time, text: '10 am - 11 pm'),
          ],
        ),
        const SizedBox(height: 24),

        // Special promotions Section
        _buildSectionTitle('Special promotions'),
        _buildCard(
          children: [
            Text(
              'AI will mention during calls',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _specialPromotionsText),
              onChanged: (value) {
                setState(() {
                  _specialPromotionsText = value;
                });
              },
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type here',
                fillColor: const Color(0xFFF8F9FB),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12.0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, String subtitle, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        control,
      ],
    );
  }

  Widget _buildDropdownField({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        ],
      ),
    );
  }
}
