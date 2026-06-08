import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/features/onboarding/screens/verification_code_screen.dart';

class PhoneEntryController extends GetxController {
  final phoneController = TextEditingController();
  final isConfirmationVisible = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void showConfirmation() {
    isConfirmationVisible.value = true;
  }

  void hideConfirmation() {
    isConfirmationVisible.value = false;
  }

  Future<void> sendOtp(BuildContext context, Color primaryColor) async {
    var cleanPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }
    if (!cleanPhone.startsWith('94')) {
      cleanPhone = '94$cleanPhone';
    }
    final phone = cleanPhone;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );

    try {
      final response = await ApiService().sendOtp(phone);
      if (context.mounted) {
        Navigator.pop(context); // Pop loader
        if (response.statusCode == 200) {
          Get.to(() => VerificationCodeScreen(phoneNumber: phone));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to send OTP code"),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send SMS: ${e.toString()}"),
          ),
        );
      }
    }
  }
}
