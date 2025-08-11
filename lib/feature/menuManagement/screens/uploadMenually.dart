import 'package:flutter/material.dart';

class AddFoodItemScreen extends StatelessWidget {
  const AddFoodItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet
              ? screenWidth * 0.1
              : 20.0, // More padding for tablets
          vertical: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Picture and Add Description Section
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAddPictureSection(isTablet)),
                      SizedBox(width: isTablet ? 30 : 0),
                      Expanded(child: _buildAddDescriptionSection(isTablet)),
                    ],
                  )
                : Column(
                    children: [
                      _buildAddPictureSection(isTablet),
                      const SizedBox(height: 20),
                      _buildAddDescriptionSection(isTablet),
                    ],
                  ),
            const SizedBox(height: 30),

            // Name and Price Section
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextFieldSection(
                          'Name',
                          'Type here',
                          isTablet,
                        ),
                      ),
                      SizedBox(width: isTablet ? 30 : 0),
                      Expanded(
                        child: _buildTextFieldSection(
                          'Price',
                          'Type here',
                          isTablet,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextFieldSection('Name', 'Type here', isTablet),
                      const SizedBox(height: 20),
                      _buildTextFieldSection('Price', 'Type here', isTablet),
                    ],
                  ),
            const SizedBox(height: 30),

            // Category and Status Section
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDropdownSection('Category', [
                          'Appetizers',
                          'Main Course',
                          'Desserts',
                          'Drinks',
                        ], isTablet),
                      ),
                      SizedBox(width: isTablet ? 30 : 0),
                      Expanded(
                        child: _buildDropdownSection('Status', [
                          'Available',
                          'Unavailable',
                        ], isTablet),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildDropdownSection('Category', [
                        'Appetizers',
                        'Main Course',
                        'Desserts',
                        'Drinks',
                      ], isTablet),
                      const SizedBox(height: 20),
                      _buildDropdownSection('Status', [
                        'Available',
                        'Unavailable',
                      ], isTablet),
                    ],
                  ),
            const SizedBox(height: 30),

            // Add Item Button
            Center(
              child: SizedBox(
                width: isTablet ? 300 : double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Add Item button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5), // Teal color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Add Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget for the "Add Picture" section
  Widget _buildAddPictureSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Picture',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: isTablet ? 200 : 150, // Adjust height for responsiveness
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: isTablet ? 48 : 36,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),

                      // Line 1
                      Text(
                        'Drop your files here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 13,
                          color: Colors.grey[700],
                        ),
                      ),

                      // Line 2 - Click to Upload (styled)
                      GestureDetector(
                        onTap: () {
                          // Handle file pick here if needed
                        },
                        child: Text(
                          'Click to upload',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 15 : 13,
                            color: const Color(0xFF00BFA5),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Line 3
                      Text(
                        'SVG, PNG, JPG or GIF (max. 800x400px)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget for the "Add Description" section
  Widget _buildAddDescriptionSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Description',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: isTablet ? 200 : 150, // Match height of add picture section
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            maxLines: null, // Allows multiple lines
            expands: true, // Allows the text field to expand vertically
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Type here',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isTablet ? 16 : 14,
              ),
              border: InputBorder.none, // Remove default border
              contentPadding: EdgeInsets.all(isTablet ? 16 : 12),
            ),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Widget for generic text input fields (Name, Price)
  Widget _buildTextFieldSection(String title, String hintText, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isTablet ? 16 : 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.black87,
            ),
            keyboardType: title == 'Price'
                ? TextInputType.number
                : TextInputType.text,
          ),
        ),
      ],
    );
  }

  // Widget for dropdown sections (Category, Status)
  Widget _buildDropdownSection(
    String title,
    List<String> items,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value:
                  items.first, // Default selected value (for stateless example)
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.black87,
              ),
              onChanged: (String? newValue) {
                // In a StatelessWidget, this will not update the UI.
                // A parent StatefulWidget would manage the selected value.
                debugPrint('Selected: $newValue');
              },
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
