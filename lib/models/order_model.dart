import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final Timestamp timestamp;
  final String status;
  final String orderType;
  final String deliveryDetails;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    this.status = 'pending',
    this.orderType = 'pickup',
    this.deliveryDetails = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'items': items,
      'totalAmount': totalAmount,
      'timestamp': timestamp,
      'status': status,
      'orderType': orderType,
      'deliveryDetails': deliveryDetails,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      timestamp: map['timestamp'] ?? Timestamp.now(),
      status: map['status'] ?? 'pending',
      orderType: map['orderType'] ?? 'pickup',
      deliveryDetails: map['deliveryDetails'] ?? '',
    );
  }
}
