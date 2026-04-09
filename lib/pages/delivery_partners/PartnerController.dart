// import 'package:get/get.dart';

// class ProfileController extends GetxController {


// }
// services/partner_service.dart
import 'package:admin_panel/api_calls/models/partner_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerController {
  final CollectionReference _partnersCollection =
      FirebaseFirestore.instance.collection('partners');

  // Get all partners
  Stream<List<PartnerModel>> getPartners() {
    return _partnersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PartnerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get partner by ID
  Future<PartnerModel?> getPartnerById(String id) async {
    try {
      DocumentSnapshot doc = await _partnersCollection.doc(id).get();
      if (doc.exists) {
        return PartnerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting partner: $e');
      return null;
    }
  }

  // Add partner
  Future<bool> addPartner(PartnerModel partner) async {
    try {
      await _partnersCollection.doc(partner.id).set(partner.toMap());
      return true;
    } catch (e) {
      print('Error adding partner: $e');
      return false;
    }
  }

  // Update partner
  Future<bool> updatePartner(PartnerModel partner) async {
    try {
      await _partnersCollection.doc(partner.id).update(partner.toMap());
      return true;
    } catch (e) {
      print('Error updating partner: $e');
      return false;
    }
  }

  // Delete partner
  Future<bool> deletePartner(String id) async {
    try {
      await _partnersCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting partner: $e');
      return false;
    }
  }

  // Update partner availability
  Future<bool> updateAvailability(String id, bool isAvailable) async {
    try {
      await _partnersCollection.doc(id).update({'isAvailable': isAvailable});
      return true;
    } catch (e) {
      print('Error updating availability: $e');
      return false;
    }
  }

  // Increment assigned orders count
  Future<void> incrementAssignedOrders(String partnerId) async {
    try {
      await _partnersCollection.doc(partnerId).update({
        'assignedOrdersCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing orders: $e');
    }
  }

  // Get partners list for dropdown
  Future<List<Map<String, dynamic>>> getPartnersForDropdown() async {
    try {
      QuerySnapshot snapshot = await _partnersCollection
          .where('isAvailable', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'photoUrl': data['photoUrl'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error getting partners for dropdown: $e');
      return [];
    }
  }
}