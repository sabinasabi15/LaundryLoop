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