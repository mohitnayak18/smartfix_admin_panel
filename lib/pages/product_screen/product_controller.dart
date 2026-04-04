// api_calls/controllers/product_controller.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:admin_panel/api_calls/models/brand_model.dart';
import 'package:admin_panel/api_calls/models/product_model.dart';
import 'package:admin_panel/api_calls/models/service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mime/mime.dart';

class ProductController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: "smartfixapp-18342.firebasestorage.app",
  );
  final ImagePicker _picker = ImagePicker();
  Uint8List? imageBytes;
  String? imageUrl;
  String? imageName;

  // ==================== BRAND METHODS ====================
  
  // Get all brands - Using correct collection name 'mobile_brands'
  Stream<List<BrandModel>> getBrands() {
    return _firestore.collection('mobile_brands').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BrandModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ==================== MODEL METHODS ====================
  
  // Get models by brand ID
  Stream<List<Map<String, dynamic>>> getModelsByBrand(String brandId) {
    return _firestore
        .collection('models')
        .where('brandId', isEqualTo: brandId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? '',
        };
      }).toList();
    });
  }

Stream<List<ServiceModel>> getServices() {
  return _firestore
      .collection('service')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      // Use fromFirestore - first param data (Map), second param id (String)
      return ServiceModel.fromFirestore(
        doc.data() as Map<String, dynamic>, 
        doc.id
      );
    }).toList();
  });
}

Future<ServiceModel?> getServiceById(String id) async {
  try {
    DocumentSnapshot doc = await _firestore.collection('service').doc(id).get();
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
  // Stream<List<ServiceModel>> getServices() {
  //   return _firestore.collection('service').snapshots().map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return ServiceModel.fromMap(doc.data() as String, doc.id as Map<String, dynamic>);
  //     }).toList();
  //   });
  // }

  // ==================== PRODUCT METHODS ====================
  
  // Get all products
  // Get all products with null safety
Stream<List<ProductModel>> getProducts() {
  return _firestore
      .collection('products')
      .snapshots()
      .map((snapshot) {
    print('Products found: ${snapshot.docs.length}');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      print('Product ID: ${doc.id}');
      print('Product data: $data');
      
      return ProductModel(
        id: doc.id,
        brandId: data['brandId']?.toString() ?? '',
        modelId: data['modelId']?.toString() ?? '',
        serviceId: data['serviceId']?.toString() ?? '',
        name: data['name']?.toString() ?? 'No Name', // Handle missing name
        price: data['price']?.toString() ?? '0',
        discountPrice: data['discountPrice']?.toString() ?? '0',
        rating: data['rating']?.toString() ?? '0',
        image: data['image']?.toString() ?? '',
      );
    }).toList();
  });
}

  // Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel(
          id: doc.id,
          brandId: doc['brandId'] ?? '',
          modelId: doc['modelId'] ?? '',
          serviceId: doc['serviceId'] ?? '',
          name: doc['name'] ?? '',
          price: doc['price']?.toString() ?? '',
          discountPrice: doc['discountPrice']?.toString() ?? '',
          rating: doc['rating']?.toString() ?? '',
          image: doc['image'] ?? '',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // Get products by brand
  Stream<List<ProductModel>> getProductsByBrand(String brandId) {
    return _firestore
        .collection('products')
        .where('brandId', isEqualTo: brandId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel(
          id: doc.id,
          brandId: doc['brandId'] ?? '',
          modelId: doc['modelId'] ?? '',
          serviceId: doc['serviceId'] ?? '',
          name: doc['name'] ?? '',
          price: doc['price']?.toString() ?? '',
          discountPrice: doc['discountPrice']?.toString() ?? '',
          rating: doc['rating']?.toString() ?? '',
          image: doc['image'] ?? '',
        );
      }).toList();
    });
  }

  // Get products by model
  Stream<List<ProductModel>> getProductsByModel(String modelId) {
    return _firestore
        .collection('products')
        .where('modelId', isEqualTo: modelId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel(
          id: doc.id,
          brandId: doc['brandId'] ?? '',
          modelId: doc['modelId'] ?? '',
          serviceId: doc['serviceId'] ?? '',
          name: doc['name'] ?? '',
          price: doc['price']?.toString() ?? '',
          discountPrice: doc['discountPrice']?.toString() ?? '',
          rating: doc['rating']?.toString() ?? '',
          image: doc['image'] ?? '',
        );
      }).toList();
    });
  }

  // Get products by service
  Stream<List<ProductModel>> getProductsByService(String serviceId) {
    return _firestore
        .collection('products')
        .where('serviceId', isEqualTo: serviceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel(
          id: doc.id,
          brandId: doc['brandId'] ?? '',
          modelId: doc['modelId'] ?? '',
          serviceId: doc['serviceId'] ?? '',
          name: doc['name'] ?? '',
          price: doc['price']?.toString() ?? '',
          discountPrice: doc['discountPrice']?.toString() ?? '',
          rating: doc['rating']?.toString() ?? '',
          image: doc['image'] ?? '',
        );
      }).toList();
    });
  }

  // ==================== IMAGE METHODS ====================
  
  // Pick image from gallery
  Future<XFile?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  // Upload image to Firebase Storage
    // Upload image to Firebase Storage
Future<String> uploadImage(XFile image) async {
  try {
    // Generate unique filename
    String fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = _storage.ref().child('product/$fileName');
    
    String downloadUrl;
    
    if (kIsWeb) {
      // Web platform
      print('📸 Uploading image from web...');
      Uint8List imageBytes = await image.readAsBytes();
      await ref.putData(imageBytes);
      downloadUrl = await ref.getDownloadURL();
    } else {
      // Mobile platform
      print('📸 Uploading image from mobile...');
      File file = File(image.path);
      await ref.putFile(file);
      downloadUrl = await ref.getDownloadURL();
    }
    
    print('✅ Image uploaded successfully');
    print('📎 URL: $downloadUrl');
    
    return downloadUrl;
  } catch (e) {
    print('❌ Image upload failed: $e');
    throw Exception('Failed to upload image: $e');
  }
}

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        // Extract file path from URL
        final Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw error if image deletion fails
    }
  }

  // ==================== SAVE/UPDATE/DELETE METHODS ====================
  
  // Save product (add or update)
  Future<void> saveProduct(ProductModel product) async {
    try {
      if (product.id == null || product.id!.isEmpty) {
        // Add new product
        await _firestore.collection('products').add({
          'brandId': product.brandId,
          'modelId': product.modelId,
          'serviceId': product.serviceId,
          'name': product.name,
          'price': product.price,
          'discountPrice': product.discountPrice,
          'rating': product.rating,
          'image': product.image,
          // 'createdAt': FieldValue.serverTimestamp(),
          // 'updatedAt': FieldValue.serverTimestamp(),
        });
//         log('Product added: ${product.id}');
// log('Product updated: ${product.id}');
        // log('Product added: ${product.id}' as num);
      } else {
        // Update existing product
        await _firestore.collection('products').doc(product.id).update({
          'brandId': product.brandId,
          'modelId': product.modelId,
          'serviceId': product.serviceId,
          'name': product.name,
          'price': product.price,
          'discountPrice': product.discountPrice,
          'rating': product.rating,
          'image': product.image,
          // 'updatedAt': FieldValue.serverTimestamp(),
        });
        log('Product updated: ${product.id}' as num);
        // log('Product updated: ${product.id}' as num);

      }
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      // First get the product to delete its image
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        String imageUrl = doc['image'] ?? '';
        if (imageUrl.isNotEmpty) {
          await deleteImage(imageUrl);
        }
      }
      
      // Delete the product document
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Delete multiple products
  Future<void> deleteMultipleProducts(List<String> productIds) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (String id in productIds) {
        DocumentReference ref = _firestore.collection('products').doc(id);
        batch.delete(ref);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete products: $e');
    }
  }

  // ==================== SEARCH METHODS ====================
  
  // Search products by name
  Stream<List<ProductModel>> searchProducts(String searchQuery) {
    return _firestore
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: searchQuery)
        .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel(
          id: doc.id,
          brandId: doc['brandId'] ?? '',
          modelId: doc['modelId'] ?? '',
          serviceId: doc['serviceId'] ?? '',
          name: doc['name'] ?? '',
          price: doc['price']?.toString() ?? '',
          discountPrice: doc['discountPrice']?.toString() ?? '',
          rating: doc['rating']?.toString() ?? '',
          image: doc['image'] ?? '',
        );
      }).toList();
    });
  }

  // ==================== VALIDATION METHODS ====================
  
  // Validate product data
  String? validateProduct(ProductModel product) {
    if (product.name.isEmpty) {
      return 'Product name is required';
    }
    if (product.price.isEmpty) {
      return 'Price is required';
    }
    if (product.brandId.isEmpty) {
      return 'Brand is required';
    }
    if (product.modelId.isEmpty) {
      return 'Model is required';
    }
    if (product.serviceId.isEmpty) {
      return 'Service is required';
    }
    return null;
  }

  // ==================== STATISTICS METHODS ====================
  
  // Get total products count
  Future<int> getTotalProductsCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get product count: $e');
    }
  }

  // Get products count by brand
  Future<int> getProductsCountByBrand(String brandId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('brandId', isEqualTo: brandId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get product count: $e');
    }
  }
}