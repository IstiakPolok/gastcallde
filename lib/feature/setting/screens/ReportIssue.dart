import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:http/http.dart' as http;

import '../../../core/network_caller/endpoints.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class ReportIssue extends StatefulWidget {
  const ReportIssue({super.key});

  @override
  State<ReportIssue> createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue> {
  final TextEditingController _issueSummaryController = TextEditingController();
  final TextEditingController _issueDetailsController = TextEditingController();
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'gif', 'svg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitIssue() async {
    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ No token found")));
      return;
    }

    final url = Uri.parse("${Urls.baseUrl}/owner/create-support/");
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = "Bearer $token";

    request.fields['issue'] = _issueSummaryController.text.trim();
    request.fields['issue_details'] = _issueDetailsController.text.trim();

    if (_selectedFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('uploaded_file', _selectedFile!.path),
      );
    }

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        print("✅ Issue reported successfully: $body");

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Issue submitted successfully")),
        );

        // ⬅️ Clear the form
        setState(() {
          _issueSummaryController.clear();
          _issueDetailsController.clear();
          _selectedFile = null;
        });
      } else {
        print("❌ Failed to submit issue: $body");

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Failed: $body")));
      }
    } catch (e) {
      print("🔥 Exception: $e");

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("🔥 Error: $e")));
    }
  }

  @override
  void dispose() {
    _issueSummaryController.dispose();
    _issueDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Report an Issue',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issue Summary Text Field
              _buildTextField(
                controller: _issueSummaryController,
                hintText: 'e.g., Issue with approval process',
              ),
              const SizedBox(height: 24),

              // Issue Details Section
              const Text(
                'Issue details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              _buildMultilineTextField(
                controller: _issueDetailsController,
                hintText:
                    '', // No specific hint text in the image for this field
              ),
              const SizedBox(height: 24),

              // Upload File Section
              const Text(
                'Upload File',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              _buildFileUploadArea(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: _submitIssue,

          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.primaryColor, // Blue color for submit button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
          ),
        ),
        style: const TextStyle(color: Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildMultilineTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      height: 120, // Adjust height as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: null, // Allows multiple lines
        expands: true, // Allows the text field to expand vertically
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
          ),
        ),
        style: const TextStyle(color: Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildFileUploadArea() {
    return Container(
      height: 200, // Adjust height as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFCBD5E1), // Light grey border
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined, // Cloud upload icon
              color: const Color(0xFF64748B),
              size: 40,
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                children: [
                  const TextSpan(text: 'Drop your files here or '),
                  TextSpan(
                    text: 'Click to upload',
                    style: const TextStyle(
                      color: Color(0xFF007BFF), // Blue color for link
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _pickFile,
                  ),
                ],
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                "Selected: ${_selectedFile!.path.split('/').last}",
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],

            const SizedBox(height: 5),
            const Text(
              'SVG, PNG, JPG or GIF (max. 800x400px)',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
