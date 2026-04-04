// models/service.dart
class ServiceModel {
  String id;
  String name;
  String imageUrl;
  String offerto;
  
  ServiceModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.offerto,
  });

  // For Firestore (matches your provider's call)
  factory ServiceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      offerto: data['offerto'] ?? '',
    );
  }
  
  // Alternative name (if you prefer fromMap)
  factory ServiceModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      offerto: map['offerto'] ?? '',
    );
  }
  
  // Convert to Map for Firestore operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'offerto': offerto,
    };
  }
  
  // Copy with method for easy updates
  ServiceModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? offerto,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      offerto: offerto ?? this.offerto,
    );
  }
}
