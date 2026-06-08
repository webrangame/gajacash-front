import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/phone_entry_controller.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:gajacash_sample/core/widgets/custom_back_button.dart';
import 'package:gajacash_sample/core/widgets/speech_bubble.dart';
import 'package:gajacash_sample/core/widgets/phone_input_field.dart';
import 'package:gajacash_sample/core/constants/countries.dart';
import 'package:gajacash_sample/core/widgets/inset_neumorphic_container.dart';

class PhoneEntryScreen extends StatelessWidget {
  const PhoneEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PhoneEntryController());

    return Scaffold(
      backgroundColor: AppColors.phoneFrameBg,
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
    return Column(
      children: [
        const SpeechBubble(
          texts: [
            "If you already have an account, we’ll prompt you to log in. If not, we’ll guide you through a quick registration.",
            "Enter your mobile number to continue.",
          ],
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -16),
            child: Transform.scale(
              scale: 0.9,
              child: Image.asset(
                'assets/images/mascot.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    PhoneEntryController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mobile number",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Enter your mobile number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryGreen.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() => PhoneInputField(
          controller: controller.phoneController,
          countryCode: controller.selectedCountry.value.code,
          flagAssetPath: controller.selectedCountry.value.flagAsset,
          onCountryCodeTap: () => _showCountryPicker(context, controller),
        )),
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
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.0,
          ),
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
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Is this number correct?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll send you a confirmation code there",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                  controller.selectedCountry.value.code,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    letterSpacing: 0.5,
                  ),
                )),
                const SizedBox(width: 8),
                Text(
                  controller.phoneController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
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

  void _showCountryPicker(BuildContext context, PhoneEntryController controller) {
    final theme = Theme.of(context);
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filteredCountries = CountryData.countries.where((country) {
              final query = searchQuery.toLowerCase();
              return country.name.toLowerCase().contains(query) ||
                  country.code.contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
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
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Select Country",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InsetNeumorphicContainer(
                    borderRadius: 16,
                    height: 48,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search country name or code...",
                        hintStyle: TextStyle(
                          color: AppColors.primaryGreen.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primaryGreen.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredCountries.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        return Obx(() {
                          final isSelected = controller.selectedCountry.value.code == country.code;
                          return InkWell(
                            onTap: () {
                              controller.selectedCountry.value = country;
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen.withValues(alpha: 0.05)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: country.flagAsset.startsWith('http')
                                          ? Image.network(
                                              country.flagAsset,
                                              width: 32,
                                              height: 20,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey[300],
                                                width: 32,
                                                height: 20,
                                                alignment: Alignment.center,
                                                child: const Icon(Icons.flag, size: 12),
                                              ),
                                            )
                                          : Image.asset(
                                              country.flagAsset,
                                              width: 32,
                                              height: 20,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      country.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    country.code,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : AppColors.primaryText.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
