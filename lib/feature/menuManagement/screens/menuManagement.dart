import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/menuManagement/screens/EditFoodScreen.dart';
import 'package:gastcallde/feature/menuManagement/screens/FoodDetailsScreen.dart';
import 'package:gastcallde/feature/menuManagement/screens/UploadFoodMenuScreen.dart';
import 'package:get/get.dart';

class menuManagement extends StatelessWidget {
  menuManagement({super.key});

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double breakpoint = 600;
    final isMobile = screenWidth < breakpoint;

    return Scaffold(
      appBar: isMobile ? AppBar(title: const Text('Menu Management')) : null,
      drawer: isMobile
          ? ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                return CustomDrawer(
                  selectedIndex: 4,
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
                    selectedIndex: 4,
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
                  return ItemsScreen(); // Assuming callDashboard is the widget for call logs
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Item {
  //final String imageUrl;
  final String name;
  final String availability;
  final String category;
  final String price;
  final String description; // Added description field

  Item({
    // required this.imageUrl,
    required this.name,
    required this.availability,
    required this.category,
    required this.price,
    required this.description, // Added to constructor
  });
}

class ItemsScreen extends StatelessWidget {
  ItemsScreen({super.key});

  final List<Item> _items = [
    Item(
      // imageUrl:
      //     'https://cdn.sanity.io/images/czqk28jt/prod_plk_us/84bbcd43ce0d00ab85cc40e4c23f007e19501d21-2000x1333.png?q=70&auto=format',
      name: 'Chicken Popeyes',
      availability: 'In Stock',
      category: 'Junk',
      price: '\$30.00',
      description: 'Delicious fried chicken with a crispy coating.',
    ),
    Item(
      // imageUrl:
      // 'https://greatrangebison.com/wp-content/uploads/2023/07/caramelized-onion-burger-featured-image.jpg',
      name: 'Bison Burgers',
      availability: 'In Stock',
      category: 'Dessert',
      price: '\$40.00',
      description: 'Juicy bison patty served on a toasted bun.',
    ),
    Item(
      //imageUrl: 'https://static.toiimg.com/photo/54714340.cms',
      name: 'Grill Sandwich',
      availability: 'In Stock',
      category: 'Junk',
      price: '\$20.00',
      description: 'Classic grilled cheese sandwich with a golden crust.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Items',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar + Add Item button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(UploadFoodMenuScreen());
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 12,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 12,
                      vertical: isTablet ? 14 : 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Table Headers for tablet, labels for mobile
            if (isTablet)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Item',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Availability',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Action',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            // Item List
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: isTablet
                        ? _buildTabletItemRow(item)
                        : _buildMobileItemCard(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tablet view: Row layout
  Widget _buildTabletItemRow(Item item) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(8.0),
                  //   child: Image.network(
                  //     item.imageUrl,
                  //     width: 40,
                  //     height: 40,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  const SizedBox(width: 10),
                  Text(item.name),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.availability,
                style: const TextStyle(color: Colors.green),
              ),
            ),
            Expanded(flex: 2, child: Text(item.category)),
            Expanded(flex: 1, child: Text(item.price)),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Get.to(FoodDetailsScreen(item: item));
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Get.to(EditFoodScreen());
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[200], height: 1.0),
      ],
    );
  }

  /// Mobile view: Card layout
  Widget _buildMobileItemCard(Item item) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(8.0),
                //   child: Image.network(
                //     item.imageUrl,
                //     width: 60,
                //     height: 60,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Availability: ${item.availability}',
              style: const TextStyle(color: Colors.green),
            ),
            Text('Category: ${item.category}'),
            Text('Price: ${item.price}'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Get.to(FoodDetailsScreen(item: item));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  onPressed: () {
                    Get.to(EditFoodScreen());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
