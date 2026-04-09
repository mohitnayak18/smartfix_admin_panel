import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PriceDetailsController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();

  /// ✅ SINGLE DOCUMENT
  /// 🔹 TERM CONDITIONS DOC
  DocumentReference get termDocRef =>
      firestore.collection("settings").doc("term_conditions");

  /// 🔹 PRICE DETAILS DOC
  DocumentReference get priceDocRef =>
      firestore.collection("settings").doc("price_details");

  /// 🔹 UPDATE FIELD
  Future<void> updatePrice(String field, String value) async {
    await priceDocRef.update({field: int.tryParse(value) ?? 0});
  }

  /// 🔹 DELETE FIELD
  Future<void> deletePrice(String field) async {
    await priceDocRef.update({field: FieldValue.delete()});
  }

  /// 🔹 EDIT DIALOG
  void showPriceDialog({required String field, required int oldValue}) {
    controller.text = oldValue.toString();

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter $field"),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () async {
              await updatePrice(field, controller.text.trim());
              controller.clear();
              Get.back();
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
