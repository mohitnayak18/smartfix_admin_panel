import 'package:admin_panel/pages/login/login_controller.dart';
import 'package:admin_panel/theme/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:admin_panel/utils/asset_constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginController controller;
  final _formKey = GlobalKey<FormState>();

  // Focus nodes for better keyboard navigation
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: _buildDynamicCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicCard(BuildContext context) {
    return Container(
      width: 450,
      padding: Dimens.edgeInsets20,
      margin: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimation(),
            Dimens.boxHeight10,
            _buildTitle(context),
            Dimens.boxHeight20,
            _buildFormFields(context),
            Dimens.boxHeight25,
            _buildActionButton(context),
            Dimens.boxHeight15,
            _buildBottomLinks(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget _buildAnimation() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Lottie.asset(
        AssetConstants.loginpage,
        height: 140,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 140,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Obx(() {
      String title = '';
      String subtitle = '';

      switch (controller.currentPage.value) {
        case 'login':
          title = 'Welcome Back!';
          subtitle = 'Sign in to continue to Admin Panel';
          break;
        case 'signup':
          title = 'Create Account';
          subtitle = 'Sign up to get started';
          break;
        case 'forgot_password':
          title = 'Forgot Password';
          subtitle = 'Enter your email to reset your password';
          break;
      }

      return Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Dimens.boxHeight8,
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      );
    });
  }

  Widget _buildFormFields(BuildContext context) {
    return Obx(() {
      switch (controller.currentPage.value) {
        case 'login':
          return Column(
            children: [
              _buildEmailField(context),
              Dimens.boxHeight20,
              _buildPasswordField(),
              Dimens.boxHeight15,
              _buildForgotPasswordLink(),
            ],
          );
        case 'signup':
          return Column(
            children: [
              _buildNameField(),
              Dimens.boxHeight20,
              _buildEmailField(context),
              Dimens.boxHeight20,
              _buildPasswordField(),
              Dimens.boxHeight20,
              _buildConfirmPasswordField(),
            ],
          );
        case 'forgot_password':
          return Column(
            children: [
              _buildEmailField(context),
              Dimens.boxHeight10,
              _buildInfoText('We will send you a password reset link'),
            ],
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: controller.nameController,
      focusNode: _nameFocusNode,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      cursorColor: Get.theme.primaryColor,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person_outline, color: Get.theme.primaryColor),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildFocusedBorder(Get.theme.primaryColor),
        errorBorder: _buildErrorBorder(),
        focusedErrorBorder: _buildFocusedErrorBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name is required';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
      onChanged: controller.setName,
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      
      controller: controller.emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      cursorColor: Get.theme.primaryColor,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email_outlined, color: Get.theme.primaryColor),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildFocusedBorder(Get.theme.primaryColor),
        errorBorder: _buildErrorBorder(),
        focusedErrorBorder: _buildFocusedErrorBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      onFieldSubmitted: (_) {
        if (controller.currentPage.value == 'login') {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } else if (controller.currentPage.value == 'signup') {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } else {
          if (_formKey.currentState!.validate()) {
            controller.forgotPassword();
          }
        }
      },
      validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  if (value != value.toLowerCase()) {
    return 'Email must be in lowercase';
  }
  if (!GetUtils.isEmail(value.trim())) {
    return 'Please enter a valid email';
  }
  return null;
},
     onChanged: (value) {
  final lowerValue = value.toLowerCase();

  controller.emailController.value = TextEditingValue(
    text: lowerValue,
    selection: TextSelection.collapsed(offset: lowerValue.length),
  );

  controller.setEmail(lowerValue);
},
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextFormField(
              inputFormatters: [
  FilteringTextInputFormatter.deny(RegExp(r'\s')),
],
        controller: controller.passwordController,
        focusNode: _passwordFocusNode,
        obscureText: controller.isPasswordHidden.value,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: controller.currentPage.value == 'login'
            ? TextInputAction.done
            : TextInputAction.next,
        cursorColor: Get.theme.primaryColor,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: controller.currentPage.value == 'signup'
              ? 'Create a password'
              : 'Enter your password',
          prefixIcon: Icon(Icons.lock_outline, color: Get.theme.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordHidden.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: _buildBorder(),
          enabledBorder: _buildBorder(),
          focusedBorder: _buildFocusedBorder(Get.theme.primaryColor),
          errorBorder: _buildErrorBorder(),
          focusedErrorBorder: _buildFocusedErrorBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onFieldSubmitted: (_) {
          if (controller.currentPage.value == 'login') {
            if (_formKey.currentState!.validate()) {
              controller.login();
            }
          } else if (controller.currentPage.value == 'signup') {
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password is required';
          }
          if (value.length < 8) {
  return 'Minimum 8 characters required';
}
if (!RegExp(r'[A-Z]').hasMatch(value)) {
  return 'At least 1 uppercase letter required';
}
if (!RegExp(r'[0-9]').hasMatch(value)) {
  return 'At least 1 number required';
}
if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
  return 'At least 1 special character required';
}
          return null;
        },
        onChanged: controller.setPassword,
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Obx(
      () => TextFormField(
        inputFormatters: [
  FilteringTextInputFormatter.deny(RegExp(r'\s')),
],
        controller: controller.confirmPasswordController,
        focusNode: _confirmPasswordFocusNode,
        obscureText: controller.isConfirmPasswordHidden.value,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        cursorColor: Get.theme.primaryColor,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          hintText: 'Re-enter your password',
          prefixIcon: Icon(Icons.lock_outline, color: Get.theme.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isConfirmPasswordHidden.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey.shade600,
            ),
            onPressed: controller.toggleConfirmPasswordVisibility,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: _buildBorder(),
          enabledBorder: _buildBorder(),
          focusedBorder: _buildFocusedBorder(Get.theme.primaryColor),
          errorBorder: _buildErrorBorder(),
          focusedErrorBorder: _buildFocusedErrorBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onFieldSubmitted: (_) {
          if (_formKey.currentState!.validate()) {
            controller.signUp();
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          }
          if (value != controller.password) {
            return 'Passwords do not match';
          }
          return null;
        },
        onChanged: controller.setConfirmPassword,
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.showForgotPassword,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(50, 30),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
    );
  }

  OutlineInputBorder _buildFocusedBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 2),
    );
  }

  OutlineInputBorder _buildErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1),
    );
  }

  OutlineInputBorder _buildFocusedErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.red.shade700, width: 2),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Obx(() {
      String buttonText = '';
      VoidCallback? action;

      switch (controller.currentPage.value) {
        case 'login':
          buttonText = 'Login';
          action = () {
            if (_formKey.currentState!.validate()) {
              controller.login();
            }
          };
          break;
        case 'signup':
          buttonText = 'Sign Up';
          action = () {
            if (_formKey.currentState!.validate()) {
              controller.signUp();
            }
          };
          break;
        case 'forgot_password':
          buttonText = 'Send Reset Link';
          action = () {
            if (_formKey.currentState!.validate()) {
              controller.forgotPassword();
            }
          };
          break;
      }

      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : action,
          style: ElevatedButton.styleFrom(
            backgroundColor: Get.theme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBackgroundColor: Get.theme.primaryColor.withOpacity(0.5),
          ),
          child: controller.isLoading.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                )
              : Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildBottomLinks() {
    return Obx(() {
      switch (controller.currentPage.value) {
        case 'login':
          return Column(
            children: [
              _buildSignupLink(),
              Dimens.boxHeight10,
              const SizedBox.shrink(),
            ],
          );
        case 'signup':
          return Column(
            children: [
              _buildLoginLink(),
              Dimens.boxHeight10,
              _buildBackToLoginLink(),
            ],
          );
        case 'forgot_password':
          return _buildBackToLoginLink();
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        TextButton(
          onPressed: controller.showSignup,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Get.theme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        TextButton(
          onPressed: controller.showLogin,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Login',
            style: TextStyle(
              color: Get.theme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackToLoginLink() {
    return TextButton(
      onPressed: controller.showLogin,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        '← Back to Login',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}