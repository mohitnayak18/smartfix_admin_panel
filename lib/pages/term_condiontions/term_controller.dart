import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();

  /// ✅ SINGLE DOCUMENT
  /// 🔹 TERM CONDITIONS DOC
DocumentReference get termDocRef =>
    firestore.collection("settings").doc("term_conditions");

  /// ================= OFFERS =================



/// 🔹 UPDATE FIELD (privacy / terms)
Future<void> updateTerm(String field, String value) async {
  await termDocRef.update({
    field: value,
  });
}

/// 🔹 DELETE FIELD
Future<void> deleteTerm(String field) async {
  await termDocRef.update({
    field: FieldValue.delete(),
  });
}

/// 🔹 EDIT DIALOG
void showTermDialog({
  required String field,
  required String oldValue,
}) {
  controller.text = oldValue;

  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Edit ${field.toUpperCase()}"),
      content: TextField(
        controller: controller,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: "Enter $field",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Cancel",style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
          onPressed: () async {
            await updateTerm(field, controller.text.trim());
            controller.clear();
            Get.back();
          },
          child: const Text("Save",style: TextStyle(color: Colors.white)),
        )
      ],
    ),
  );
}
}
