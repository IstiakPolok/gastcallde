import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/feature/auth/signUp/screens/UploadFilesScreen.dart';
import 'package:gastcallde/feature/menuManagement/screens/UploadFiles.dart';
import 'package:gastcallde/feature/menuManagement/screens/uploadMenually.dart';

class UploadFoodMenuScreen extends StatefulWidget {
  final int selectedSegment;

  const UploadFoodMenuScreen({super.key, this.selectedSegment = 0});

  @override
  State<UploadFoodMenuScreen> createState() => _UploadFoodMenuScreenState();
}

class _UploadFoodMenuScreenState extends State<UploadFoodMenuScreen> {
  PlatformFile? _selectedFile;
  late ValueNotifier<bool> isListView;

  @override
  void initState() {
    super.initState();
    isListView = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    isListView.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    //final ValueNotifier<bool> isListView = ValueNotifier<bool>(true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Column(
          children: [
            const Text(
              'Upload Food Menu',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? screenWidth * 0.15 : 20.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              Text(
                'Choose the method that works best for you to add your restaurant menu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 16 : 14,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: isListView,
                      builder: (context, isListViewActive, child) {
                        return ElevatedButton(
                          onPressed: () {
                            isListView.value = true; // Set to ListView
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: isListViewActive
                                ? AppColors.primaryColor
                                : Colors.grey[300],
                          ),
                          child: Text(
                            'Upload Menu',
                            style: TextStyle(
                              color: isListViewActive
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    ValueListenableBuilder<bool>(
                      valueListenable: isListView,
                      builder: (context, isListViewActive, child) {
                        return ElevatedButton(
                          onPressed: () {
                            isListView.value = false; // Set to GridView
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: !isListViewActive
                                ? AppColors.primaryColor
                                : Colors.grey[300],
                          ),

                          child: Text(
                            'Upload manually',
                            style: TextStyle(
                              color: !isListViewActive
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              ValueListenableBuilder<bool>(
                valueListenable: isListView,
                builder: (context, isListViewActive, child) {
                  return Container(
                    // Adjust container height
                    // Green when GridView is active
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // First text to show which view is active

                          // Conditional Column: Different content for ListView vs GridView
                          if (isListViewActive)
                            SingleChildScrollView(
                              child: _buildUploadPdfSection(isTablet),
                            )
                          else
                            AddFoodItemScreen(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildSegmentedControl(bool isTablet) {
  //   return Container(
  //     padding: const EdgeInsets.all(4),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         _buildSegmentButton(
  //           label: 'Upload Menu',
  //           icon: Icons.upload_file,
  //           index: 0,
  //           isTablet: isTablet,
  //         ),
  //         _buildSegmentButton(
  //           label: 'Upload manually',
  //           icon: Icons.upload,
  //           index: 1,
  //           isTablet: isTablet,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSegmentButton({
  //   required String label,
  //   required IconData icon,
  //   required int index,
  //   required bool isTablet,
  // }) {
  //   final bool isSelected = widget.selectedSegment == index;
  //   return GestureDetector(
  //     onTap: () {
  //       debugPrint('Tapped $label');
  //     },
  //     child: Container(
  //       padding: EdgeInsets.symmetric(
  //         horizontal: isTablet ? 24 : 16,
  //         vertical: 12,
  //       ),
  //       decoration: BoxDecoration(
  //         color: isSelected ? Colors.white : Colors.transparent,
  //         borderRadius: BorderRadius.circular(10),
  //         boxShadow: isSelected
  //             ? [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.1),
  //                   blurRadius: 6,
  //                   offset: const Offset(0, 3),
  //                 ),
  //               ]
  //             : null,
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             color: isSelected ? const Color(0xFF00BFA5) : Colors.grey[700],
  //             size: isTablet ? 22 : 18,
  //           ),
  //           SizedBox(width: isTablet ? 10 : 6),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               color: isSelected ? const Color(0xFF00BFA5) : Colors.grey[700],
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //               fontSize: isTablet ? 16 : 14,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildUploadPdfSection(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload PDF Menu',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your menu as a PDF file. We support files up to 10MB.',
            style: TextStyle(
              fontSize: isTablet ? 15 : 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose PDF File',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          UploadFileswidget(),

          // GestureDetector(
          //   onTap: _pickPdfFile,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border.all(color: Colors.grey, width: 1.5),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     padding: EdgeInsets.all(isTablet ? 40 : 20),
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.cloud_upload,
          //             size: isTablet ? 60 : 48,
          //             color: Colors.grey[400],
          //           ),
          //           const SizedBox(height: 16),
          //           if (_selectedFile == null)
          //             RichText(
          //               textAlign: TextAlign.center,
          //               text: TextSpan(
          //                 style: TextStyle(
          //                   fontSize: isTablet ? 16 : 14,
          //                   color: Colors.grey[700],
          //                 ),
          //                 children: <TextSpan>[
          //                   const TextSpan(text: 'Drop your files here or '),
          //                   TextSpan(
          //                     text: 'Click to upload',
          //                     style: TextStyle(
          //                       color: const Color(0xFF00BFA5),
          //                       fontWeight: FontWeight.bold,
          //                       decoration: TextDecoration.underline,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             )
          //           else
          //             Text(
          //               _selectedFile!.name,
          //               style: TextStyle(
          //                 fontSize: isTablet ? 16 : 14,
          //                 color: Colors.black87,
          //               ),
          //             ),
          //           const SizedBox(height: 8),
          //           Text(
          //             'PDF (max. 10MB)',
          //             style: TextStyle(
          //               fontSize: isTablet ? 13 : 11,
          //               color: Colors.grey[500],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
