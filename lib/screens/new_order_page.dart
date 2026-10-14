import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/laundry_order.dart';
import '../data/app_data.dart';
import 'pickup_location_page.dart';


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

  final TextEditingController addressController = TextEditingController();

  final TextEditingController noteController = TextEditingController();

  // ====================================================
  // PICKUP DATE
  // ====================================================

  Future<void> selectPickupDate() async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedPickupDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
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
        builder: (context) =>
            PickupLocationPage(initialLocation: selectedPickupLocation),
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
        const SnackBar(content: Text('Please select a pickup date.')),
      );

      return;
    }
    if (selectedPickupLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your pickup location on the map.'),
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
      const SnackBar(content: Text('Order created successfully!')),
    );

    // Return to Home Page after a short delay.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Laundry Order',

          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              'Create a New Order',

              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose your laundry service and provide the necessary details.',

              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),

            const SizedBox(height: 28),

            // =================================================
            // SERVICE
            // =================================================
            const Text(
              '1. Select Service',

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedService,

              decoration: InputDecoration(
                labelText: 'Laundry Service',

                prefixIcon: const Icon(Icons.local_laundry_service),

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

                DropdownMenuItem(value: 'Ironing', child: Text('Ironing')),

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

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),

              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Row(
                    children: [
                      Icon(Icons.checkroom, color: Colors.teal),

                      SizedBox(width: 10),

                      Text('Clothes', style: TextStyle(fontSize: 16)),
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

                        icon: const Icon(Icons.remove_circle_outline),
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

                        icon: const Icon(Icons.add_circle_outline),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  border: Border.all(color: Colors.grey.shade300),
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

                    const Icon(Icons.calendar_today, color: Colors.teal),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
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
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),

                    Text(
                      'Longitude: '
                      '${selectedPickupLocation!.longitude.toStringAsFixed(5)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton.icon(
                      onPressed: selectPickupLocation,

                      icon: const Icon(Icons.map_outlined),

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

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: noteController,

              maxLines: 3,

              decoration: InputDecoration(
                hintText: 'Any special instruction? (Optional)',

                prefixIcon: const Icon(Icons.note_alt_outlined),

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

                icon: const Icon(Icons.check_circle_outline),

                label: const Text(
                  'Place Order',

                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
