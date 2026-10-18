
import '../models/laundry_order.dart';

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

String registeredName = '';
String registeredEmail = '';
String registeredPhone = '';
String registeredAddress = '';
String registeredPassword = '';

bool isLoggedIn = false;
