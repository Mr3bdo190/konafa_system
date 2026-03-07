import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F3F8),
          appBar: AppBar(
            title: const Text('إدارة الطلبات'), backgroundColor: Colors.orange, centerTitle: true,
            bottom: const TabBar(
              indicatorColor: Colors.white, indicatorWeight: 4, labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [Tab(text: 'جديدة 🆕'), Tab(text: 'تجهيز ⏳'), Tab(text: 'مكتملة ✅')],
            ),
          ),
          body: const TabBarView(
            children: [OrdersList(statusFilter: 'pending'), OrdersList(statusFilter: 'accepted'), OrdersList(statusFilter: 'completed_or_cancelled')],
          ),
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String statusFilter;
  const OrdersList({super.key, required this.statusFilter});

  void _updateStatus(DocumentReference doc, String status) {
    doc.update({'status': status});
  }

  // دالة توليد وطباعة الفاتورة PDF (باللغة الإنجليزية لضمان توافق الخطوط العالمية للطباعة)
  Future<void> _printReceipt(String orderId, Map<String, dynamic> data) async {
    final doc = pw.Document();
    List items = data['items'] ?? [];
    
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // مقاس بكرة الكاشير القياسية
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('KONAFA SYSTEM', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Order Receipt', style: const pw.TextStyle(fontSize: 16)),
                pw.Divider(),
                pw.Text('Order ID: #${orderId.substring(0, 8)}'),
                pw.Text('Customer: ${data['customerName']}'),
                pw.Text('Phone: ${data['customerPhone']}'),
                pw.Divider(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Item'), pw.Text('Qty')]),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                ...items.map((item) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text(item['name']), pw.Text('${item['quantity']}')]
                )).toList(),
                pw.Divider(),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text('TOTAL AMOUNT:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${data['totalAmount']} EGP', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                ]),
                pw.SizedBox(height: 20),
                pw.Text('Thank you for your order!', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Powered by Konafa System', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            )
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs.where((doc) {
          String s = doc['status'] ?? '';
          if (statusFilter == 'completed_or_cancelled') return s == 'completed' || s == 'cancelled';
          return s == statusFilter;
        }).toList();

        if (docs.isEmpty) return const Center(child: Text('لا يوجد طلبات في هذا القسم'));
        docs.sort((a, b) {
          var tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          var tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          return (tB ?? Timestamp.now()).compareTo(tA ?? Timestamp.now());
        });

        return ListView.builder(
          padding: const EdgeInsets.all(15), itemCount: docs.length,
          itemBuilder: (context, index) {
            var order = docs[index]; var data = order.data() as Map<String, dynamic>;
            List items = data['items'] ?? [];
            return Card(
              margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('طلب #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        // زر الطباعة الجديد
                        IconButton(icon: const Icon(Icons.print, color: Colors.blue), onPressed: () => _printReceipt(order.id, data)),
                      ],
                    ),
                    Text('${data['totalAmount']} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 18)),
                    const Divider(),
                    Text('العميل: ${data['customerName']} - ${data['customerPhone']}'),
                    Text('العنوان: ${data['deliveryDetails']}'),
                    const SizedBox(height: 10),
                    ...items.map((item) => Text('- ${item['name']} (x${item['quantity']})')),
                    const SizedBox(height: 15),
                    if (statusFilter == 'pending') Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: () => _updateStatus(order.reference, 'accepted'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('تجهيز', style: TextStyle(color: Colors.white)))),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton(onPressed: () => _updateStatus(order.reference, 'cancelled'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('إلغاء', style: TextStyle(color: Colors.white)))),
                      ],
                    ),
                    if (statusFilter == 'accepted') SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _updateStatus(order.reference, 'completed'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('تم التسليم', style: TextStyle(color: Colors.white)))),
                    if (statusFilter == 'completed_or_cancelled') Column(children: [
                      Center(child: Text(data['status'] == 'completed' ? '✅ اكتمل بنجاح' : '❌ تم الإلغاء', style: TextStyle(fontWeight: FontWeight.bold, color: data['status'] == 'completed' ? Colors.green : Colors.red))),
                      if(data['status'] == 'completed' && data['rating'] != null) Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('تقييم العميل: '), ...List.generate(5, (i) => Icon(i < (data['rating'] as int) ? Icons.star : Icons.star_border, color: Colors.orange, size: 16))])
                    ]),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
