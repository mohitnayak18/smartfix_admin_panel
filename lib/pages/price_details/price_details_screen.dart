import 'package:admin_panel/pages/price_details/price_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PriceDetailsPage extends StatelessWidget {
  final PriceDetailsController prcCtrl = Get.put(PriceDetailsController());

  PriceDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Price Details"),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: prcCtrl.priceDocRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var data =
              snapshot.data!.data() as Map<String, dynamic>?;

          int discount = data?["discount_fee"] ?? 0;
          int gst = data?["gst_percentage"] ?? 0;
          int platform = data?["platform_fee"] ?? 0;
          int shipping = data?["shipping_fee"] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              buildTile("Discount Fee", "discount_fee", discount),
              buildTile("GST %", "gst_percentage", gst),
              buildTile("Platform Fee", "platform_fee", platform),
              buildTile("Shipping Fee", "shipping_fee", shipping),
            ],
          );
        },
      ),
    );
  }

  Widget buildTile(String title, String field, int value) {
    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.toString()),

        /// EDIT
        leading: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () => prcCtrl.showPriceDialog(
            field: field,
            oldValue: value,
          ),
        ),

        /// DELETE (optional)
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => prcCtrl.deletePrice(field),
        ),
      ),
    );
  }
}