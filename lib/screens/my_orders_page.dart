// ======================================================
// MY ORDERS PAGE
// ======================================================

import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/laundry_order.dart';
import 'order_details_page.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',

          style: TextStyle(fontWeight: FontWeight.bold),
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

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'Your laundry orders will appear here.',

              textAlign: TextAlign.center,

              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
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

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),

        side: BorderSide(color: Colors.grey.shade300),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

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
                    color: Colors.orange.withValues(alpha: 0.12),

                    borderRadius: BorderRadius.circular(20),
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
                const Icon(Icons.local_laundry_service, color: Colors.teal),

                const SizedBox(width: 10),

                Text(order.service, style: const TextStyle(fontSize: 16)),
              ],
            ),

            const SizedBox(height: 12),

            // =================================================
            // QUANTITY
            // =================================================
            Row(
              children: [
                const Icon(Icons.checkroom_outlined, color: Colors.teal),

                const SizedBox(width: 10),

                Text(
                  '${order.quantity} Clothes',

                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =================================================
            // PICKUP DATE
            // =================================================
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, color: Colors.teal),

                const SizedBox(width: 10),

                Text(
                  'Pickup: '
                  '${order.pickupDate.day.toString().padLeft(2, '0')}/'
                  '${order.pickupDate.month.toString().padLeft(2, '0')}/'
                  '${order.pickupDate.year}',

                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =================================================
            // ADDRESS
            // =================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Icon(Icons.location_on_outlined, color: Colors.teal),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    order.address,

                    style: const TextStyle(fontSize: 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Icon(Icons.note_alt_outlined, color: Colors.teal),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      order.note,

                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                const Text(
                  'Order Status',

                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}