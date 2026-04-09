import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController controller = TextEditingController();

  /// ✅ SINGLE DOCUMENT
  DocumentReference get docRef =>
      firestore.collection("settings").doc("avlOffers");
  DocumentReference get highlightsDocRef =>
      firestore.collection("settings").doc("highlights");

  /// ================= OFFERS =================

  Future<void> addOffer(String value) async {
    if (value.isEmpty) return;

    await docRef.set({
      "avlOffers": FieldValue.arrayUnion([value]),
    }, SetOptions(merge: true));
  }

  Future<void> editOffer(String oldValue, String newValue) async {
    await docRef.update({
      "avlOffers": FieldValue.arrayRemove([oldValue]),
    });

    await addOffer(newValue);
  }

  Future<void> deleteOffer(String value) async {
    await docRef.update({
      "avlOffers": FieldValue.arrayRemove([value]),
    });
  }

  /// ================= HIGHLIGHTS =================

  Future<void> addHighlight(String value) async {
    if (value.isEmpty) return;

    await highlightsDocRef.set({
      "highlights": FieldValue.arrayUnion([value]),
    }, SetOptions(merge: true));
  }

  Future<void> editHighlight(String oldValue, String newValue) async {
    await highlightsDocRef.update({
      "highlights": FieldValue.arrayRemove([oldValue]),
    });

    await addHighlight(newValue);
  }

  Future<void> deleteHighlight(String value) async {
    await highlightsDocRef.update({
      "highlights": FieldValue.arrayRemove([value]),
    });
  }

  /// ================= COMMON DIALOG =================

  void showDialogBox({String? oldValue, bool isHighlight = false}) {
    controller.text = oldValue ?? "";

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          oldValue == null
              ? (isHighlight ? "Add Highlight" : "Add Offer")
              : (isHighlight ? "Edit Highlight" : "Edit Offer"),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isHighlight ? "Enter highlight" : "Enter offer",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clear();
              Get.back();
            },
            child: const Text("Cancel",style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            onPressed: () async {
              String value = controller.text.trim();

              if (value.isEmpty) return;

              if (oldValue == null) {
                /// ADD
                if (isHighlight) {
                  await addHighlight(value);
                } else {
                  await addOffer(value);
                }
              } else {
                /// EDIT
                if (isHighlight) {
                  await editHighlight(oldValue, value);
                } else {
                  await editOffer(oldValue, value);
                }
              }

              controller.clear();
              Get.back();
            },
            child: const Text("Save",style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}
