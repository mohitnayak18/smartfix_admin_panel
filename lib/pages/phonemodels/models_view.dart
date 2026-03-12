import 'dart:typed_data';
import 'package:admin_panel/theme/dimens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Uint8List? imageBytes;
  String? imageUrl;
  String? imageName;

  String? selectedBrandId;
  String? editingId;

  /// PICK IMAGE
  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      imageBytes = await file.readAsBytes();

      imageName = file.name; // original name like Galaxy S25 Ultra.png

      setState(() {});
    }
  }

  /// UPLOAD IMAGE
  Future<String?> uploadImage() async {
    if (imageBytes == null || imageName == null) return null;

    // make filename safe
    imageName = imageName!.replaceAll(" ", "_");

    String mimeType =
        lookupMimeType('', headerBytes: imageBytes) ?? 'image/png';

    final storage = FirebaseStorage.instanceFor(
      bucket: "smartfixapp-18342.firebasestorage.app",
    );

    // stored directly inside models/
    final ref = storage.ref().child("models/$imageName");

    final metadata = SettableMetadata(contentType: mimeType);

    TaskSnapshot snapshot = await ref.putData(imageBytes!, metadata);

    imageUrl = await snapshot.ref.getDownloadURL();

    return imageName;
  }

  /// SAVE MODEL
  Future<void> saveModel() async {
    if (nameController.text.isEmpty || selectedBrandId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (editingId == null && imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please upload image")));
      return;
    }

    if (editingId == null) {
      // CREATE
      DocumentReference docRef = firestore.collection("models").doc();
      String modelId = docRef.id;

      String? savedFileName;

      if (imageBytes != null) {
        savedFileName = await uploadImage();
      }

      await docRef.set({
        "modelId": modelId,
        "brandId": selectedBrandId,
        "name": nameController.text,
        "imageUrl": imageUrl ?? "",
        "imageName": savedFileName ?? "",
      });
    } else {
      // UPDATE
      String? savedFileName;

      if (imageBytes != null) {
        savedFileName = await uploadImage();
      }

      await firestore.collection("models").doc(editingId).update({
        "modelId": editingId,
        "brandId": selectedBrandId,
        "name": nameController.text,
        if (imageUrl != null) "imageUrl": imageUrl,
        if (savedFileName != null) "imageName": savedFileName,
      });
    }

    clearForm();
  }

  /// DELETE MODEL
  Future<void> deleteModel(String id) async {
    await firestore.collection("models").doc(id).delete();
  }

  /// EDIT MODEL
  void editModel(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    nameController.text = data["name"] ?? "";
    selectedBrandId = data["brandId"];
    imageUrl = data["imageUrl"];

    editingId = doc.id;

    setState(() {});
  }

  /// CLEAR FORM
  void clearForm() {
    nameController.clear();
    selectedBrandId = null;
    editingId = null;
    imageBytes = null;
    imageUrl = null;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyActions: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "Model Management",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey,
      ),

      body: Row(
        children: [
          /// LEFT SIDE FORM
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade100,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add / Update Model",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// BRAND DROPDOWN
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection("mobile_brands").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      var brands = snapshot.data!.docs;

                      return DropdownButtonFormField<String>(
                        // focusColor: Colors.white,
                        dropdownColor: Colors.white,
                        value: selectedBrandId,

                        hint: const Text("Select Brand"),

                        items: brands.map((brand) {
                          return DropdownMenuItem(
                            value: brand.id,
                            child: Text(brand["name"]),
                          );
                        }).toList(),

                        onChanged: (value) {
                          setState(() {
                            selectedBrandId = value;
                          });
                        },

                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(16),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  /// MODEL NAME
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Model Name",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// IMAGE BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: pickImage,
                    icon: const Icon(Icons.upload, color: Colors.blueGrey),
                    label: Text(
                      "Upload Image",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// IMAGE PREVIEW
                  if (imageBytes != null)
                    Image.memory(imageBytes!, height: 120)
                  else if (imageUrl != null)
                    Image.network(imageUrl!, height: 120),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: saveModel,
                    child: Text(
                      editingId == null ? "Add Model" : "Update Model",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (editingId != null)
                    // Dimens.boxHeight2,
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: clearForm,
                      child: const Text(
                        "Cancel Edit",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// RIGHT SIDE TABLE
          Expanded(
            flex: 4,
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection("models").snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No Models Found"));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),

                  child: DataTable(
                    dataRowMinHeight: 80,
                    dataRowMaxHeight: 90,
                    columnSpacing: 30,
                    dividerThickness: 0,
                    border: TableBorder.all(color: Colors.white),

                    columns: const [
                      DataColumn(label: Text("Image")),
                      DataColumn(label: Text("Model Name")),
                      DataColumn(label: Text("Brand ID")),
                      DataColumn(label: Text("Model ID")),
                      DataColumn(label: Text("Actions")),
                    ],

                    rows: List.generate(docs.length, (index) {
                      var doc = docs[index];
                      var data = doc.data() as Map<String, dynamic>? ?? {};

                      return DataRow(
                        color: MaterialStateProperty.all(
                          index % 2 == 0 ? Colors.white : Colors.grey.shade100,
                        ),
                        cells: [
                          /// IMAGE
                          DataCell(
                            Image.network(
                              data["imageUrl"] ?? "",
                              width: 60,
                              height: 80,
                              fit: BoxFit.fitHeight,
                              errorBuilder: (a, b, c) =>
                                  const Icon(Icons.image),
                            ),
                          ),

                          /// NAME
                          DataCell(Text(data["name"] ?? "")),

                          /// BRAND ID
                          DataCell(Text(data["brandId"] ?? "")),

                          /// MODEL ID
                          DataCell(Text(data["modelId"] ?? doc.id)),

                          /// ACTIONS
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => editModel(doc),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => deleteModel(doc.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
