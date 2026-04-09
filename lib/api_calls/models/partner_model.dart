// models/partner_model.dart
class PartnerModel {
  String id;
  String name;
  String phoneNumber;
  String photoUrl;
  int assignedOrdersCount;
  bool isAvailable;

  PartnerModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.photoUrl,
    this.assignedOrdersCount = 0,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'assignedOrdersCount': assignedOrdersCount,
      'isAvailable': isAvailable,
    };
  }

  factory PartnerModel.fromMap(Map<String, dynamic> map, String id) {
    return PartnerModel(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      assignedOrdersCount: map['assignedOrdersCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
     
    );
  }
}