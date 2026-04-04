import 'package:admin_panel/api_calls/models/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ServiceProvider {
  final CollectionReference serviceCollection = 
      FirebaseFirestore.instance.collection('service');
 final storage = FirebaseStorage.instanceFor(
      bucket: "smartfixapp-18342.firebasestorage.app",
    );
  
  // Add new service
  Future<void> addService({
    required String name,
    required String offerto,
    XFile? imageFile,
  }) async {
    try {
      String imageUrl = '';
      
      // Upload image if selected
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, name);
      }
      
      // Create new document with auto-generated ID
      DocumentReference docRef = serviceCollection.doc();
      
      await docRef.set({
        'name': name,
        'offerto': offerto,
        'imageUrl': imageUrl,
      });
      
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }
  
  // Add service using ServiceModel object
  Future<void> addServiceFromModel(ServiceModel service, {XFile? imageFile}) async {
    try {
      String imageUrl = service.imageUrl;
      
      // Upload new image if provided
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, service.name);
      }
      
      DocumentReference docRef = serviceCollection.doc();
      
      await docRef.set({
        'name': service.name,
        'offerto': service.offerto,
        'imageUrl': imageUrl,
      });
      
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }
  
  // Update existing service
  Future<void> updateService({
    required String docId,
    required String name,
    required String offerto,
    XFile? newImageFile,
    String? existingImageUrl,
  }) async {
    try {
      String imageUrl = existingImageUrl ?? '';
      
      // Upload new image if provided
      if (newImageFile != null) {
        // Delete old image if exists
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await deleteImageFromUrl(existingImageUrl);
        }
        imageUrl = await uploadImage(newImageFile, name);
      }
      
      await serviceCollection.doc(docId).update({
        'name': name,
        'offerto': offerto,
        'imageUrl': imageUrl,
      });
      
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }
  
  // Update service using ServiceModel object
  Future<void> updateServiceFromModel(ServiceModel service, {XFile? newImageFile}) async {
    try {
      String imageUrl = service.imageUrl;
      
      // Upload new image if provided
      if (newImageFile != null) {
        // Delete old image if exists
        if (service.imageUrl.isNotEmpty) {
          await deleteImageFromUrl(service.imageUrl);
        }
        imageUrl = await uploadImage(newImageFile, service.name);
      }
      
      await serviceCollection.doc(service.id).update({
        'name': service.name,
        'offerto': service.offerto,
        'imageUrl': imageUrl,
      });
      
    } catch (e) {
      throw Exception('Failed to update service: $e');
    }
  }
  
  // Partial update (update specific fields only)
  Future<void> updateServiceFields({
    required String docId,
    String? name,
    String? offerto,
    XFile? newImageFile,
    String? existingImageUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (offerto != null) updateData['offerto'] = offerto;
      
      if (newImageFile != null) {
        // Delete old image if exists
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await deleteImageFromUrl(existingImageUrl);
        }
        String newImageUrl = await uploadImage(newImageFile, name ?? 'service');
        updateData['imageUrl'] = newImageUrl;
      }
      
      if (updateData.isNotEmpty) {
        await serviceCollection.doc(docId).update(updateData);
      }
      
    } catch (e) {
      throw Exception('Failed to update service fields: $e');
    }
  }
  
  // Delete service
  Future<void> deleteService(String docId, String? imageUrl) async {
    try {
      // Delete image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImageFromUrl(imageUrl);
      }
      
      // Delete document from Firestore
      await serviceCollection.doc(docId).delete();
      
    } catch (e) {
      throw Exception('Failed to delete service: $e');
    }
  }
  
  // Delete multiple services
  Future<void> deleteMultipleServices(List<String> docIds, List<String?> imageUrls) async {
    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      
      // Delete images from storage
      for (String? imageUrl in imageUrls) {
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await deleteImageFromUrl(imageUrl);
        }
      }
      
      // Delete documents from Firestore
      for (String docId in docIds) {
        batch.delete(serviceCollection.doc(docId));
      }
      
      await batch.commit();
      
    } catch (e) {
      throw Exception('Failed to delete services: $e');
    }
  }
// Upload image to Firebase Storage (Web & Mobile compatible)
Future<String> uploadImage(XFile imageFile, String serviceName) async {
    try {
      String cleanName = serviceName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String fileName = 'services/${DateTime.now().millisecondsSinceEpoch}_$cleanName.jpg';
      Reference storageRef = storage.ref().child(fileName);
     
      
      String downloadUrl;
      
      if (kIsWeb) {
        // WEB PLATFORM: Use bytes
        print('📸 Uploading service image from web...');
        Uint8List imageBytes = await imageFile.readAsBytes();
        await storageRef.putData(imageBytes);
        downloadUrl = await storageRef.getDownloadURL();
      } else {
        // MOBILE PLATFORM: Use file
        print('📸 Uploading service image from mobile...');
        File file = File(imageFile.path);
        await storageRef.putFile(file);
        downloadUrl = await storageRef.getDownloadURL();
      }
      
      print('✅ Service image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  // Delete image from storage (Simplified - works on both platforms)
  Future<void> deleteImageFromUrl(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;
      
      // This works on both web and mobile
      final Reference ref = storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Image deleted: $imageUrl');
    } catch (e) {
      print('Failed to delete image: $e');
      // Don't throw - we still want to delete the document
    }
  }
  // Stream of all services (real-time)
  Stream<List<ServiceModel>> getServices() {
    return serviceCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceModel.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }
  
  // Stream with query (e.g., ordered by name)
  Stream<List<ServiceModel>> getServicesOrderedByName() {
    return serviceCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceModel.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }
  
  // Get single service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      DocumentSnapshot doc = await serviceCollection.doc(id).get();
      if (doc.exists) {
        return ServiceModel.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get service: $e');
    }
  }
  
  // Get all services as Future (one-time read)
  Future<List<ServiceModel>> getAllServices() async {
    try {
      QuerySnapshot snapshot = await serviceCollection.get();
      return snapshot.docs.map((doc) {
        return ServiceModel.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get services: $e');
    }
  }
  
  // Check if service exists
  Future<bool> serviceExists(String docId) async {
    try {
      DocumentSnapshot doc = await serviceCollection.doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
  
  // Search services by name
  Stream<List<ServiceModel>> searchServices(String searchTerm) {
    return serviceCollection
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceModel.fromFirestore(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }
}