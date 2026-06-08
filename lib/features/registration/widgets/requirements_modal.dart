import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RequirementsModal extends StatelessWidget {
  final VoidCallback onClose;

  const RequirementsModal({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(0, -8), blurRadius: 16),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Requirements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    IconButton(onPressed: onClose, icon: const Icon(LucideIcons.x, color: AppColors.primaryGreen)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRequirementItem("Age 18 or above"),
                _buildRequirementItem("Valid National Identity Card (NIC)"),
                _buildRequirementItem("Recent police clearance certificate (< 6 months)"),
                _buildRequirementItem("Recent CRIB report (< 6 months)"),
                _buildRequirementItem("Valid driving licence"),
                _buildRequirementItem("Proof of residential address"),
                _buildRequirementItem("Willingness to complete training & sign agreement"),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.primaryText, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// Function to show the modal
void showRequirementsModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => RequirementsModal(onClose: () => Navigator.pop(context)),
  );
}
