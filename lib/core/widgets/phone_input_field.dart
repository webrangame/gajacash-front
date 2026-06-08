import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gajacash_sample/core/theme.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String countryCode;
  final String flagAssetPath;
  final VoidCallback? onCountryCodeTap;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.hintText = "777-XXX-XXX",
    this.countryCode = "+94",
    this.flagAssetPath = "assets/images/flag_lk.png",
    this.onCountryCodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: context.neumorphic.clayShadowSmall,
      ),
      child: Row(
        children: [
          // Country Code Selector
          GestureDetector(
            onTap: onCountryCodeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.asset(
                      flagAssetPath,
                      width: 24,
                      height: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    countryCode,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          // TextField Input
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              inputFormatters: [PhoneInputFormatter()],
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black26),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final length = text.length;

    if (length == 0) {
      return const TextEditingValue();
    }

    final StringBuffer newText = StringBuffer();
    for (int i = 0; i < length && i < 9; i++) {
      if (i == 3 || i == 6) {
        newText.write('-');
      }
      newText.write(text[i]);
    }

    final String selectionText = newText.toString();
    return TextEditingValue(
      text: selectionText,
      selection: TextSelection.collapsed(offset: selectionText.length),
    );
  }
}
