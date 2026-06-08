import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gajacash_sample/features/onboarding/phone_entry_controller.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:gajacash_sample/core/widgets/custom_back_button.dart';
import 'package:gajacash_sample/core/widgets/mascot_bubble.dart';
import 'package:gajacash_sample/core/widgets/phone_input_field.dart';

class PhoneEntryScreen extends StatelessWidget {
  const PhoneEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhoneEntryController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Row(children: [const CustomBackButton()]),
                          ),

                          // Mascot bubble takes remaining space to push input and button to bottom
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: _buildMascotSection(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Form & Button Group at the bottom
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFormSection(context, controller),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  text: "Continue",
                                  onPressed: () {
                                    final phone = controller
                                        .phoneController
                                        .text
                                        .replaceAll(RegExp(r'\D'), '');
                                    if (phone.length >= 7) {
                                      controller.showConfirmation();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please enter a valid phone number (at least 7 digits)",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Backdrop and Confirmation Sheet
            Obx(
              () => controller.isConfirmationVisible.value
                  ? _buildBackdrop(context, controller)
                  : const SizedBox.shrink(),
            ),
            Obx(() => _buildConfirmationSheet(context, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotSection() {
    return const MascotBubble(
      messages: [
        "If you already have an account, we’ll prompt you to log in. If not, we’ll guide you through a quick registration.",
        "Enter your mobile number to continue.",
      ],
      mascotWidth: 170,
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    PhoneEntryController controller,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mobile number",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Enter your mobile number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        PhoneInputField(controller: controller.phoneController),
      ],
    );
  }

  Widget _buildBackdrop(BuildContext context, PhoneEntryController controller) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => controller.hideConfirmation(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: controller.isConfirmationVisible.value ? 1.0 : 0.0,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
            child: Container(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationSheet(
    BuildContext context,
    PhoneEntryController controller,
  ) {
    final theme = Theme.of(context);
    final isVisible = controller.isConfirmationVisible.value;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: isVisible ? 0 : -400,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 30,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Is this number correct?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "We'll send you a confirmation code there",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "+94 ",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  controller.phoneController.text,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "Confirm",
              onPressed: () =>
                  controller.sendOtp(context, theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: "Go back",
              backgroundColor: const Color(0xFFD9D9D9),
              textColor: const Color(0xFF1F1D1B),
              onPressed: () => controller.hideConfirmation(),
            ),
          ],
        ),
      ),
    );
  }
}
