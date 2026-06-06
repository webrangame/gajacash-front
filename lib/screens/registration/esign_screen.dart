import 'package:gajacash_sample/widgets/safe_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/registration/registration_success_screen.dart';
import 'package:gajacash_sample/widgets/requirements_modal.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ESignScreen extends StatefulWidget {
  final Map<String, dynamic> regData;
  const ESignScreen({super.key, required this.regData});

  @override
  State<ESignScreen> createState() => _ESignScreenState();
}

class _ESignScreenState extends State<ESignScreen> {
  bool _agreed = false;
  String _signatureType = "Type";
  final TextEditingController _nameController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.regData['signature_name'] ?? '';
  }

  Future<void> _submitKYC() async {
    setState(() => _submitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      // 1. Build a dummy signed-agreement text file and upload it
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/signed_agreement.txt');
      await tempFile.writeAsString(
          'Signed by: ${_nameController.text}\nDate: ${DateTime.now().toIso8601String()}');

      final uploadResponse = await ApiService().uploadFile(tempFile.path);
      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 201) {
        widget.regData['signed_agreement_url'] =
            uploadResponse.data['url'] as String? ?? '';
      } else {
        // Fallback: use production URL so it isn't localhost
        widget.regData['signed_agreement_url'] =
            '${ApiService.baseUrl}/uploads/signed_agreement_placeholder.txt';
      }

      // 2. Submit the full KYC payload
      final response = await ApiService().createAgentKYC(widget.regData);

      if (mounted) {
        Navigator.pop(context); // pop loader
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const RegistrationSuccessScreen()),
          );
        } else {
          final errMsg = response.data is Map
              ? (response.data['error'] ?? 'Registration failed')
              : 'Registration failed (${response.statusCode})';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errMsg.toString()),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission error: $e'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Agreement & E-Sign",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ),
            
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildMascotSection(),
                            const SizedBox(height: 32),
                            
                            _buildLabel("Signed Agreement", isRequired: true),
                            _buildAgreementBox(),
                            
                            const SizedBox(height: 20),
                            _buildCheckboxSection(),
                            
                            const SizedBox(height: 32),
                            _buildSignatureSection(),
                            
                            const SizedBox(height: 120), // Space for bottom nav
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomNav(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMascotSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          SafeNetworkImage(url:
            'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/46988f10-aac0-46de-95d1-0dea926ebd5e_800w.png?w=800&q=80',
            width: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Our Terms & Conditions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
                Text(
                  "Review the agreement and sign to confirm.",
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          if (isRequired) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text("MANDATORY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAgreementBox() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: const SingleChildScrollView(
        child: Text(
          "The Company hereby appoints the Agent as a non-exclusive authorized agent to perform the Services set forth in this Agreement. The Agent accepts such appointment and agrees to act in accordance with the terms herein.\n\nThe Agent agrees to comply with all applicable laws, regulations, and Company policies. The Agent shall maintain confidentiality of all proprietary information and customer data.\n\nEither party may terminate this Agreement with 30 days written notice. Immediate termination may occur for any breach of material terms.\n\nThe Agent agrees to indemnify and hold the Company harmless from any claims, losses, or damages arising from the Agent's performance or breach of this Agreement.",
          style: TextStyle(fontSize: 13, color: AppColors.primaryGreen, height: 1.5),
        ),
      ),
    );
  }

  Widget _buildCheckboxSection() {
    return GestureDetector(
      onTap: () => setState(() => _agreed = !_agreed),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _agreed ? AppColors.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
            ),
            child: _agreed ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "I have read and agree to the Terms & Conditions above.",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Signature", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            Container(
              decoration: BoxDecoration(
                color: AppColors.phoneFrameBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _toggleButton("Type"),
                  _toggleButton("Draw"),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.phoneFrameBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(2, 2), blurRadius: 4),
              const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
            ],
          ),
          child: TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            decoration: InputDecoration(
              hintText: "Type your full legal name",
              hintStyle: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.3), fontWeight: FontWeight.normal),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
            ),
            onChanged: (val) {
              widget.regData['signature_name'] = val;
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "By typing your name, you agree this constitutes a legal signature.",
          style: TextStyle(fontSize: 10, color: AppColors.primaryGreen.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _toggleButton(String label) {
    bool isSelected = _signatureType == label;
    return GestureDetector(
      onTap: () => setState(() => _signatureType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(2, 2), blurRadius: 4),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final canSubmit = _agreed && _nameController.text.trim().isNotEmpty && !_submitting;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
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
            _navIconButton(LucideIcons.arrowUpDown, isPrimary: true, onTap: () => showRequirementsModal(context)),
            const Expanded(child: SizedBox()),
            ElevatedButton(
              onPressed: canSubmit ? _submitKYC : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC66),
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFFFFCC66).withValues(alpha: 0.5),
                disabledForegroundColor: Colors.black.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
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
