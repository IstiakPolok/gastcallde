// lib/feature/calls/order_entry_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gastcallde/core/const/app_colors.dart';
import 'package:gastcallde/core/network_caller/endpoints.dart';
import 'package:gastcallde/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:gastcallde/feature/delivery/controllers/delivery_info_controller.dart';
import 'package:gastcallde/feature/menuManagement/controllers/ExtrasController.dart';
import 'package:gastcallde/feature/orderManagment/models/food_item_model.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http/http.dart' as http;
import 'controllers/OrderEntryController.dart';
import 'controllers/MenuController.dart';

class OrderEntryScreen extends StatefulWidget {
  const OrderEntryScreen({super.key});

  @override
  State<OrderEntryScreen> createState() => _OrderEntryScreenState();
}

class _OrderEntryScreenState extends State<OrderEntryScreen> {
  final menuController = Get.put(Menu_Controller());
  final orderEntryController = Get.put(OrderEntryController());
  final deliveryController = Get.put(DeliveryInfoController());
  final extrasController = Get.put(ExtrasController());

  // Autocomplete variables
  List<Map<String, dynamic>> _customerSuggestions = [];
  bool _isSearching = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Fetch delivery areas once when screen initializes
    deliveryController.fetchDeliveryAreas();

    // Add listener for name field autocomplete
    orderEntryController.customerNameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    orderEntryController.customerNameController.removeListener(_onNameChanged);
    super.dispose();
  }

  void _onNameChanged() {
    final query = orderEntryController.customerNameController.text.trim();
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }
    _searchCustomers(query);
  }

  Future<void> _searchCustomers(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      if (token == null) {
        return;
      }

      final url = Uri.parse(
        "${Urls.baseUrl}/owner/customers/",
      ).replace(queryParameters: {'search': query});

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _customerSuggestions = jsonData.map<Map<String, dynamic>>((item) {
            return {
              'id': item['id'],
              'customer_name': item['customer_name'] ?? '',
              'phone': item['phone'] ?? '',
              'email': item['email'] ?? '',
              'address': item['address'] ?? '',
            };
          }).toList();
        });

        if (_customerSuggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      print('Error searching customers: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _layerLink.leaderSize?.width ?? 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _layerLink.leaderSize?.height ?? 60),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _customerSuggestions.length,
                itemBuilder: (context, index) {
                  final customer = _customerSuggestions[index];
                  return ListTile(
                    title: Text(customer['customer_name']),
                    subtitle: Text(customer['phone']),
                    onTap: () {
                      _selectCustomer(customer);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectCustomer(Map<String, dynamic> customer) {
    orderEntryController.customerNameController.removeListener(_onNameChanged);

    orderEntryController.customerNameController.text =
        customer['customer_name'];
    orderEntryController.emailController.text = customer['email'];
    orderEntryController.addressController.text = customer['address'];

    // Parse phone number to extract country code and remaining number
    String fullPhone = customer['phone'];
    _parseAndSetPhoneNumber(fullPhone);

    _removeOverlay();

    Future.delayed(const Duration(milliseconds: 100), () {
      orderEntryController.customerNameController.addListener(_onNameChanged);
    });

    setState(() {});
  }

  void _parseAndSetPhoneNumber(String fullPhone) {
    if (fullPhone.isEmpty) {
      orderEntryController.phoneController.text = '';
      return;
    }

    // List of common country codes (sorted by length, longest first)
    final countryCodes = [
      '+1',
      '+7',
      '+20',
      '+27',
      '+30',
      '+31',
      '+32',
      '+33',
      '+34',
      '+36',
      '+39',
      '+40',
      '+41',
      '+43',
      '+44',
      '+45',
      '+46',
      '+47',
      '+48',
      '+49',
      '+51',
      '+52',
      '+53',
      '+54',
      '+55',
      '+56',
      '+57',
      '+58',
      '+60',
      '+61',
      '+62',
      '+63',
      '+64',
      '+65',
      '+66',
      '+81',
      '+82',
      '+84',
      '+86',
      '+90',
      '+91',
      '+92',
      '+93',
      '+94',
      '+95',
      '+98',
      '+212',
      '+213',
      '+216',
      '+218',
      '+220',
      '+221',
      '+222',
      '+223',
      '+224',
      '+225',
      '+226',
      '+227',
      '+228',
      '+229',
      '+230',
      '+231',
      '+232',
      '+233',
      '+234',
      '+235',
      '+236',
      '+237',
      '+238',
      '+239',
      '+240',
      '+241',
      '+242',
      '+243',
      '+244',
      '+245',
      '+246',
      '+248',
      '+249',
      '+250',
      '+251',
      '+252',
      '+253',
      '+254',
      '+255',
      '+256',
      '+257',
      '+258',
      '+260',
      '+261',
      '+262',
      '+263',
      '+264',
      '+265',
      '+266',
      '+267',
      '+268',
      '+269',
      '+290',
      '+291',
      '+297',
      '+298',
      '+299',
      '+350',
      '+351',
      '+352',
      '+353',
      '+354',
      '+355',
      '+356',
      '+357',
      '+358',
      '+359',
      '+370',
      '+371',
      '+372',
      '+373',
      '+374',
      '+375',
      '+376',
      '+377',
      '+378',
      '+380',
      '+381',
      '+382',
      '+383',
      '+385',
      '+386',
      '+387',
      '+389',
      '+420',
      '+421',
      '+423',
      '+500',
      '+501',
      '+502',
      '+503',
      '+504',
      '+505',
      '+506',
      '+507',
      '+508',
      '+509',
      '+590',
      '+591',
      '+592',
      '+593',
      '+594',
      '+595',
      '+596',
      '+597',
      '+598',
      '+599',
      '+670',
      '+672',
      '+673',
      '+674',
      '+675',
      '+676',
      '+677',
      '+678',
      '+679',
      '+680',
      '+681',
      '+682',
      '+683',
      '+685',
      '+686',
      '+687',
      '+688',
      '+689',
      '+690',
      '+691',
      '+692',
      '+850',
      '+852',
      '+853',
      '+855',
      '+856',
      '+880',
      '+886',
      '+960',
      '+961',
      '+962',
      '+963',
      '+964',
      '+965',
      '+966',
      '+967',
      '+968',
      '+970',
      '+971',
      '+972',
      '+973',
      '+974',
      '+975',
      '+976',
      '+977',
      '+992',
      '+993',
      '+994',
      '+995',
      '+996',
      '+998',
    ];

    // Sort by length descending to match longest codes first
    countryCodes.sort((a, b) => b.length.compareTo(a.length));

    String detectedCode = '+49'; // Default
    String remainingNumber = fullPhone;

    // Check if phone starts with +
    if (fullPhone.startsWith('+')) {
      for (String code in countryCodes) {
        if (fullPhone.startsWith(code)) {
          detectedCode = code;
          remainingNumber = fullPhone.substring(code.length);
          break;
        }
      }
    }

    setState(() {
      orderEntryController.countryCode.value = detectedCode;
      orderEntryController.phoneController.text = remainingNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('order_entry'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust flex based on screen width for better mobile experience
          int leftFlex = constraints.maxWidth < 600 ? 1 : 2;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Customer details and menu
              Expanded(
                flex: leftFlex,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'customer_info'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: TextField(
                          controller:
                              orderEntryController.customerNameController,
                          decoration: InputDecoration(
                            labelText: 'customer_name'.tr,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: orderEntryController.addressController,
                        decoration: InputDecoration(
                          labelText: 'address'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Obx(
                            () => InkWell(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: true,
                                  onSelect: (Country country) {
                                    orderEntryController.countryCode.value =
                                        '+${country.phoneCode}';
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      orderEntryController.countryCode.value,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: orderEntryController.phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'phone_number'.tr,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => ElevatedButton.icon(
                              onPressed:
                                  orderEntryController.isLoadingCustomer.value
                                  ? null
                                  : () => orderEntryController
                                        .fetchCustomerByPhone(
                                          orderEntryController
                                              .countryCode
                                              .value,
                                        ),
                              icon: orderEntryController.isLoadingCustomer.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(Icons.search),
                              label: Text('fetch'.tr),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: orderEntryController.emailController,
                        decoration: InputDecoration(
                          labelText: 'email_optional'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),

                      // Order Type Selection
                      Obx(() {
                        // Check if mobile view
                        bool isMobile = MediaQuery.of(context).size.width < 600;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'order_type'.tr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Use Column for mobile, Row for desktop
                              isMobile
                                  ? Column(
                                      children: [
                                        RadioListTile<String>(
                                          title: Text('delivery'.tr),
                                          value: 'delivery',
                                          groupValue: orderEntryController
                                              .orderType
                                              .value,
                                          onChanged: (value) {
                                            orderEntryController
                                                    .orderType
                                                    .value =
                                                value!;
                                          },
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                        ),
                                        RadioListTile<String>(
                                          title: Text('pickup'.tr),
                                          value: 'pickup',
                                          groupValue: orderEntryController
                                              .orderType
                                              .value,
                                          onChanged: (value) {
                                            orderEntryController
                                                    .orderType
                                                    .value =
                                                value!;
                                          },
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: Text('delivery'.tr),
                                            value: 'delivery',
                                            groupValue: orderEntryController
                                                .orderType
                                                .value,
                                            onChanged: (value) {
                                              orderEntryController
                                                      .orderType
                                                      .value =
                                                  value!;
                                            },
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                          ),
                                        ),
                                        Expanded(
                                          child: RadioListTile<String>(
                                            title: Text('pickup'.tr),
                                            value: 'pickup',
                                            groupValue: orderEntryController
                                                .orderType
                                                .value,
                                            onChanged: (value) {
                                              orderEntryController
                                                      .orderType
                                                      .value =
                                                  value!;
                                            },
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 10),

                      // Delivery Area Dropdown (only for delivery orders)
                      Obx(() {
                        if (orderEntryController.orderType.value ==
                            'delivery') {
                          return Obx(() {
                            if (deliveryController.isLoading.value) {
                              return const LinearProgressIndicator();
                            }

                            if (deliveryController.deliveryAreas.isEmpty) {
                              return Text(
                                'no_delivery_areas_available'.tr,
                                style: const TextStyle(color: Colors.grey),
                              );
                            }

                            return DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'delivery_area_optional'.tr,
                                border: const OutlineInputBorder(),
                              ),
                              isExpanded: true,
                              value: orderEntryController
                                  .selectedDeliveryArea
                                  .value,
                              items: deliveryController.deliveryAreas.map((
                                area,
                              ) {
                                return DropdownMenuItem<int>(
                                  value: area['id'],
                                  child: Text(
                                    'PLZ ${area['postalcode']} - €${area['delivery_fee']} (${area['estimated_delivery_time']}m)',
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                orderEntryController
                                        .selectedDeliveryArea
                                        .value =
                                    value;
                              },
                            );
                          });
                        }
                        return const SizedBox.shrink();
                      }),
                      const SizedBox(height: 10),

                      TextField(
                        controller: orderEntryController.allergyController,
                        decoration: InputDecoration(
                          labelText: 'allergies_optional'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: orderEntryController.discountTextController,
                        decoration: InputDecoration(
                          labelText: 'discount_code_optional'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: orderEntryController.orderNotesController,
                        decoration: InputDecoration(
                          labelText: 'order_notes_optional'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'menu'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(() {
                          return Row(
                            children: menuController.categories.map((cat) {
                              final isSelected =
                                  orderEntryController.selectedCategory.value ==
                                  cat;
                              return FilterButton(
                                text: cat,
                                isSelected: isSelected,
                                onPressed: () {
                                  orderEntryController.selectedCategory.value =
                                      cat;
                                },
                              );
                            }).toList(),
                          );
                        }),
                      ),

                      const SizedBox(height: 10),

                      // Menu items
                      Obx(() {
                        if (menuController.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final items = menuController.filteredItems(
                          orderEntryController.selectedCategory.value,
                        );

                        return Column(
                          children: items.map((foodItem) {
                            return FoodMenuItem(
                              id: foodItem.id,
                              name: foodItem.name,
                              price: foodItem.price,
                              onAdd: (FoodItem item) {
                                orderEntryController.addFoodItem(item);
                              },
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Right side: Current order summary
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey[100],
                  child: Obx(() {
                    double subtotal = orderEntryController.orderItems.fold(
                      0.0,
                      (sum, item) => sum + (item.totalPrice * item.quantity),
                    );

                    // Get delivery fee if delivery type is selected and area is chosen
                    double deliveryFee = 0.0;
                    if (orderEntryController.orderType.value == 'delivery' &&
                        orderEntryController.selectedDeliveryArea.value !=
                            null) {
                      final selectedArea = deliveryController.deliveryAreas
                          .firstWhereOrNull(
                            (area) =>
                                area['id'] ==
                                orderEntryController.selectedDeliveryArea.value,
                          );
                      if (selectedArea != null) {
                        deliveryFee =
                            double.tryParse(
                              selectedArea['delivery_fee'].toString(),
                            ) ??
                            0.0;
                      }
                    }

                    double total = subtotal + deliveryFee;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fixed header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'current_order'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Scrollable order items
                        Expanded(
                          child: orderEntryController.orderItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'no_items_added'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  itemCount:
                                      orderEntryController.orderItems.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        orderEntryController.orderItems[index];
                                    return OrderItemSummary(
                                      item: item,
                                      onIncrement: () => orderEntryController
                                          .incrementQuantity(item),
                                      onDecrement: () => orderEntryController
                                          .decrementQuantity(item),
                                      onRemove: () =>
                                          orderEntryController.removeItem(item),
                                    );
                                  },
                                ),
                        ),

                        // Fixed footer with totals and button
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Subtotal
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${'subtotal'.tr}:",
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      "€${subtotal.toStringAsFixed(2)}",
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),

                              // Delivery Fee (only show if delivery is selected)
                              if (orderEntryController.orderType.value ==
                                  'delivery') ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${'delivery_fee'.tr}:",
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "€${deliveryFee.toStringAsFixed(2)}",
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 8),
                              const Divider(thickness: 1),
                              const SizedBox(height: 8),

                              // Total amount display
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${'total'.tr}:",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      "€${total.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: orderEntryController.createOrder,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('create_order'.tr),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Filter Button Widget
class FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white : AppColors.primaryColor,
          foregroundColor: isSelected ? AppColors.primaryColor : Colors.white,
          minimumSize: Size(60, 40),
          side: isSelected
              ? BorderSide(color: AppColors.primaryColor, width: 1.5)
              : null,
        ),
        child: Text(text),
      ),
    );
  }
}

class FoodMenuItemData {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String? image;

  FoodMenuItemData({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.image,
  });

  factory FoodMenuItemData.fromJson(Map<String, dynamic> json) {
    return FoodMenuItemData(
      id: json['id'],
      name: json['item_name'],
      category: json['category'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      description: json['descriptions'] ?? '',
      image: json['image'],
    );
  }
}

class FoodMenuItem extends StatefulWidget {
  final int id;
  final String name;
  final double price;
  final void Function(FoodItem) onAdd;

  const FoodMenuItem({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    //required this.imagePath,
    required this.onAdd,
  });

  @override
  _FoodMenuItemState createState() => _FoodMenuItemState();
}

class _FoodMenuItemState extends State<FoodMenuItem> {
  final extrasController = Get.find<ExtrasController>();
  Map<int, bool> selectedExtras = {};

  final TextEditingController _specialInstructionsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize all extras as unselected
    for (var extra in extrasController.extras) {
      selectedExtras[extra.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // If the screen width is less than 600, use Column for mobile responsiveness
    bool isMobile = screenWidth < 600;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'extras'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Obx(() {
                  if (extrasController.extras.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No extras available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return Column(
                    children: extrasController.extras.map((extra) {
                      return _buildText(
                        '${extra.title} (+€${extra.price})',
                        selectedExtras[extra.id] ?? false,
                        (value) {
                          setState(() {
                            selectedExtras[extra.id] = value!;
                          });
                        },
                      );
                    }).toList(),
                  );
                }),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'special_instructions'.tr,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'add_special_instructions'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Layout for mobile (Column)
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Image.asset(widget.imagePath, width: 60, height: 60),
        // ),
        Text(
          widget.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            '€${widget.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
          ),
          onPressed: () {
            // Collect selected extras
            List<String> extras = [];
            double extrasPrice = 0.0;

            selectedExtras.forEach((extraId, isSelected) {
              if (isSelected) {
                final extra = extrasController.extras.firstWhere(
                  (e) => e.id == extraId,
                );
                extras.add(extra.title);
                extrasPrice += double.tryParse(extra.price) ?? 0.0;
              }
            });

            widget.onAdd(
              FoodItem(
                id: widget.id,
                name: widget.name,
                price: widget.price,
                extras: extras.join(", "),
                extrasPrice: extrasPrice,
                specialInstructions: _specialInstructionsController.text,
              ),
            );
          },

          child: Text('add'.tr),
        ),
      ],
    );
  }

  // Layout for larger screens (Row)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        //Image.asset(widget.imagePath, width: 60, height: 60),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '€${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryColor,
          ),
          onPressed: () {
            // Collect selected extras
            List<String> extras = [];
            double extrasPrice = 0.0;

            selectedExtras.forEach((extraId, isSelected) {
              if (isSelected) {
                final extra = extrasController.extras.firstWhere(
                  (e) => e.id == extraId,
                );
                extras.add(extra.title);
                extrasPrice += double.tryParse(extra.price) ?? 0.0;
              }
            });

            widget.onAdd(
              FoodItem(
                id: widget.id, // pass id
                name: widget.name,
                price: widget.price,
                extras: extras.join(", "),
                extrasPrice: extrasPrice,
                specialInstructions: _specialInstructionsController.text,
              ),
            );
          },

          child: const Text('Add to Order'),
        ),
      ],
    );
  }

  // Checkboxes for extras
  Widget _buildText(
    String text,
    bool isChecked,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Checkbox(value: isChecked, onChanged: onChanged),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class OrderItemSummary extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const OrderItemSummary({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Check screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile =
        screenWidth < 600; // Consider mobile if width is less than 600px

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Show extras if any
                  if (item.extras.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Extras: ${item.extras}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  // Show special instructions if any
                  if (item.specialInstructions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${item.specialInstructions}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '€${(item.totalPrice * item.quantity).toStringAsFixed(2)}',
                  ),

                  Row(
                    children: [
                      Flexible(
                        child: IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: onDecrement,
                          iconSize: 20,
                        ),
                      ),
                      Flexible(child: Text('${item.quantity}')),
                      Flexible(
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: onIncrement,

                          iconSize: 20,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Show extras if any
                        if (item.extras.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Extras: ${item.extras}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        // Show special instructions if any
                        if (item.specialInstructions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Note: ${item.specialInstructions}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '€${(item.totalPrice * item.quantity).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: onDecrement,
                  ),
                  Text('${item.quantity}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onIncrement,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ],
              ),
      ),
    );
  }
}
