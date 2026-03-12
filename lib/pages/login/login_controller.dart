import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  /// Observable states
  RxBool isPasswordHidden = true.obs;
  RxBool isConfirmPasswordHidden = true.obs;
  RxBool isLoading = false.obs;

  /// login / signup / forgot_password
  RxString currentPage = 'login'.obs;

  /// Variables
  String email = '';
  String password = '';
  String confirmPassword = '';
  String name = '';

  /// Setters
  void setEmail(String value) => email = value;
  void setPassword(String value) => password = value;
  void setConfirmPassword(String value) => confirmPassword = value;
  void setName(String value) => name = value;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  /// Page switchers
  void showSignup() {
    currentPage.value = 'signup';
  }

  void showLogin() {
    currentPage.value = 'login';
  }

  void showForgotPassword() {
    currentPage.value = 'forgot_password';
  }

  /// LOGIN
  Future<void> login() async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Get.snackbar(
      //   "Success",
      //   "Login successful",
      //   snackPosition: SnackPosition.BOTTOM,
      // );

      /// Navigate to home screen
       Get.offAllNamed('/home-screen');

    } on FirebaseAuthException catch (e) {

      Get.snackbar(
        "Login Failed",
        e.message ?? "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
      );

    } finally {
      isLoading.value = false;
    }
  }

  /// SIGNUP
  Future<void> signUp() async {
    try {

      if (password != confirmPassword) {
        Get.snackbar("Error", "Passwords do not match");
        return;
      }

      isLoading.value = true;

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await userCredential.user!.updateDisplayName(name);

      Get.snackbar(
        "Success",
        "Account created successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      showLogin();

    } on FirebaseAuthException catch (e) {

      Get.snackbar(
        "Signup Failed",
        e.message ?? "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
      );

    } finally {
      isLoading.value = false;
    }
  }

  /// FORGOT PASSWORD
  Future<void> forgotPassword() async {
    try {

      isLoading.value = true;

      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      Get.snackbar(
        "Success",
        "Password reset email sent",
        snackPosition: SnackPosition.BOTTOM,
      );

      showLogin();

    } on FirebaseAuthException catch (e) {

      Get.snackbar(
        "Error",
        e.message ?? "Something went wrong",
        snackPosition: SnackPosition.BOTTOM,
      );

    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}