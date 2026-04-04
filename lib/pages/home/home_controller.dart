import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Dashboard stats
  var totalOrders = 0.obs;
  var pendingOrders = 0.obs;
  var completedOrders = 0.obs;
  var totalRevenue = 0.0.obs;
  var totalCanceled = 0.0.obs;
  
  // ALL AUTH USERS (with phone numbers)
  var allAuthUsers = <Map<String, dynamic>>[].obs;
  var phoneUsers = <Map<String, dynamic>>[].obs; // Separate list for phone users
  var emailUsers = <Map<String, dynamic>>[].obs; // Users with email
  var allUsersList = <Map<String, dynamic>>[].obs; // All users combined
  
  var isLoadingUsers = false.obs;
  var userError = ''.obs;
  
  // Recent orders
  var recentOrders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
    loadRecentOrders();
    fetchAllAuthUsers();
  }

  // Fetch ALL users from Firebase Authentication
  Future<void> fetchAllAuthUsers() async {
    try {
      isLoadingUsers.value = true;
      userError.value = '';
      
      print("📱 Fetching all auth users...");
      
      // Call the Cloud Function
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getAllAuthUsers');
      final result = await callable();
      
      print("📱 Cloud function response received");
      
      if (result.data != null) {
        List<dynamic> users = result.data;
        // print("📱 Total users from Cloud Function: ${users.length}");
        
        // Process all users
        List<Map<String, dynamic>> processedUsers = [];
        List<Map<String, dynamic>> processedPhoneUsers = [];
        List<Map<String, dynamic>> processedEmailUsers = [];
        
        for (var user in users) {
          try {
            String phoneNumber = user['phoneNumber'] ?? '';
            String email = user['email'] ?? '';
            String displayName = user['displayName'] ?? '';
            bool isPhoneUser = user['isPhoneUser'] ?? false;
            
            // Clean phone number (remove country code if needed for display)
            String cleanPhone = phoneNumber;
            if (phoneNumber.isNotEmpty && phoneNumber != 'No phone') {
              // You can format phone number here if needed
              if (phoneNumber.startsWith('+')) {
                cleanPhone = phoneNumber; // Keep as is with country code
              }
            }
            
            Map<String, dynamic> processedUser = {
              'uid': user['uid'] ?? '',
              'email': email.isNotEmpty ? email : 'No email',
              'phoneNumber': cleanPhone.isNotEmpty ? cleanPhone : 'No phone',
              'displayName': displayName.isNotEmpty ? displayName : 
                            (cleanPhone.isNotEmpty ? cleanPhone : 'No name'),
              'photoURL': user['photoURL'] ?? '',
              'creationTime': _formatTimestamp(user['creationTime']),
              'lastSignInTime': _formatTimestamp(user['lastSignInTime']),
              'providerId': user['providerId'] ?? 'unknown',
              'isPhoneUser': isPhoneUser || (phoneNumber.isNotEmpty && email.isEmpty),
              'hasPhone': phoneNumber.isNotEmpty,
              'hasEmail': email.isNotEmpty,
              'providers': user['providers'] ?? [],
            };
            
            processedUsers.add(processedUser);
            
            // Categorize users
            if (processedUser['isPhoneUser'] == true || phoneNumber.isNotEmpty) {
              processedPhoneUsers.add(processedUser);
              // print("📞 Phone user found: $phoneNumber - ${processedUser['displayName']}");
            }
            
            if (email.isNotEmpty) {
              processedEmailUsers.add(processedUser);
            }
            
          } catch (e) {
            print("Error processing user: $e");
          }
        }
        
        allAuthUsers.value = processedUsers;
        phoneUsers.value = processedPhoneUsers;
        emailUsers.value = processedEmailUsers;
        
        // Combine all users for display
        allUsersList.value = [...processedPhoneUsers, ...processedEmailUsers];
        
        print("✅ Total users fetched: ${allAuthUsers.length}");
        print("✅ Phone users found: ${phoneUsers.length}");
        print("✅ Email users found: ${emailUsers.length}");
        
        // Show all phone numbers in console
        if (phoneUsers.isNotEmpty) {
          // print("\n📞 ALL PHONE NUMBERS REGISTERED:");
          for (var i = 0; i < phoneUsers.length; i++) {
            var user = phoneUsers[i];
            // print("   ${i+1}. ${user['phoneNumber']} (${user['displayName']})");
          }
        } else {
          print("⚠️ No phone users found!");
        }
      }
    } catch (e) {
      userError.value = e.toString();
      print("❌ Error fetching auth users: $e");
      Get.snackbar(
        'Error',
        'Failed to fetch users: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // Helper method to safely format timestamps
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      if (timestamp is String) {
        return timestamp;
      }
      if (timestamp is Timestamp) {
        return timestamp.toDate().toString();
      }
      if (timestamp is DateTime) {
        return timestamp.toString();
      }
      return timestamp.toString();
    } catch (e) {
      return '';
    }
  }

Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed('/login-view');
      // Get.offAll(() => const LoginView());
    } catch (e) {
      Get.snackbar("Logout Failed", e.toString());
    }
  }
  // Load dashboard statistics
  Future<void> loadDashboardData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();

      int total = snapshot.docs.length;
      int pending = 0;
      int completed = 0;
      double revenue = 0;
      double canceledRevenue = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        String status = data['status']?.toString().toLowerCase() ?? '';
        double amount = (data['subtotal'] ?? 0).toDouble();

        if (status == "pending") {
          pending++;
        }

        if (status == "completed" || status == "delivered") {
          completed++;
          revenue += amount;
        }

        if (status == "cancelled" || status == "canceled") {
          canceledRevenue += amount;
        }
      }

      totalOrders.value = total;
      pendingOrders.value = pending;
      completedOrders.value = completed;
      totalRevenue.value = revenue;
      totalCanceled.value = canceledRevenue;

    } catch (e) {
      print("Dashboard load error: $e");
    }
  }

  // Load recent orders
  Future<void> loadRecentOrders() async {
    try {
      isLoading.value = true;
      
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      
      recentOrders.value = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Create a safe copy of data
        Map<String, dynamic> safeData = {};
        data.forEach((key, value) {
          if (value is Timestamp) {
            safeData[key] = value.toDate().toIso8601String();
          } else if (value is DocumentReference) {
            safeData[key] = value.path;
          } else {
            safeData[key] = value;
          }
        });
        
        return {
          'id': doc.id,
          ...safeData,
        };
      }).toList();
      
    } catch (e) {
      print("Error loading recent orders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    try {
      await Future.wait([
        loadDashboardData(),
        loadRecentOrders(),
        fetchAllAuthUsers(),
      ]);
      
      // Get.snackbar(
      //   'Success',
      //   'Data refreshed successfully',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      print("Refresh error: $e");
    }
  }
}