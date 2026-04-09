// pages/partners/partners_list_screen.dart
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartnersListScreen extends StatefulWidget {
  const PartnersListScreen({super.key});

  @override
  State<PartnersListScreen> createState() => _PartnersListScreenState();
}

class _PartnersListScreenState extends State<PartnersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: "smartfixapp-18342.firebasestorage.app",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Partners Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search partners by name, phone, or email...',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          // Add Partner Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showPartnerDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Partner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Partners List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('partners')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 50, color: Colors.red),
                        const SizedBox(height: 10),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                var partners = docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return {'id': doc.id, ...data};
                }).toList();

                if (_searchQuery.isNotEmpty) {
                  partners = partners.where((partner) {
                    return partner['name'].toString().toLowerCase().contains(
                          _searchQuery,
                        ) ||
                        partner['phoneNumber'].toString().contains(
                          _searchQuery,
                        );
                  }).toList();
                }

                if (partners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No Partners Found'
                              : 'No matching partners found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Text('Clear Search'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: partners.length,
                  itemBuilder: (context, index) {
                    final partner = partners[index];
                    return _buildPartnerCard(partner);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    bool isAvailable = partner['isAvailable'] ?? true;
    int assignedOrdersCount = partner['assignedOrdersCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner Photo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAvailable ? Colors.green : Colors.red,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8),
                ],
              ),
              child: ClipOval(
                child:
                    (partner['photoUrl'] != null &&
                        partner['photoUrl'].toString().isNotEmpty)
                    ? Image.network(
                        partner['photoUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.teal.shade100,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.teal.shade700,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.teal.shade100,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.teal.shade700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Partner Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          partner['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAvailable ? 'Available' : 'Unavailable',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isAvailable
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        partner['phoneNumber'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Orders Count with Edit Button
                  Row(
                    children: [
                      Icon(Icons.assignment, size: 14, color: Colors.teal),
                      const SizedBox(width: 4),
                      Text(
                        '$assignedOrdersCount Orders',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showEditOrdersCountDialog(partner),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue.shade700),
                  onPressed: () => _showPartnerDialog(partner: partner),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.shade700),
                  onPressed: () => _confirmDelete(partner),
                  tooltip: 'Delete',
                ),
                IconButton(
                  icon: Icon(
                    isAvailable ? Icons.block : Icons.check_circle,
                    color: isAvailable ? Colors.orange : Colors.green,
                  ),
                  onPressed: () => _toggleAvailability(partner),
                  tooltip: isAvailable ? 'Mark Unavailable' : 'Mark Available',
                ),
              ],
            ),
          ],
        )
      ),
    );
  }

  // Dialog to edit orders count
  void _showEditOrdersCountDialog(Map<String, dynamic> partner) {
    final TextEditingController ordersController = TextEditingController(
      text: (partner['assignedOrdersCount'] ?? 0).toString(),
    );
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.edit_note, color: Colors.teal),
            const SizedBox(width: 8),
            const Text('Edit Orders Count'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partner: ${partner['name']}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ordersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Orders Count',
                prefixIcon: const Icon(Icons.assignment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                helperText: 'Enter the total number of orders assigned to this partner',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCount = int.tryParse(ordersController.text.trim());
              if (newCount == null) {
                Get.snackbar(
                  'Error',
                  'Please enter a valid number',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              Get.back();
              
              try {
                await FirebaseFirestore.instance
                    .collection('partners')
                    .doc(partner['id'])
                    .update({
                  'assignedOrdersCount': newCount,
                });
                
                Get.snackbar(
                  'Success',
                  'Orders count updated to $newCount',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update orders count: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Method to upload image to Firebase Storage
  Future<String?> _uploadImageToStorage(Uint8List imageBytes, String fileName) async {
    try {
      // Create a reference to the location in Firebase Storage
      final storageRef = _storage.ref().child('partners/$fileName.jpg');
      
      // Upload the file
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Method to pick image file
  Future<Uint8List?> _pickImage() async {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    await input.onChange.first;
    
    if (input.files!.isEmpty) return null;
    
    final file = input.files![0];
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    
    await reader.onLoad.first;
    
    return reader.result as Uint8List?;
  }

  void _showPartnerDialog({Map<String, dynamic>? partner}) {
    final bool isEditing = partner != null;
    final formKey = GlobalKey<FormState>();

    // Controllers
    final nameController = TextEditingController(text: partner?['name'] ?? '');
    final phoneController = TextEditingController(
      text: partner?['phoneNumber'] ?? '',
    );
    final ordersCountController = TextEditingController(
      text: (partner?['assignedOrdersCount'] ?? 0).toString(),
    );
    
    String? photoUrl = partner?['photoUrl'] ?? '';
    bool isAvailable = partner?['isAvailable'] ?? true;
    Uint8List? selectedImageBytes;
    bool isUploading = false;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? 'Edit Partner' : 'Add New Partner',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Image Picker Section
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  // Image Preview
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: selectedImageBytes != null
                                        ? Image.memory(
                                            selectedImageBytes!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : (photoUrl!.isNotEmpty)
                                            ? Image.network(
                                                photoUrl!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.image_not_supported, size: 40),
                                                        SizedBox(height: 8),
                                                        Text('No Image Selected'),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                            : const Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.person, size: 50),
                                                    SizedBox(height: 8),
                                                    Text('No Image Selected'),
                                                  ],
                                                ),
                                              ),
                                  ),
                                  // Upload Button
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    child: ElevatedButton.icon(
                                      onPressed: isUploading
                                          ? null
                                          : () async {
                                              final imageBytes = await _pickImage();
                                              if (imageBytes != null) {
                                                setState(() {
                                                  selectedImageBytes = imageBytes;
                                                  photoUrl = ''; // Clear old URL if new image is selected
                                                });
                                              }
                                            },
                                      icon: isUploading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.upload),
                                      label: Text(
                                        isUploading ? 'Uploading...' : 'Choose Image',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Name
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Phone
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Orders Count (Only for Add, not for Edit)
                            if (!isEditing)
                              TextFormField(
                                controller: ordersCountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Initial Orders Count',
                                  prefixIcon: const Icon(Icons.assignment),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  helperText: 'Number of orders already assigned to this partner',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter orders count';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            
                            const SizedBox(height: 16),
                            
                            // Available Checkbox
                            CheckboxListTile(
                              title: const Text('Available'),
                              value: isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  isAvailable = value ?? false;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  isUploading = true;
                                });

                                String? finalPhotoUrl = photoUrl;

                                // Upload new image if selected
                                if (selectedImageBytes != null) {
                                  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
                                  final uploadedUrl = await _uploadImageToStorage(
                                    selectedImageBytes!,
                                    fileName,
                                  );
                                  if (uploadedUrl != null) {
                                    finalPhotoUrl = uploadedUrl;
                                  }
                                }

                                final partnerData = {
                                  'name': nameController.text.trim(),
                                  'phoneNumber': phoneController.text.trim(),
                                  'photoUrl': finalPhotoUrl ?? '',
                                  'assignedOrdersCount': isEditing
                                      ? (partner?['assignedOrdersCount'] ?? 0)
                                      : int.parse(ordersCountController.text.trim()),
                                  'isAvailable': isAvailable,
                                };

                                try {
                                  if (isEditing) {
                                    await FirebaseFirestore.instance
                                        .collection('partners')
                                        .doc(partner['id'])
                                        .update(partnerData);
                                  } else {
                                    await FirebaseFirestore.instance
                                        .collection('partners')
                                        .add(partnerData);
                                  }

                                  Get.back();
                                  Get.snackbar(
                                    'Success',
                                    isEditing
                                        ? 'Partner updated successfully'
                                        : 'Partner added successfully',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } catch (e) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to save partner: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } finally {
                                  setState(() {
                                    isUploading = false;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(isEditing ? 'Update' : 'Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> partner) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Partner'),
        content: Text('Are you sure you want to delete ${partner['name']}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                // Also delete the image from storage if exists
                if (partner['photoUrl'] != null && partner['photoUrl'].toString().isNotEmpty) {
                  try {
                    final storageRef = _storage.refFromURL(partner['photoUrl'].toString());
                    await storageRef.delete();
                  } catch (e) {
                    print('Error deleting image: $e');
                  }
                }
                
                await FirebaseFirestore.instance
                    .collection('partners')
                    .doc(partner['id'])
                    .delete();
                    
                Get.snackbar(
                  'Success',
                  'Partner deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete partner: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(Map<String, dynamic> partner) async {
    try {
      bool newAvailability = !(partner['isAvailable'] ?? true);
      await FirebaseFirestore.instance
          .collection('partners')
          .doc(partner['id'])
          .update({'isAvailable': newAvailability});

      Get.snackbar(
        'Success',
        'Partner ${newAvailability ? 'available' : 'unavailable'} now',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update availability: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}