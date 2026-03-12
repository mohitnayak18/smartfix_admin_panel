import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BannerPage extends StatefulWidget {
  const BannerPage({super.key});

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  final picker = ImagePicker();
  final firestore = FirebaseFirestore.instance;

  final storage = FirebaseStorage.instanceFor(
    bucket: "smartfixapp-18342.firebasestorage.app",
  );

  XFile? imageFile;
  String? imageUrl;
  String? imageName;
  String? editingId;

  bool uploading = false;

  /// PICK IMAGE
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      imageFile = picked;
      imageName = picked.name; // original filename
    });

    await saveBanner();
  }

  /// UPLOAD IMAGE
  Future<String?> uploadImage() async {
    if (imageFile == null || imageName == null) return null;

    imageName = imageName!;

    try {
      Reference ref = storage.ref().child("banners/$imageName");

      TaskSnapshot snapshot = await ref.putData(await imageFile!.readAsBytes());

      imageUrl = await snapshot.ref.getDownloadURL();

      return imageName;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// SAVE BANNER
  Future<void> saveBanner() async {
    if (imageFile == null && editingId == null) return;

    String? savedFileName;

    if (imageFile != null) {
      savedFileName = await uploadImage();
    }

    if (editingId == null) {
      DocumentReference docRef = firestore.collection("banners").doc();

      await docRef.set({
        "imageUrl": imageUrl ?? "",
        "imageName": savedFileName ?? "",
        "active": true,
      });
    } else {
      await firestore.collection("banners").doc(editingId).update({
        if (imageUrl != null) "imageUrl": imageUrl,
        if (savedFileName != null) "imageName": savedFileName,
      });

      editingId = null;
    }

    setState(() {
      imageFile = null;
    });
  }

  /// DELETE BANNER
  Future<void> deleteBanner(String id, String imageName) async {
    try {
      await storage.ref("banners/$imageName").delete();
    } catch (e) {
      debugPrint("Image not found");
    }

    await firestore.collection("banners").doc(id).delete();
  }

  /// TOGGLE ACTIVE
  Future<void> toggleActive(String id, bool value) async {
    await firestore.collection("banners").doc(id).update({"active": value});
  }

  /// UPDATE IMAGE
  Future<void> updateBannerImage(String docId) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      imageFile = XFile(picked.path);
      editingId = docId;
    });

    await saveBanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        title: Text(
          "Banner Manager",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: const Icon(Icons.add),
      ),

      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: firestore.collection("banners").snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var banners = snapshot.data!.docs;

              if (banners.isEmpty) {
                return const Center(child: Text("No banners"));
              }

              return ListView.builder(
                itemCount: banners.length,

                itemBuilder: (context, index) {
                  var data = banners[index].data() as Map<String, dynamic>;

                  String imageUrl = data["imageUrl"] ?? "";
                  bool active = data["active"] ?? false;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(10),

                    child: Padding(
                      padding: const EdgeInsets.all(10),

                      child: Row(
                        children: [
                          /// IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),

                            child: SizedBox(
                              width: 150,
                              height: 100,

                              child: CachedNetworkImage(
                                // color: Colors.white,
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (c, s) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (c, s, d) =>
                                    const Icon(Icons.image),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          /// ACTIVE SWITCH
                          Expanded(
                            child: Row(
                              children: [
                                const Text("Active"),

                                Switch(
                                  value: active,
                                  onChanged: (v) =>
                                      toggleActive(banners[index].id, v),
                                ),
                              ],
                            ),
                          ),

                          /// ACTION BUTTONS
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    updateBannerImage(banners[index].id),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteBanner(
                                  banners[index].id,
                                  data["imageName"],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          /// LOADER
          if (uploading)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
