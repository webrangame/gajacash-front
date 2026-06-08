import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final theme = Theme.of(context);

    // Resolve color settings from theme parameters
    final Color bgColor = backgroundColor ?? theme.colorScheme.secondary;
    final Color labelColor = textColor ?? theme.colorScheme.onSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isEnabled ? bgColor : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(
                    0xFFDBA326,
                  ).withValues(alpha: 0.3), // 0.3 opacity of #DBA326
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-6, -6),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onHover: (_) {}, // For mouse interaction
          onTap: onPressed,
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isEnabled
                    ? labelColor
                    : labelColor.withValues(alpha: 0.4),
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
