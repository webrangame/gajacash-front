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

    // Generate lighter highlight color for gradient (20% white mix)
    final Color highlightColor =
        Color.lerp(bgColor, Colors.white, 0.2) ?? bgColor;
    // Generate natural shadow color (15% black mix, 30% opacity)
    final Color shadowColor =
        Color.lerp(bgColor, Colors.black, 0.15)?.withValues(alpha: 0.3) ??
        const Color(0xFFDBA326).withValues(alpha: 0.3);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: isEnabled
            ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.0)
            : null,
        color: isEnabled ? null : const Color(0xFFD9D9D9),
        gradient: isEnabled
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [highlightColor, bgColor],
              )
            : null,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: shadowColor,
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
                fontWeight: FontWeight
                    .w500, //Semi-bold for a premium, readable look matching the image
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
