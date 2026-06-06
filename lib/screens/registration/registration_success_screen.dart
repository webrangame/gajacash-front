import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/registration/application_status_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Submission Success",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large Success Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
                        ],
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.check, size: 64, color: AppColors.primaryGreen),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    const Text(
                      "Application Submitted!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      "Your application is being reviewed. This usually takes 2–5 business days.",
                      style: TextStyle(fontSize: 14, color: AppColors.primaryGreen.withValues(alpha: 0.7), height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "We'll notify you in the app and via SMS when your status changes.",
                      style: TextStyle(fontSize: 14, color: AppColors.primaryGreen.withValues(alpha: 0.7), height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Status Hint Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "You can check your application status at any time.",
                        style: TextStyle(fontSize: 12, color: AppColors.primaryGreen.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            _buildBottomNav(context),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          _navIconButton(LucideIcons.chevronLeft, onTap: () => Navigator.pop(context)),
          const SizedBox(width: 8),
          _navIconButton(LucideIcons.pieChart),
          const SizedBox(width: 8),
          _navIconButton(LucideIcons.arrowUpDown, isPrimary: true),
          const Expanded(child: SizedBox()),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ApplicationStatusScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCC66),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _navIconButton(IconData icon, {VoidCallback? onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : AppColors.primaryGreen, size: 22),
      ),
    );
  }
}
