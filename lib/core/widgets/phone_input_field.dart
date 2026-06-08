import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String countryCode;
  final String flagAssetPath;
  final VoidCallback? onCountryCodeTap;
  final FocusNode? focusNode;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.hintText = "777-XXX-XXX",
    this.countryCode = "+94",
    this.flagAssetPath = "assets/images/flag_lk.png",
    this.onCountryCodeTap,
    this.focusNode,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE0E0E0), Colors.white],
        ),
      ),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 250, 249),
          borderRadius: BorderRadius.circular(24),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha: 0.05),
          //     blurRadius: 4,
          //     offset: const Offset(-2, -2),
          //   ),
          // ],
          // border: Border.all(
          //   color: _isFocused
          //       ? const Color(0xFF006633).withValues(alpha: 0.2)
          //       : Colors.transparent,
          //   width: 1.0,
          // ),
          // gradient: const LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     Color(0xFFC5D1CB), // Simulated inset shadow (top-left) - #c5d1cb
          //     Color(0xFFE8F4ED), // Main background - #E8F4ED
          //     Color(0xFFFFFFFF), // Simulated inset reflection (bottom-right) - #ffffff
          //   ],
          //   stops: [0.0, 0.15, 1.0],
          // ),
        ),
        child: Row(
          children: [
            // Country Code Selector Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onCountryCodeTap,
                hoverColor: const Color(0xFF006633).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: const Color(0xFF006633).withValues(alpha: 0.1),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                          child: Image.asset(
                            widget.flagAssetPath,
                            width: 24,
                            height: 16,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.countryCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F1D1B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: const Color(0xFF006633).withValues(alpha: 0.60),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // TextField Input
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1D1B),
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
                inputFormatters: [PhoneInputFormatter()],
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: const Color(0xFF006633).withValues(alpha: 0.3),
                    fontFamily: 'monospace',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
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
