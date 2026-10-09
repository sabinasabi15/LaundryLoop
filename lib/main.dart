import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const LaundryLoopApp());
}

// ======================================================
// ORDER MODEL
// ======================================================

class LaundryOrder {
  final String orderId;
  final String service;
  final int quantity;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime pickupDate;
  final String note;
  String status;

  LaundryOrder({
    required this.orderId,
    required this.service,
    required this.quantity,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pickupDate,
    required this.note,
    required this.status,
  });
}

// Temporary order storage.
// Later this will be replaced with database storage.
final List<LaundryOrder> orders = [];

const List<String> laundryStatuses = [
  'Pending',
  'Pickup Scheduled',
  'Laundry Received',
  'Washing',
  'Drying',
  'Ironing',
  'Ready for Delivery',
  'Delivered',
];
// Temporary logged-in user data.
// Later this will come from MySQL + backend authentication.
String registeredName = '';
String registeredEmail = '';
String registeredPhone = '';
String registeredAddress = '';
String registeredPassword = '';

bool isLoggedIn = false;


// ======================================================
// APP
// ======================================================

class LaundryLoopApp extends StatelessWidget {
  const LaundryLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LaundryLoop',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),

      home: const WelcomePage(),
    );
  }
}

// ======================================================
// HOME PAGE
// ======================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LaundryLoop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Welcome to LaundryLoop 👋',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Your simple laundry management companion.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.local_laundry_service,
                    size: 45,
                    color: Colors.teal,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'Laundry made easier',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Schedule, track and manage your laundry services from one place.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- NEW ORDER / MY ORDERS ----------------

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_circle_outline,
                    title: 'New Order',

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NewOrderPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.receipt_long,
                    title: 'My Orders',

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MyOrdersPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ---------------- TRACK / PROFILE ----------------

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'Track Order',

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrdersPage(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person,
                    title: 'Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// QUICK ACTION CARD
// ======================================================

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 10,
          ),

          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.teal,
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// NEW ORDER PAGE
// ======================================================

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  String selectedService = 'Wash & Fold';

  int quantity = 1;

  DateTime? selectedPickupDate;

  LatLng? selectedPickupLocation;

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController noteController =
      TextEditingController();

  

  // ====================================================
  // PICKUP DATE
  // ====================================================

  Future<void> selectPickupDate() async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedPickupDate ?? today,
      firstDate: today,
      lastDate: today.add(
        const Duration(days: 30),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedPickupDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    noteController.dispose();

    super.dispose();
  }

    // ====================================================
  // SELECT PICKUP LOCATION
  // ====================================================

  Future<void> selectPickupLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickupLocationPage(
          initialLocation: selectedPickupLocation,
        ),
      ),
    );

    if (result != null) {
      final LatLng location = result['location'];
      final String address = result['address'];

      setState(() {
        selectedPickupLocation = location;
        addressController.text = address;
      });
    }
  }

  // ====================================================
  // CREATE ORDER
  // ====================================================

  void createOrder() {
    if (selectedPickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a pickup date.',
          ),
        ),
      );

      return;
    }
    if (selectedPickupLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select your pickup location on the map.',
          ),
        ),
      );

      return;
    }

    // Generate a simple order ID.
    final String orderId =
        'LL${(orders.length + 1).toString().padLeft(3, '0')}';

    // Create new order.
    final LaundryOrder newOrder = LaundryOrder(
      orderId: orderId,
      service: selectedService,
      quantity: quantity,
      address: addressController.text.trim(),
      latitude: selectedPickupLocation!.latitude,
      longitude: selectedPickupLocation!.longitude,
      pickupDate: selectedPickupDate!,
      note: noteController.text.trim(),
      status: 'Pending',
    );

    // Save order temporarily.
    orders.add(newOrder);

    // Show success message.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Order created successfully!',
        ),
      ),
    );

    // Return to Home Page after a short delay.
    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Laundry Order',

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Create a New Order',

              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose your laundry service and provide the necessary details.',

              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 28),

            // =================================================
            // SERVICE
            // =================================================

            const Text(
              '1. Select Service',

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedService,

              decoration: InputDecoration(
                labelText: 'Laundry Service',

                prefixIcon: const Icon(
                  Icons.local_laundry_service,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              items: const [
                DropdownMenuItem(
                  value: 'Wash & Fold',
                  child: Text('Wash & Fold'),
                ),

                DropdownMenuItem(
                  value: 'Dry Cleaning',
                  child: Text('Dry Cleaning'),
                ),

                DropdownMenuItem(
                  value: 'Ironing',
                  child: Text('Ironing'),
                ),

                DropdownMenuItem(
                  value: 'Wash & Iron',
                  child: Text('Wash & Iron'),
                ),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedService = value;
                  });
                }
              },
            ),

            const SizedBox(height: 28),

            // =================================================
            // QUANTITY
            // =================================================

            const Text(
              '2. Number of Clothes',

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.checkroom,
                        color: Colors.teal,
                      ),

                      SizedBox(width: 10),

                      Text(
                        'Clothes',

                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },

                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                      ),

                      Text(
                        '$quantity',

                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },

                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            // =================================================
            // PICKUP DATE
            // =================================================

            const Text(
              '3. Pickup Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            InkWell(
              onTap: selectPickupDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.teal,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        selectedPickupDate == null
                            ? 'Select pickup date'
                            : '${selectedPickupDate!.day.toString().padLeft(2, '0')}/'
                              '${selectedPickupDate!.month.toString().padLeft(2, '0')}/'
                              '${selectedPickupDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedPickupDate == null
                              ? Colors.grey[600]
                              : Colors.black87,
                          fontWeight: selectedPickupDate == null
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.calendar_today,
                      color: Colors.teal,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            // =================================================
            // ADDRESS
            // =================================================

            const Text(
              '4. Pickup Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.teal,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          selectedPickupLocation == null
                              ? 'No pickup location selected'
                              : 'Pickup location selected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedPickupLocation == null
                                ? Colors.grey[600]
                                : Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),



                  if (selectedPickupLocation != null) ...[
                    const SizedBox(height: 10),

                    Text(
                      addressController.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Latitude: '
                      '${selectedPickupLocation!.latitude.toStringAsFixed(5)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),

                    Text(
                      'Longitude: '
                      '${selectedPickupLocation!.longitude.toStringAsFixed(5)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton.icon(
                      onPressed: selectPickupLocation,

                      icon: const Icon(
                        Icons.map_outlined,
                      ),

                      label: Text(
                        selectedPickupLocation == null
                            ? 'Select Location on Map'
                            : 'Change Pickup Location',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =================================================
            // NOTE
            // =================================================

            const Text(
              '5. Additional Note',

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: noteController,

              maxLines: 3,

              decoration: InputDecoration(
                hintText:
                    'Any special instruction? (Optional)',

                prefixIcon: const Icon(
                  Icons.note_alt_outlined,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // =================================================
            // PLACE ORDER
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: createOrder,

                icon: const Icon(
                  Icons.check_circle_outline,
                ),

                label: const Text(
                  'Place Order',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
}

// ======================================================
// MY ORDERS PAGE
// ======================================================

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: orders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: orders.length,

              itemBuilder: (context, index) {
                final LaundryOrder order = orders[index];

                return _OrderCard(order: order);
              },
            ),
    );
  }

  // ====================================================
  // EMPTY ORDERS
  // ====================================================

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.receipt_long_outlined,

              size: 80,

              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Orders Yet',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Your laundry orders will appear here.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// ORDER CARD
// ======================================================

class _OrderCard extends StatelessWidget {
  final LaundryOrder order;

  const _OrderCard({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),

        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // ORDER ID + STATUS
            // =================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Order #${order.orderId}',

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(
                      alpha: 0.12,
                    ),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    order.status,

                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =================================================
            // SERVICE
            // =================================================

            Row(
              children: [
                const Icon(
                  Icons.local_laundry_service,
                  color: Colors.teal,
                ),

                const SizedBox(width: 10),

                Text(
                  order.service,

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =================================================
            // QUANTITY
            // =================================================

            Row(
              children: [
                const Icon(
                  Icons.checkroom_outlined,
                  color: Colors.teal,
                ),

                const SizedBox(width: 10),

                Text(
                  '${order.quantity} Clothes',

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =================================================
            // PICKUP DATE
            // =================================================

            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.teal,
                ),

                const SizedBox(width: 10),

                Text(
                  'Pickup: '
                  '${order.pickupDate.day.toString().padLeft(2, '0')}/'
                  '${order.pickupDate.month.toString().padLeft(2, '0')}/'
                  '${order.pickupDate.year}',

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =================================================
            // ADDRESS
            // =================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.teal,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    order.address,

                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            // =================================================
            // NOTE
            // =================================================

            if (order.note.isNotEmpty) ...[
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Icon(
                    Icons.note_alt_outlined,
                    color: Colors.teal,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      order.note,

                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Order Status',

                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(
                          order: order,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'View Details',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// ======================================================
// ORDER DETAILS PAGE
// ======================================================

class OrderDetailsPage extends StatelessWidget {
  final LaundryOrder order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // ORDER HEADER
            // =================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.teal.withValues(
                  alpha: 0.1,
                ),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 45,
                    color: Colors.teal,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Order #${order.orderId}',

                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(
                        alpha: 0.15,
                      ),

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Text(
                      order.status,

                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =================================================
            // ORDER INFORMATION
            // =================================================

            const Text(
              'Order Information',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _DetailRow(
              icon: Icons.local_laundry_service,
              title: 'Service',
              value: order.service,
            ),

            _DetailRow(
              icon: Icons.checkroom_outlined,
              title: 'Number of Clothes',
              value: '${order.quantity}',
            ),

            _DetailRow(
              icon: Icons.calendar_month_outlined,
              title: 'Pickup Date',
              value:
                  '${order.pickupDate.day.toString().padLeft(2, '0')}/'
                  '${order.pickupDate.month.toString().padLeft(2, '0')}/'
                  '${order.pickupDate.year}',
            ),

            _DetailRow(
              icon: Icons.location_on_outlined,
              title: 'Pickup Address',
              value: order.address,
            ),

            if (order.note.isNotEmpty)
              _DetailRow(
                icon: Icons.note_alt_outlined,
                title: 'Additional Note',
                value: order.note,
              ),

            const SizedBox(height: 25),

            // =================================================
            // CURRENT STATUS
            // =================================================

            const Text(
              'Current Status',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),

                side: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,

                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(
                          alpha: 0.12,
                        ),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.hourglass_top,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            order.status,

                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Your order is waiting to be processed.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // TRACK ORDER BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderTrackingPage(
                        order: order,
                      ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.local_shipping_outlined,
                ),

                label: const Text(
                  'Track Order',

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// DETAIL ROW
// ======================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: Colors.teal,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// ======================================================
// ORDER TRACKING PAGE
// ======================================================

class OrderTrackingPage extends StatefulWidget {
  final LaundryOrder order;

  const OrderTrackingPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingPage> createState() =>
      _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {

  // ====================================================
  // MOVE TO NEXT STATUS
  // ====================================================

  void moveToNextStatus() {
    final currentIndex =
        laundryStatuses.indexOf(widget.order.status);

    if (currentIndex < laundryStatuses.length - 1) {
      setState(() {
        widget.order.status =
            laundryStatuses[currentIndex + 1];
      });
    }
  }

  // ====================================================
  // BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {

    final currentIndex =
        laundryStatuses.indexOf(widget.order.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Order',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =================================================
            // ORDER HEADER
            // =================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.teal.withValues(
                  alpha: 0.1,
                ),

                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 45,
                    color: Colors.teal,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Order #${widget.order.orderId}',

                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${widget.order.service} • '
                    '${widget.order.quantity} Clothes',

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // CURRENT STATUS
            // =================================================

            const Text(
              'Current Status',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),

                side: BorderSide(
                  color:
                      Colors.grey.shade300,
                ),
              ),

              child: Padding(
                padding:
                    const EdgeInsets.all(18),

                child: Row(
                  children: [

                    Container(
                      width: 48,
                      height: 48,

                      decoration:
                          BoxDecoration(
                        color: Colors.teal
                            .withValues(
                          alpha: 0.12,
                        ),

                        shape:
                            BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.local_laundry_service,
                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            widget.order.status,

                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'This is the current stage '
                            'of your laundry order.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // TRACKING TIMELINE
            // =================================================

            const Text(
              'Order Tracking',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Column(
              children: List.generate(
                laundryStatuses.length,
                (index) {

                  final bool isCompleted =
                      index < currentIndex;

                  final bool isCurrent =
                      index == currentIndex;

                  final bool isLast =
                      index ==
                          laundryStatuses.length - 1;

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // =========================================
                      // TIMELINE
                      // =========================================

                      SizedBox(
                        width: 40,

                        child: Column(
                          children: [

                            Container(
                              width: 32,
                              height: 32,

                              decoration:
                                  BoxDecoration(
                                shape:
                                    BoxShape.circle,

                                color:
                                    isCompleted ||
                                            isCurrent
                                        ? Colors.teal
                                        : Colors
                                            .grey
                                            .shade300,
                              ),

                              child: Icon(
                                isCompleted
                                    ? Icons.check
                                    : isCurrent
                                        ? Icons.circle
                                        : Icons
                                            .circle_outlined,

                                size:
                                    isCurrent
                                        ? 12
                                        : 18,

                                color:
                                    isCompleted ||
                                            isCurrent
                                        ? Colors.white
                                        : Colors
                                            .grey
                                            .shade600,
                              ),
                            ),

                            if (!isLast)
                              Container(
                                width: 2,
                                height: 55,

                                color:
                                    index <
                                            currentIndex
                                        ? Colors.teal
                                        : Colors
                                            .grey
                                            .shade300,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 15),

                      // =========================================
                      // STATUS TEXT
                      // =========================================

                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 5,
                            bottom: 25,
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(
                                laundryStatuses[index],

                                style: TextStyle(
                                  fontSize: 16,

                                  fontWeight:
                                      isCurrent ||
                                              isCompleted
                                          ? FontWeight
                                              .bold
                                          : FontWeight
                                              .w500,

                                  color:
                                      isCurrent
                                          ? Colors.teal
                                          : isCompleted
                                              ? Colors
                                                  .black87
                                              : Colors
                                                  .grey
                                                  .shade600,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                isCompleted
                                    ? 'Completed'
                                    : isCurrent
                                        ? 'Current stage'
                                        : 'Waiting',

                                style: TextStyle(
                                  fontSize: 13,

                                  color:
                                      isCurrent
                                          ? Colors.teal
                                          : Colors
                                              .grey
                                              .shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // =================================================
            // TEST STATUS BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed:
                    currentIndex <
                            laundryStatuses.length - 1
                        ? moveToNextStatus
                        : null,

                icon: const Icon(
                  Icons.arrow_forward,
                ),

                label: Text(
                  currentIndex <
                          laundryStatuses.length - 1
                      ? 'Move to Next Status'
                      : 'Order Delivered',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // ORDER INFORMATION
            // =================================================

            const Text(
              'Order Information',

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _DetailRow(
              icon:
                  Icons.local_laundry_service,
              title: 'Service',
              value:
                  widget.order.service,
            ),

            _DetailRow(
              icon:
                  Icons.checkroom_outlined,
              title: 'Number of Clothes',
              value:
                  '${widget.order.quantity}',
            ),

            _DetailRow(
              icon:
                  Icons.calendar_month_outlined,
              title: 'Pickup Date',
              value:
                  '${widget.order.pickupDate.day.toString().padLeft(2, '0')}/'
                  '${widget.order.pickupDate.month.toString().padLeft(2, '0')}/'
                  '${widget.order.pickupDate.year}',
            ),

            _DetailRow(
              icon:
                  Icons.location_on_outlined,
              title: 'Pickup Address',
              value:
                  widget.order.address,
            ),

            if (widget.order.note.isNotEmpty)
              _DetailRow(
                icon:
                    Icons.note_alt_outlined,
                title: 'Additional Note',
                value:
                    widget.order.note,
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

//ProfilePage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = registeredName;
  String email = registeredEmail;
  String phone = registeredPhone;
    String address = registeredAddress;

  void editProfile() {
final nameController =
    TextEditingController(text: userName);

  final emailController =
      TextEditingController(text: email);

  final phoneController =
      TextEditingController(text: phone);

  final addressController =
      TextEditingController(text: address);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userName = nameController.text.trim();
                  email = emailController.text.trim();
                  phone = phoneController.text.trim();
                  address = addressController.text.trim();

                  // Update temporary account data as well.
                  registeredName = userName;
                  registeredEmail = email;
                  registeredPhone = phone;
                  registeredAddress = address;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void changePassword() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both password fields'),
                    ),
                  );
                  return;
                }

                if (passwordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout feature will be connected later'),
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile picture
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 65,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 30),

            // Personal Information
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            _ProfileInfoCard(
              icon: Icons.person_outline,
              title: 'Name',
              value: userName,
            ),

            _ProfileInfoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
            ),

            _ProfileInfoCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: phone,
            ),

            _ProfileInfoCard(
              icon: Icons.location_on_outlined,
              title: 'Address',
              value: address,
            ),

            const SizedBox(height: 25),

            // Account Settings
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: Colors.teal,
                    ),
                    title: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Update your personal information',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: editProfile,
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.lock_outline,
                      color: Colors.teal,
                    ),
                    title: const Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Update your account password',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: changePassword,
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out from your account',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: logout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'LaundryLoop',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Your laundry, our care.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

//_ProfileInfoCard

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.teal,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
// ======================================================
// WELCOME PAGE
// ======================================================

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Laundry Icon
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_laundry_service,
                  size: 75,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 30),

              // App Name
              const Text(
                'LaundryLoop',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              Text(
                'Your laundry, our care.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 15),

              // Description
              Text(
                'Schedule, manage and track your laundry '
                'services easily from one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey[600],
                ),
              ),

              const Spacer(),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Login Text
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
// ======================================================
// LOGIN PAGE
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email.',
          ),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your password.',
          ),
        ),
      );
      return;
    }

    // Check whether an account has been created.
    if (registeredEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No account found. Please Sign Up first.',
          ),
        ),
      );
      return;
    }

    // Check email and password.
    if (email != registeredEmail ||
        password != registeredPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Incorrect email or password.',
          ),
        ),
      );
      return;
    }

    // Login successful.
    isLoggedIn = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Login successful!',
        ),
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_laundry_service,
                  size: 50,
                  color: Colors.teal,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Login to continue using LaundryLoop.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password reset will be added later.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: login,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
// ======================================================
// SIGN UP PAGE
// ======================================================

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  void createAccount() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword =
        confirmPasswordController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter your name.');
      return;
    }

    if (email.isEmpty) {
      showMessage('Please enter your email.');
      return;
    }

    if (phone.isEmpty) {
      showMessage('Please enter your phone number.');
      return;
    }

    if (address.isEmpty) {
      showMessage('Please enter your address.');
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter a password.');
      return;
    }

    if (password.length < 6) {
      showMessage(
        'Password must be at least 6 characters.',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      showMessage('Please confirm your password.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    // Temporarily save the account information.
    registeredName = name;
    registeredEmail = email;
    registeredPhone = phone;
    registeredAddress = address;
    registeredPassword = password;

    isLoggedIn = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account created successfully!',
        ),
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 800),
      () {
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  size: 50,
                  color: Colors.teal,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Center(
              child: Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Join LaundryLoop and manage your laundry easily.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              'Full Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: const Icon(
                  Icons.person_outline,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: addressController,
              maxLines: 2,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Enter your address',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: 'Create a password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: createAccount,
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
// ======================================================
// PICKUP LOCATION PAGE
// ======================================================

class PickupLocationPage extends StatefulWidget {
  final LatLng? initialLocation;

  const PickupLocationPage({
    super.key,
    this.initialLocation,
  });

  @override
  State<PickupLocationPage> createState() =>
      _PickupLocationPageState();
}

class _PickupLocationPageState
    extends State<PickupLocationPage> {
  late LatLng selectedLocation;

  GoogleMapController? _mapController;

  String selectedAddress =
      'Move the map to select a location';

  bool isLoadingAddress = false;

  @override
  void initState() {
    super.initState();

    selectedLocation =
        widget.initialLocation ??
        const LatLng(
          22.3569,
          91.7832,
        );
  }

  Future<void> getAddressFromLocation(
    LatLng location,
  ) async {
    setState(() {
      isLoadingAddress = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2'
        '&lat=${location.latitude}'
        '&lon=${location.longitude}'
        '&zoom=18'
        '&addressdetails=1'
        '&accept-language=en',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'LaundryLoop/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          selectedAddress =
              data['display_name'] ??
              'Address not found';
        });
      } else {
        setState(() {
          selectedAddress =
              'Address could not be found';
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress =
            'Unable to get address';
      });
    }

    setState(() {
      isLoadingAddress = false;
    });
  }

  Future<void> confirmLocation() async {
    await getAddressFromLocation(
      selectedLocation,
    );

    if (mounted) {
      Navigator.pop(
        context,
        {
          'location': selectedLocation,
          'address': selectedAddress,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Pickup Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraMove: (position) {
              selectedLocation = position.target;
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          const Center(
            child: Icon(
              Icons.location_pin,
              size: 55,
              color: Colors.red,
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 90,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.15,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Move the map to select your pickup location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${selectedLocation.latitude.toStringAsFixed(5)}, '
                    '${selectedLocation.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),

                  if (selectedAddress !=
                      'Move the map to select a location') ...[
                    const SizedBox(height: 8),

                    Text(
                      selectedAddress,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoadingAddress
                    ? null
                    : confirmLocation,
                icon: isLoadingAddress
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  isLoadingAddress
                      ? 'Getting Address...'
                      : 'Confirm Location',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}