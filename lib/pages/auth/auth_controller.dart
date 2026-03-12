import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_panel/navigators/app_pages.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final otpController = TextEditingController();
  var isLoading = false.obs;

  late String verificationId;
  late String phoneNumber;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null &&
        args['verificationId'] != null &&
        args['phoneNumber'] != null) {
      verificationId = args['verificationId'];
      phoneNumber = args['phoneNumber'];
    } else {
      Get.snackbar('Error', 'Session expired');
      Future.microtask(() => Get.back());
    }
  }

  Future<void> verifyOtp() async {
    final smsCode = otpController.text.trim();

    if (smsCode.length != 6) {
      Get.snackbar('Error', 'Enter valid 6-digit OTP');
      return;
    }

    try {
      isLoading.value = true;

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        Get.snackbar('Error', 'User not found');
        return;
      }

      final uid = user.uid;

      // =============================
      // 🔐 ADMIN ROLE CHECK
      // =============================
      final adminDoc =
          await _firestore.collection('admins').doc(uid).get();

      if (!adminDoc.exists) {
        await _auth.signOut();
        Get.snackbar('Access Denied', 'You are not Admin');
        return;
      }

      // Optional: Role validation
      final role = adminDoc.data()?['role'];

      if (role != 'admin' && role != 'super_admin') {
        await _auth.signOut();
        Get.snackbar('Access Denied', 'Invalid role');
        return;
      }

      // =============================
      // SUCCESS → GO TO HOME
      // =============================
      Get.offAllNamed(Routes.home);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        Get.snackbar('Error', 'Invalid OTP');
      } else if (e.code == 'session-expired') {
        Get.snackbar('Error', 'OTP expired');
      } else {
        Get.snackbar('Error', e.message ?? 'Authentication failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}