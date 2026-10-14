import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/laundry_order.dart';

// ======================================================
// ORDER TRACKING PAGE
// ======================================================

class OrderTrackingPage extends StatefulWidget {
  final LaundryOrder order;

  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // ====================================================
  // MOVE TO NEXT STATUS
  // ====================================================

  void moveToNextStatus() {
    final currentIndex = laundryStatuses.indexOf(widget.order.status);

    if (currentIndex < laundryStatuses.length - 1) {
      setState(() {
        widget.order.status = laundryStatuses[currentIndex + 1];
      });
    }
  }

  // ====================================================
  // BUILD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final currentIndex = laundryStatuses.indexOf(widget.order.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Order',
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${widget.order.service} • '
                    '${widget.order.quantity} Clothes',

                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
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
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.12),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.local_laundry_service,
                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            widget.order.status,

                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
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

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Column(
              children: List.generate(laundryStatuses.length, (index) {
                final bool isCompleted = index < currentIndex;

                final bool isCurrent = index == currentIndex;

                final bool isLast = index == laundryStatuses.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

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

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: isCompleted || isCurrent
                                  ? Colors.teal
                                  : Colors.grey.shade300,
                            ),

                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : isCurrent
                                  ? Icons.circle
                                  : Icons.circle_outlined,

                              size: isCurrent ? 12 : 18,

                              color: isCompleted || isCurrent
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),

                          if (!isLast)
                            Container(
                              width: 2,
                              height: 55,

                              color: index < currentIndex
                                  ? Colors.teal
                                  : Colors.grey.shade300,
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
                        padding: const EdgeInsets.only(top: 5, bottom: 25),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              laundryStatuses[index],

                              style: TextStyle(
                                fontSize: 16,

                                fontWeight: isCurrent || isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.w500,

                                color: isCurrent
                                    ? Colors.teal
                                    : isCompleted
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              isCompleted
                                  ? 'Completed'
                                  : isCurrent
                                  ? 'Current stage'
                                  : 'Waiting',

                              style: TextStyle(
                                fontSize: 13,

                                color: isCurrent
                                    ? Colors.teal
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 10),

            // =================================================
            // TEST STATUS BUTTON
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton.icon(
                onPressed: currentIndex < laundryStatuses.length - 1
                    ? moveToNextStatus
                    : null,

                icon: const Icon(Icons.arrow_forward),

                label: Text(
                  currentIndex < laundryStatuses.length - 1
                      ? 'Move to Next Status'
                      : 'Order Delivered',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            _DetailRow(
              icon: Icons.local_laundry_service,
              title: 'Service',
              value: widget.order.service,
            ),

            _DetailRow(
              icon: Icons.checkroom_outlined,
              title: 'Number of Clothes',
              value: '${widget.order.quantity}',
            ),

            _DetailRow(
              icon: Icons.calendar_month_outlined,
              title: 'Pickup Date',
              value:
                  '${widget.order.pickupDate.day.toString().padLeft(2, '0')}/'
                  '${widget.order.pickupDate.month.toString().padLeft(2, '0')}/'
                  '${widget.order.pickupDate.year}',
            ),

            _DetailRow(
              icon: Icons.location_on_outlined,
              title: 'Pickup Address',
              value: widget.order.address,
            ),

            if (widget.order.note.isNotEmpty)
              _DetailRow(
                icon: Icons.note_alt_outlined,
                title: 'Additional Note',
                value: widget.order.note,
              ),

            const SizedBox(height: 10),
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