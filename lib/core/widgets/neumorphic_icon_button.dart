import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A reusable Neumorphic/Claymorphic icon button conforming to SOLID principles.
/// 
/// Responsibility: Renders a round neumorphic button with custom shadow, size,
/// background, and icon properties.
class NeumorphicIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final List<BoxShadow>? customShadows;

  const NeumorphicIconButton({
    super.key,
    this.icon = LucideIcons.chevronLeft,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
    this.iconSize = 28,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedBg = backgroundColor ?? theme.colorScheme.surface;
    final resolvedIconColor = iconColor ?? theme.colorScheme.primary;

    // Default Neumorphic outer shadow definition
    final shadows = customShadows ?? const [
      BoxShadow(
        color: AppColors.clayShadowColor,
        offset: Offset(6, 6),
        blurRadius: 12,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(-6, -6),
        blurRadius: 12,
      ),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: resolvedBg,
          shape: BoxShape.circle,
          boxShadow: shadows,
        ),
        child: Center(
          child: Icon(
            icon,
            color: resolvedIconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
