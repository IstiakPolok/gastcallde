import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/global_widegts/CustomDrawer.dart';
import 'package:gastcallde/core/global_widegts/CustomNavigationRail.dart';
import 'package:gastcallde/feature/menuManagement/controllers/menuManagmentController.dart';
import 'package:gastcallde/feature/menuManagement/screens/EditFoodScreen.dart';
import 'package:gastcallde/feature/menuManagement/screens/ExtrasScreen.dart';
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
  final int id;
  final String name;
  final String status;
  final String description;
  final String category;
  final String price;
  final String preparationTime;
  final String? discount;

  Item({
    required this.id,
    required this.name,
    required this.status,
    required this.description,
    required this.category,
    required this.price,
    required this.preparationTime,
    required this.discount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? '',
      name: json['item_name'] ?? '',
      status: json['status'] ?? '',
      description: json['descriptions'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? '',
      preparationTime: json['preparation_time'] ?? '',
      discount: json['discount'] ?? '',
    );
  }
}

class ItemsScreen extends StatefulWidget {
  // Changed from StatelessWidget to StatefulWidget
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<Item> _allItems = []; // Store all items
  List<Item> _filteredItems = []; // Filtered items for search
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _debounce; // Timer for debounce

  @override
  void initState() {
    super.initState();
    _loadItems();

    // Listen to search input changes
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _filterItems();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await fetchItems();
      if (!mounted) return;
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        _allItems = [];
        _filteredItems = [];
      });
      print('Error loading menu items: $error');
    }
  }

  void _filterItems() {
    if (!mounted) return;
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredItems = _allItems.where((item) {
        final nameMatch = item.name.toLowerCase().contains(query);
        final categoryMatch = item.category.toLowerCase().contains(query);
        return nameMatch || categoryMatch; // Search in name OR category
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'items'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
                    child: TextField(
                      controller: _searchController, // <-- Added controller
                      decoration: InputDecoration(
                        hintText: 'search_hint'.tr, // Updated hint
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
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
                    'add_item'.tr,
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(ExtrasScreen());
                  },
                  icon: const Icon(Icons.art_track, color: Colors.white),
                  label: Text(
                    'extras'.tr,
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text('Error: $_errorMessage'))
                  : _filteredItems.isEmpty
                  ? Center(child: Text('no_items_found'.tr))
                  : isTablet
                  ? Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'item'.tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'status'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'category'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'price'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'action'.tr,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: _buildTabletItemRow(item, context),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return _buildMobileItemCard(item, context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tablet view: Row layout
  Widget _buildTabletItemRow(Item item, BuildContext context) {
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
                  Flexible(
                    child: Text(
                      item.name,
                      softWrap: true,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item.status,
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
                        Get.to(EditFoodScreen(item: item));
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(item.id, context);
                      },
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
  Widget _buildMobileItemCard(Item item, BuildContext context) {
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
              'Availability: ${item.status}',
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
                    Get.to(EditFoodScreen(item: item));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(item.id, context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int itemId, BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Are you sure you want to delete this item?'),
        content: const Text('This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Get.back(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Get.back(); // Close the dialog
              EasyLoading.show(status: 'Deleting...'); // Show loading indicator

              try {
                await deleteItem(itemId); // Call the delete method
                EasyLoading.dismiss();
                Get.snackbar('Success', 'Item deleted successfully');
                _loadItems(); // Refresh the list
              } catch (error) {
                EasyLoading.dismiss();
                Get.snackbar('Error', 'Failed to delete item: $error');
              }
            },
          ),
        ],
      ),
    );
  }
}
