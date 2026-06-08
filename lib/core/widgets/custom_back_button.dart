import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CustomBackButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybeOf(context)?.pop(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: const [
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
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryGreen,
            size: 28,
          ),
        ),
      ),
    );
  }
}
