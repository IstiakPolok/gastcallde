import 'package:flutter/material.dart';

class EditFoodScreen extends StatelessWidget {
  const EditFoodScreen({super.key});

  // Placeholder values for dropdowns
  final List<String> categories = const ['Junk', 'Healthy', 'Dessert'];
  final List<String> products = const ['Popular', 'New', 'Seasonal'];
  final List<String> statuses = const [
    'Available',
    'Out of Stock',
    'Coming Soon',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Handle back button press
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Food',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define a breakpoint for switching between single and two-column layout
            const double breakpoint = 600.0;
            final bool isTwoColumn = constraints.maxWidth > breakpoint;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section: Edit Picture and Add Description
                isTwoColumn
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _buildEditPictureCard()),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: _buildAddDescriptionCard()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildEditPictureCard(),
                          const SizedBox(height: 16),
                          _buildAddDescriptionCard(),
                        ],
                      ),
                const SizedBox(height: 20),

                // Input fields section: Name, Price, Category, Product, Status
                isTwoColumn
                    ? Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  'Name',
                                  'Chicken Burger',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInputField(
                                  'Price',
                                  'Type here',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  'Category',
                                  categories,
                                  'Junk',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdownField(
                                  'Product',
                                  products,
                                  'Popular',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField('Status', statuses, 'Available'),
                        ],
                      )
                    : Column(
                        children: [
                          _buildInputField('Name', 'Chicken Burger'),
                          const SizedBox(height: 16),
                          _buildInputField(
                            'Price',
                            'Type here',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField('Category', categories, 'Junk'),
                          const SizedBox(height: 16),
                          _buildDropdownField('Product', products, 'Popular'),
                          const SizedBox(height: 16),
                          _buildDropdownField('Status', statuses, 'Available'),
                        ],
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper function to build the "Edit Picture" card
  Widget _buildEditPictureCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://greatrangebison.com/wp-content/uploads/2023/07/caramelized-onion-burger-featured-image.jpg', // Placeholder image
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200, // Adjusted height for better fit
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build the "Add Description" card
  Widget _buildAddDescriptionCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue:
                  'A mouth-watering crispy chicken burger featuring a perfectly seasoned and breaded chicken breast, fresh lettuce, ripe tomatoes, creamy mayo, and our signature sauce, all nestled in a toasted brioche bun. A mouth-watering.',
              maxLines: null, // Allows multiline input
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              decoration: const InputDecoration(
                border: OutlineInputBorder(), // Add border for clarity
                hintText: 'Enter description...',
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (value) {
                // You can handle text change here if needed
                print('Updated Description: $value');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build an input text field
  Widget _buildInputField(
    String label,
    String initialValue, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextField(
          controller: TextEditingController(text: initialValue),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), // Rounded border
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  // Helper function to build a dropdown field
  Widget _buildDropdownField(
    String label,
    List<String> items,
    String selectedValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(10), // Rounded border
            border: Border.all(color: Colors.grey), // Optional border color
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: (String? newValue) {
                // Handle change (in real usage, update state)
                print('$label changed to: $newValue');
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
