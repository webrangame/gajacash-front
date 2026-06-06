import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';

class LanguageCard extends StatelessWidget {
  final String title;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.title,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.background,
          borderRadius: BorderRadius.circular(40),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    offset: const Offset(8, 8),
                    blurRadius: 20,
                  ),
                  const BoxShadow(
                    color: Colors.white24,
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                  const BoxShadow(
                    color: Colors.black26,
                    offset: Offset(-4, -4),
                    blurRadius: 8,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: AppColors.clayShadowColor,
                    offset: Offset(8, 8),
                    blurRadius: 16,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-8, -8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.1) : AppColors.phoneFrameBg,
                shape: BoxShape.circle,
                boxShadow: !isSelected
                    ? [
                        const BoxShadow(
                          color: AppColors.clayShadowColor,
                          offset: Offset(4, 4),
                          blurRadius: 8,
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 8,
                        ),
                      ]
                    : [
                        const BoxShadow(
                          color: Colors.white30,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
              ),
              child: Center(
                child: icon ??
                    Text(
                      title[0], // fallback or logic for character representations
                      style: TextStyle(
                        fontSize: 30,
                        color: isSelected ? Colors.white : AppColors.primaryGreen,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.primaryText,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
