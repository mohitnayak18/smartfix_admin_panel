import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BrandController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: "smartfixapp-18342.firebasestorage.app",
  );

  var brands = [].obs;
  var isLoading = false.obs;

  Uint8List? webImage;

  final nameController = TextEditingController();
  final ratingController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  Uint8List? imageBytes;
  String? imageName;

  @override
  void onInit() {
    fetchBrands();
    super.onInit();
  }

  // FETCH BRANDS
  fetchBrands() async {
    isLoading(true);

    var snapshot = await firestore.collection("mobile_brands").get();

    brands.value = snapshot.docs.map((e) => e.data()).toList();

    isLoading(false);
  }

  // PICK IMAGE
  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      imageBytes = await file.readAsBytes();
      imageName = file.name; // original name like Galaxy S25 Ultra.png

      // assign to webImage used by the UI and notify GetBuilder listeners
      webImage = imageBytes;
      update();
    }
  }

  // UPLOAD LOGO
  Future<String> uploadLogo(Uint8List imageBytes, String brandName) async {
    try {
      String cleanName = brandName;
      String fileName = "$cleanName";

      Reference ref = storage.ref().child("logo/$fileName");

      UploadTask uploadTask = ref.putData(imageBytes);

      TaskSnapshot snapshot = await uploadTask;

      String url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      Get.snackbar("Upload Error", e.toString());
      rethrow;
    }
  }

  // ADD BRAND
  // ADD BRAND
Future addBrand() async {
  try {
    if (webImage == null) {
      Get.snackbar("Error", "Select Logo");
      return;
    }

    if (nameController.text.isEmpty) {
      Get.snackbar("Error", "Please enter brand name");
      return;
    }

    if (ratingController.text.isEmpty) {
      Get.snackbar("Error", "Please enter rating");
      return;
    }

    String name = nameController.text.trim();
    
    int rating;
    try {
      rating = int.parse(ratingController.text.trim());
    } catch (e) {
      Get.snackbar("Error", "Please enter a valid number for rating");
      return;
    }

    // Show loading dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Upload logo first
    String logoUrl = await uploadLogo(webImage!, name);

    // Create Firestore document
    var doc = firestore.collection("mobile_brands").doc();

    await doc.set({
      "id": doc.id,
      "name": name,
      "logo": logoUrl,
      "rating": rating,
     
    });

    // Close loading dialog
    Get.back();

    // Clear controllers
    nameController.clear();
    ratingController.clear();
    webImage = null;
    update(); // Update UI to remove image preview

    // Close add brand dialog
    Get.back();

    // Show success message
    Get.snackbar(
      "Success",
      "Brand added successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    // Refresh brands list
    await fetchBrands();

  } catch (e) {
    // Close loading dialog if open
    if (Get.isDialogOpen!) {
      Get.back();
    }
    
    Get.snackbar(
      "Error",
      "Failed to add brand: $e",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    print("Error adding brand: $e");
  }
}

// UPLOAD LOGO - Improved version
// Future<String> uploadLogo(Uint8List imageBytes, String brandName) async {
//   try {
//     // Create a unique filename to avoid overwrites
//     String fileName = "${brandName}_${DateTime.now().millisecondsSinceEpoch}.png";
    
//     // Create reference with proper path
//     Reference ref = storage.ref().child("logos/$fileName");
    
//     // Set metadata
//     SettableMetadata metadata = SettableMetadata(
//       contentType: 'image/png',
//       customMetadata: {'uploadedBy': 'admin', 'brandName': brandName},
//     );

//     // Upload with metadata
//     UploadTask uploadTask = ref.putData(imageBytes, metadata);

//     // Wait for upload to complete
//     TaskSnapshot snapshot = await uploadTask;

//     // Check if upload was successful
//     if (snapshot.state == TaskState.success) {
//       // Get download URL
//       String url = await snapshot.ref.getDownloadURL();
//       print("Upload successful! URL: $url");
//       return url;
//     } else {
//       throw Exception("Upload failed with state: ${snapshot.state}");
//     }
//   } catch (e) {
//     print("Upload error details: $e");
//     Get.snackbar("Upload Error", e.toString());
//     rethrow;
//   }
// }

  // DELETE BRAND
  Future deleteBrand(String id, String logoUrl) async {
    await firestore.collection("mobile_brands").doc(id).delete();

    await storage.refFromURL(logoUrl).delete();

    fetchBrands();
  }

  // ADD BRAND DIALOG
  void openAddBrandDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Add Brand"),
        content: GetBuilder<BrandController>(
          builder: (controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Brand Name"),
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: "Rating"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: pickImage,
                  child: const Text("Select Logo"),
                ),
                const SizedBox(height: 10),
                if (webImage != null) Image.memory(webImage!, height: 60),
              ],
            );
          },
        ),
        actions: [
          ElevatedButton(onPressed: addBrand, child: const Text("Add")),
        ],
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    ratingController.dispose();
    super.onClose();
  }
}