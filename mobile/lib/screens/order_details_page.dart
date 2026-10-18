import 'package:flutter/material.dart';

import '../models/laundry_order.dart';
import 'order_tracking_page.dart';

// ======================================================
// ORDER DETAILS PAGE
// ======================================================

class OrderDetailsPage extends StatelessWidget {
  final LaundryOrder order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                color: Colors.teal.withValues(alpha: 0.1),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Icon(Icons.receipt_long, size: 45, color: Colors.teal),

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
                      color: Colors.orange.withValues(alpha: 0.15),

                      borderRadius: BorderRadius.circular(20),
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

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Card(
              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),

                side: BorderSide(color: Colors.grey.shade300),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,

                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),

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
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            order.status,

                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text('Your order is waiting to be processed.'),
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
                      builder: (context) => OrderTrackingPage(order: order),
                    ),
                  );
                },

                icon: const Icon(Icons.local_shipping_outlined),

                label: const Text(
                  'Track Order',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        border: Border.all(color: Colors.grey.shade300),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: Colors.teal),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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