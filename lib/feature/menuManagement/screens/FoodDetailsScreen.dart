import 'package:flutter/material.dart';
import 'package:gastcallde/feature/menuManagement/screens/menuManagement.dart';

class FoodDetailsScreen extends StatelessWidget {
  final Item item;

  const FoodDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Food Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive layout: Row for tablet, Column for mobile
            isTablet
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(isTablet: isTablet),
                      const SizedBox(width: 20),
                      _buildStatusCard(isTablet: isTablet),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSection(isTablet: isTablet),
                      const SizedBox(height: 20),
                      _buildStatusCard(isTablet: isTablet),
                    ],
                  ),
            const SizedBox(height: 20),
            _buildDescriptionCard(isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  // Image section
  Widget _buildImageSection({required bool isTablet}) {
    return Expanded(
      flex: isTablet ? 5 : 0,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: isTablet ? 300 : 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Status Card section
  Widget _buildStatusCard({required bool isTablet}) {
    return Expanded(
      flex: isTablet ? 3 : 0,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu Status',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              _buildDetailRow(
                'Category',
                item.category,
                isChip: true,
                chipColor: Colors.grey[200],
              ),
              _buildDetailRow(
                'Status',
                item.availability,
                isChip: true,
                chipColor: Colors.blue[100],
                textColor: Colors.blue[800],
              ),
              _buildDetailRow('Price', item.price),
              _buildDetailRow('Prep. time', '25 mins'),
              _buildDetailRow(
                'Product',
                'Popular',
                isChip: true,
                chipColor: Colors.green[100],
                textColor: Colors.green[800],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Description Section
  Widget _buildDescriptionCard({required bool isTablet}) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Description',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Detail row helper
  Widget _buildDetailRow(
    String label,
    String value, {
    bool isChip = false,
    Color? chipColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          if (isChip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: chipColor ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.black87,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
