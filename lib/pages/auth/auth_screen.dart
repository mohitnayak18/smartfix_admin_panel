import 'package:admin_panel/pages/auth/auth_controller.dart';
import 'package:admin_panel/utils/asset_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({super.key});

  final AuthController controller = Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450, // important for web
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 15,
                  color: Colors.black12,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Animation
                  Lottie.asset(
                    AssetConstants.authscreen,
                    height: 200,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Phone Verification',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Enter the 6-digit code sent to\n${controller.phoneNumber}',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  /// OTP INPUT
                  Pinput(
                    controller: controller.otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: const Color(0xFF0D9488),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length != 6) {
                        return 'Enter valid OTP';
                      }
                      return null;
                    },
                    onCompleted: (_) {
                      if (_formKey.currentState!.validate()) {
                        controller.verifyOtp();
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  /// VERIFY BUTTON
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.verifyOtp();
                                }
                              },
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Verify & Continue',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Edit phone number?',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}