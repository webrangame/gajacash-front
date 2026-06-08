import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/core/widgets/inset_neumorphic_container.dart';
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
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _isFocused = _focusNode.hasFocus;
  }

  @override
  void didUpdateWidget(covariant PhoneInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      _focusNode.removeListener(_onFocusChange);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
      _isFocused = _focusNode.hasFocus;
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InsetNeumorphicContainer(
      borderRadius: 24,
      isFocused: _isFocused,
      height: 64,
      color: AppColors.phoneFrameBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Country Code Selector Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onCountryCodeTap,
                hoverColor: AppColors.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
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
                          child: widget.flagAssetPath.startsWith('http')
                              ? Image.network(
                                  widget.flagAssetPath,
                                  width: 24,
                                  height: 16,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[300],
                                    width: 24,
                                    height: 16,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.flag, size: 12),
                                  ),
                                )
                              : Image.asset(
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
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: AppColors.primaryGreen.withValues(alpha: 0.60),
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
                  color: AppColors.primaryText,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
                inputFormatters: [PhoneInputFormatter()],
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
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
