import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RegistrationStepper extends StatelessWidget {
  final int currentStep;
  
  const RegistrationStepper({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final step = index + 1;
          final isActive = step == currentStep;
          final isCompleted = step < currentStep;
          final label = ["Profile", "Address", "Identity", "Compliance", "License", "Training", "Review"][index];
          
          return Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? Colors.transparent : (isCompleted ? AppColors.primaryGreen.withValues(alpha: 0.1) : AppColors.phoneFrameBg),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isActive || isCompleted) ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.2),
                    width: isActive ? 3 : 1,
                  ),
                  boxShadow: isActive ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 10)] : null,
                ),
                child: Center(
                  child: isCompleted 
                    ? const Icon(LucideIcons.check, size: 16, color: AppColors.primaryGreen)
                    : Text(
                        "$step",
                        style: TextStyle(
                          color: isActive ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.4),
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
