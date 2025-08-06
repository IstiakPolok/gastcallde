import 'package:flutter/material.dart';

class CustomerDetailsScreen extends StatefulWidget {
  CustomerDetailsScreen({super.key});

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  // Customer Info
  final Map<String, String> customerInfo = {
    'name': 'Sophia Clark',
    'email': 'user2025@gmail.com',
    'phone': '+83467 5987',
    'address': '170, royal street park, GN 1200',
    'joined': '2021-05-15',
  };

  // Order History with expanded state for each order
  final List<Map<String, dynamic>> orderHistory = [
    {
      'orderId': 'ORD789',
      'date': '2023-08-15',
      'status': 'Delivered',
      'total': '\$150.00',
      'isExpanded': false,
    },
    {
      'orderId': 'ORD456',
      'date': '2023-07-20',
      'status': 'Delivered',
      'total': '\$200.00',
      'isExpanded': false,
    },
    {
      'orderId': 'ORD123',
      'date': '2023-06-05',
      'status': 'Cancelled',
      'total': '\$100.00',
      'isExpanded': false,
    },
    {
      'orderId': 'ORD001',
      'date': '2023-05-10',
      'status': 'Cancelled',
      'total': '\$50.00',
      'isExpanded': false,
    },
    {
      'orderId': 'ORD999',
      'date': '2023-04-25',
      'status': 'Delivered',
      'total': '\$120.00',
      'isExpanded': false,
    },
  ];

  // Function to toggle the expanded state for an order
  void _toggleExpansion(int index) {
    setState(() {
      orderHistory[index]['isExpanded'] = !orderHistory[index]['isExpanded'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Customer Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'View and manage customer information',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Customer Information Card
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            customerInfo['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${customerInfo['email']}'),
                          Text('Phone: ${customerInfo['phone']}'),
                          Text('Address: ${customerInfo['address']}'),
                          Text('Joined: ${customerInfo['joined']}'),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text('Total Orders:'),
                                  Text('Total Spent:'),
                                  Text('Last Order:'),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: const <Widget>[
                                  Text('12'),
                                  Text('\$2450.00'),
                                  Text('2024-01-15'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                customerInfo['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Email: ${customerInfo['email']}'),
                              Text('Phone: ${customerInfo['phone']}'),
                              Text('Address: ${customerInfo['address']}'),
                              Text('Joined: ${customerInfo['joined']}'),
                              const SizedBox(height: 20),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  Text('Total Orders:'),
                                  Text('Total Spent:'),
                                  Text('Last Order:'),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: const <Widget>[
                                  Text('12'),
                                  Text('\$2450.00'),
                                  Text('2024-01-15'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            const Text(
              'Order History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 15),

            // Order History List (using dynamic data)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Mobile: Show orders as cards with expanded details on click
                  return Column(
                    children: List.generate(orderHistory.length, (index) {
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order ID: ${orderHistory[index]['orderId']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      orderHistory[index]['isExpanded']
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                    ),
                                    onPressed: () {
                                      _toggleExpansion(index);
                                    },
                                  ),
                                ],
                              ),
                              Text('Date: ${orderHistory[index]['date']}'),
                              Text(
                                'Status: ${orderHistory[index]['status']}',
                                style: TextStyle(
                                  color:
                                      orderHistory[index]['status'] ==
                                          'Delivered'
                                      ? Colors.teal.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Total: ${orderHistory[index]['total']}'),
                              if (orderHistory[index]['isExpanded'])
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: <Widget>[
                                          MenuItemCard(
                                            imagePath:
                                                'https://cdn.sanity.io/images/czqk28jt/prod_plk_us/84bbcd43ce0d00ab85cc40e4c23f007e19501d21-2000x1333.png?q=70&auto=format', // Placeholder image
                                            itemName: 'Veg Hawaiian Pizza',
                                            price: '\$12.00',
                                            hasCheckbox: true,
                                          ),
                                          const SizedBox(height: 10),
                                          MenuItemCard(
                                            imagePath:
                                                'https://greatrangebison.com/wp-content/uploads/2023/07/caramelized-onion-burger-featured-image.jpg', // Placeholder image
                                            itemName: 'Veg-Korma Special Pizza',
                                            price: '\$35.00',
                                            hasCheckbox: false,
                                          ),
                                          const SizedBox(height: 10),
                                          MenuItemCard(
                                            imagePath:
                                                'https://static.toiimg.com/photo/54714340.cms', // Placeholder image
                                            itemName: 'Chicken Paneer Pizza',
                                            price: '\$25.00',
                                            hasCheckbox: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                } else {
                  // Large screens: Use table format
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      children: orderHistory.map((order) {
                        return _buildOrderRow(
                          order['orderId']!,
                          order['date']!,
                          order['status']!,
                          order['total']!,
                          order['status'] == 'Delivered'
                              ? Colors.teal.shade100
                              : Colors.red.shade100,
                          order['status'] == 'Delivered'
                              ? Colors.teal.shade700
                              : Colors.red.shade700,
                          orderHistory.indexOf(
                            order,
                          ), // Pass the index for toggling
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(
    String orderId,
    String date,
    String status,
    String total,
    Color statusBgColor,
    Color statusTextColor,
    int index, // Add index to track the specific order
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with order details
          Row(
            children: <Widget>[
              Expanded(flex: 2, child: Text(orderId)),
              Expanded(flex: 2, child: Text(date)),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusTextColor, fontSize: 12),
                    ),
                  ),
                ),
              ),
              Expanded(flex: 2, child: Text(total)),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                  color: Colors.grey[600],
                  onPressed: () {
                    // Toggle expansion to show/hide the details for this specific order
                    _toggleExpansion(index); // Toggling for the specific index
                  },
                ),
              ),
            ],
          ),

          // Conditionally display expanded details
          if (orderHistory[index]['isExpanded'])
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            MenuItemCard(
                              imagePath:
                                  'https://cdn.sanity.io/images/czqk28jt/prod_plk_us/84bbcd43ce0d00ab85cc40e4c23f007e19501d21-2000x1333.png?q=70&auto=format', // Placeholder image
                              itemName: 'Veg Hawaiian Pizza',
                              price: '\$12.00',
                              hasCheckbox: true,
                            ),

                            MenuItemCard(
                              imagePath:
                                  'https://greatrangebison.com/wp-content/uploads/2023/07/caramelized-onion-burger-featured-image.jpg', // Placeholder image
                              itemName: 'Veg-Korma Special Pizza',
                              price: '\$35.00',
                              hasCheckbox: false,
                            ),

                            MenuItemCard(
                              imagePath:
                                  'https://static.toiimg.com/photo/54714340.cms', // Placeholder image
                              itemName: 'Chicken Paneer Pizza',
                              price: '\$25.00',
                              hasCheckbox: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final String imagePath;
  final String itemName;
  final String price;
  final bool hasCheckbox;

  const MenuItemCard({
    super.key,
    required this.imagePath,
    required this.itemName,
    required this.price,
    this.hasCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen size for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding:
            screenWidth <
                600 // Check for small screens (mobile)
            ? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0)
            : const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Adjust size of avatar based on screen width
            CircleAvatar(
              radius: screenWidth < 600 ? 25 : 30, // Smaller radius for mobile
              backgroundImage: NetworkImage(imagePath),
              backgroundColor: Colors.grey[200], // Fallback background
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Row(
                children: [
                  // Adjust text size for smaller screens
                  Text(
                    itemName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth < 600
                          ? 14
                          : 16, // Smaller font on mobile
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Handle overflow on small screens
                  ),
                  if (hasCheckbox)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons
                            .check_box_outline_blank, // Or Icons.check_box for filled
                        size: screenWidth < 600
                            ? 16
                            : 18, // Smaller icon on mobile
                        color: Colors.teal,
                      ),
                    ),
                ],
              ),
            ),
            // Adjust price text size for smaller screens
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth < 600
                    ? 16
                    : 18, // Smaller price text on mobile
                color: const Color(0xFF1A237E), // A dark blue color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
