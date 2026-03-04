import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final String customerName;
  final List<dynamic> items;
  final double totalAmount;
  final String status;
  final Timestamp timestamp;
  final String orderType; // 'delivery' أو 'pickup'
  final String deliveryDetails; // العنوان أو اسم الفرع

  OrderModel({
    required this.orderId, required this.customerId, required this.customerName,
    required this.items, required this.totalAmount, this.status = 'pending',
    required this.timestamp, required this.orderType, required this.deliveryDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId, 'customerId': customerId, 'customerName': customerName,
      'items': items, 'totalAmount': totalAmount, 'status': status,
      'timestamp': timestamp, 'orderType': orderType, 'deliveryDetails': deliveryDetails,
    };
  }
}
