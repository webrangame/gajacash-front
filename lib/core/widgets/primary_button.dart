import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = const Color(0xFFFFCC66),
    this.textColor = const Color(0xFF1F1D1B),
  });

  @override
  Widget build(BuildContext context) {
    bool isEnabled = onPressed != null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isEnabled ? backgroundColor : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: isEnabled ? [
          const BoxShadow(
            color: Color(0x4DDBA326), // 0.3 opacity of #DBA326
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
        ] : null,
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
                color: isEnabled ? textColor : textColor.withValues(alpha: 0.4),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
