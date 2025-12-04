import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/auth/signUp/screens/SubmissionCompleteScreen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UploadFilesPage extends StatefulWidget {
  const UploadFilesPage({super.key});

  @override
  _UploadFilesPageState createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends State<UploadFilesPage> {
  final List<File> selectedFiles = [];
  String? bearerToken;
  final String apiUrl = Urls.uploadmenu;

  @override
  void initState() {
    super.initState();
    _getBearerToken();
  }

  Future<void> _getBearerToken() async {
    bearerToken = await SharedPreferencesHelper.getAccessToken();
  }

  // Function to pick multiple files (image or pdf)
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null) {
      Get.snackbar(
        'Files picked',
        'You have picked ${result.files.length} files',
        animationDuration: const Duration(milliseconds: 300),
      );
      print('Files picked: ${result.files.length}');
      setState(() {
        for (var file in result.files) {
          String? filePath = file.path;
          if (filePath != null) {
            selectedFiles.add(File(filePath));
            // Get.snackbar(
            //   'File Added',
            //   'Added file: ${filePath.split('/').last}',
            //   animationDuration: const Duration(milliseconds: 300),
            // );
            print('Added file: ${filePath.split('/').last}');
          }
        }
      });
    } else {
      print('No files selected');
    }
  }

  Future<void> uploadFiles() async {
    try {
      if (selectedFiles.isEmpty) {
        Get.snackbar('Error', 'Please select files to upload');
        return;
      }

      var uri = Uri.parse(apiUrl);

      // Debug: Print the API URL
      print('Sending request to: $uri');

      // Create a multipart request
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $bearerToken';

      // Add files to the request
      for (var file in selectedFiles) {
        String fileName = basename(file.path);
        print(
          'Adding file to request: $fileName',
        ); // Debug: Print each file being added

        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            file.path,
            filename: fileName,
          ),
        );
      }

      // Send the request with timeout
      var response = await request.send().timeout(
        const Duration(seconds: 120), // 2 minutes timeout
        onTimeout: () {
          throw Exception('Upload timed out. Please try with fewer or smaller files.');
        },
      );

      // Debug: Print response status and headers
      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      // Check the response status
      if (response.statusCode == 200) {
        print('Files uploaded successfully');
        Get.snackbar('Success', 'Files uploaded successfully!');
      } else {
        print('Failed to upload files: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to upload files');
      }

      // Debugging response body (if available)
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
      }
    } catch (e) {
      print('Error: $e');
      
      String errorMessage = 'An error occurred during the upload';
      
      if (e.toString().contains('Connection reset')) {
        errorMessage = 'Connection lost. Please check your internet and try again.';
      } else if (e.toString().contains('timed out')) {
        errorMessage = 'Upload timed out. Try uploading fewer files at once.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      
      Get.snackbar(
        'Upload Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Upload Menu (Images or PDF)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: Icon(Icons.cloud_upload_outlined),
            label: Text('Upload Files'),
          ),
          const SizedBox(height: 16),

          // Display selected files list
          const SizedBox(height: 8),
          selectedFiles.isNotEmpty
              ? Column(
                  children: [
                    const Text(
                      'Selected Files:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: selectedFiles.length,
                      itemBuilder: (context, index) {
                        File file = selectedFiles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                file.path.endsWith('.pdf')
                                    ? Icons.picture_as_pdf
                                    : Icons.image,
                                color: file.path.endsWith('.pdf')
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(file.path.split('/').last),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
              : Text(' '),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () {
                uploadFiles();
                Get.to(SubmissionCompleteScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Submit'),
            ),
          ),
          // ElevatedButton(onPressed: uploadFiles, child: Text('Submit')),
        ],
      ),
    );
  }
}
