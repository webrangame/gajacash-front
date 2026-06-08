import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/core/upload_helper.dart';
import 'package:gajacash_sample/widgets/registration_stepper.dart';
import 'package:gajacash_sample/screens/registration/compliance_screen.dart';
import 'package:gajacash_sample/widgets/requirements_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class IdentityVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> regData;
  const IdentityVerificationScreen({super.key, required this.regData});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  final _nicController = TextEditingController();
  bool _addressMatches = false;

  String? _nicFrontUrl;
  String? _nicBackUrl;
  String? _proofOfAddressUrl;

  bool _uploadingNicFront = false;
  bool _uploadingNicBack = false;
  bool _uploadingAddress = false;

  @override
  void initState() {
    super.initState();
    _nicController.text = widget.regData['nic_number'] ?? '';
    _nicFrontUrl = widget.regData['nic_photo_front_url'];
    _nicBackUrl = widget.regData['nic_photo_back_url'];
    _proofOfAddressUrl = widget.regData['proof_of_address_url'];
  }

  Future<void> _pickAndUpload(String fieldName) async {
    final labels = {
      'nic_photo_front_url': 'NIC Front',
      'nic_photo_back_url': 'NIC Back',
      'proof_of_address_url': 'Proof of Address',
    };
    final url = await pickAndUploadDocument(
      context,
      label: labels[fieldName] ?? 'Document',
      setLoading: (loading) {
        if (!mounted) return;
        setState(() {
          if (fieldName == 'nic_photo_front_url') _uploadingNicFront = loading;
          if (fieldName == 'nic_photo_back_url') _uploadingNicBack = loading;
          if (fieldName == 'proof_of_address_url') _uploadingAddress = loading;
        });
      },
    );
    if (!mounted || url == null) return;
    setState(() {
      if (fieldName == 'nic_photo_front_url') _nicFrontUrl = url;
      if (fieldName == 'nic_photo_back_url') _nicBackUrl = url;
      if (fieldName == 'proof_of_address_url') _proofOfAddressUrl = url;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploaded successfully!'), backgroundColor: AppColors.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepper(currentStep: 3),
            
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
                            const SizedBox(height: 24),
                            
                            // NIC Section
                            _buildSectionHeader("NIC NUMBER"),
                            _buildInputField(_nicController, placeholder: "Eg: 199012345678"),
                            const SizedBox(height: 20),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildUploadBox(
                                    "Front Side",
                                    "nic_photo_front_url",
                                    () => _pickAndUpload("nic_photo_front_url"),
                                    _uploadingNicFront,
                                    _nicFrontUrl,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildUploadBox(
                                    "Back Side",
                                    "nic_photo_back_url",
                                    () => _pickAndUpload("nic_photo_back_url"),
                                    _uploadingNicBack,
                                    _nicBackUrl,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Proof of Address Section
                            _buildSectionHeader("PROOF OF ADDRESS"),
                            _buildLargeUploadBox(
                              "Upload Document",
                              "proof_of_address_url",
                              () => _pickAndUpload("proof_of_address_url"),
                              _uploadingAddress,
                              _proofOfAddressUrl,
                            ),
                            
                            const SizedBox(height: 16),
                            _buildInfoText(
                                "Accepted: Utility bill/Bank statement (dated less than 3 months) or letter from Grama Niladhari / local authority. Must match address in profile."),
                            
                            const SizedBox(height: 16),
                            _buildCheckboxRow("Address on document matches profile?"),
                            
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


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, {String? placeholder}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(2, 2), blurRadius: 4),
          const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.3), fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildUploadBox(String label, String fieldName, VoidCallback onTap, bool isUploading, String? uploadedUrl) {
    return Column(
      children: [
        GestureDetector(
          onTap: isUploading ? null : onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: uploadedUrl != null ? Colors.green.withValues(alpha: 0.5) : AppColors.primaryGreen.withValues(alpha: 0.2),
                style: BorderStyle.solid,
                width: uploadedUrl != null ? 2 : 1,
              ),
            ),
            child: Center(
              child: isUploading
                  ? const CircularProgressIndicator(color: AppColors.primaryGreen)
                  : (uploadedUrl != null
                      ? const Icon(LucideIcons.checkCircle, color: Colors.green, size: 36)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _uploadIcon(LucideIcons.upload),
                            const SizedBox(width: 12),
                            _uploadIcon(LucideIcons.camera),
                          ],
                        )),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          uploadedUrl != null ? "Uploaded" : label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: uploadedUrl != null ? Colors.green : AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildLargeUploadBox(String label, String fieldName, VoidCallback onTap, bool isUploading, String? uploadedUrl) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.phoneFrameBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploadedUrl != null ? Colors.green.withValues(alpha: 0.5) : AppColors.primaryGreen.withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: uploadedUrl != null ? 2 : 1,
          ),
        ),
        child: Center(
          child: isUploading
              ? const CircularProgressIndicator(color: AppColors.primaryGreen)
              : (uploadedUrl != null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.checkCircle, color: Colors.green, size: 40),
                        SizedBox(height: 8),
                        Text("Proof of address uploaded", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _uploadIcon(LucideIcons.upload),
                        const SizedBox(width: 16),
                        _uploadIcon(LucideIcons.camera),
                        const SizedBox(width: 16),
                        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                      ],
                    )),
        ),
      ),
    );
  }

  Widget _uploadIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(2, 2), blurRadius: 4),
          const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
        ],
      ),
      child: Icon(icon, size: 20, color: AppColors.primaryGreen),
    );
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: AppColors.primaryGreen.withValues(alpha: 0.8), height: 1.4),
      ),
    );
  }

  Widget _buildCheckboxRow(String text) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _addressMatches = !_addressMatches),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _addressMatches ? AppColors.primaryGreen : AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
            ),
            child: _addressMatches ? const Icon(LucideIcons.check, size: 18, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
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
              onPressed: () {
                widget.regData['nic_number'] = _nicController.text.trim();
                widget.regData['nic_photo_front_url'] = _nicFrontUrl ?? '';
                widget.regData['nic_photo_back_url'] = _nicBackUrl ?? '';
                widget.regData['proof_of_address_url'] = _proofOfAddressUrl ?? '';
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplianceScreen(regData: widget.regData)),
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
