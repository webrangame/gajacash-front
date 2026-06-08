import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/core/upload_helper.dart';
import 'package:gajacash_sample/features/registration/widgets/registration_stepper.dart';
import 'package:gajacash_sample/features/registration/screens/training_screen.dart';
import 'package:gajacash_sample/features/registration/widgets/requirements_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LicenseScreen extends StatefulWidget {
  final Map<String, dynamic> regData;
  const LicenseScreen({super.key, required this.regData});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _expiryDateController = TextEditingController();
  final _licenceNumberController = TextEditingController();
  final _pvNumberController = TextEditingController();
  String? _selectedVehicle;

  String? _licenceFrontUrl;
  String? _licenceBackUrl;
  String? _regCertUrl;
  String? _premisesPhotoUrl;

  bool _uploadingFront = false;
  bool _uploadingBack = false;
  bool _uploadingCert = false;
  bool _uploadingPremises = false;

  @override
  void initState() {
    super.initState();
    _pvNumberController.text = widget.regData['pv_number'] ?? '';
    _licenceNumberController.text = widget.regData['driving_licence_number'] ?? '';
    _expiryDateController.text = widget.regData['driving_licence_expiry_raw'] ?? '';
    _selectedVehicle = widget.regData['vehicle_type'];
    _licenceFrontUrl = widget.regData['driving_licence_front_url'];
    _licenceBackUrl = widget.regData['driving_licence_back_url'];
    _regCertUrl = widget.regData['registration_certificate_url'];
    _premisesPhotoUrl = widget.regData['business_premises_photo_url'];
  }

  Future<void> _pickAndUpload(String fieldName) async {
    final labels = {
      'driving_licence_front_url': 'Licence Front',
      'driving_licence_back_url': 'Licence Back',
      'registration_certificate_url': 'BR Certificate',
      'business_premises_photo_url': 'Premises Photo',
    };
    final url = await pickAndUploadDocument(
      context,
      label: labels[fieldName] ?? 'Document',
      setLoading: (loading) {
        if (!mounted) return;
        setState(() {
          if (fieldName == 'driving_licence_front_url') _uploadingFront = loading;
          if (fieldName == 'driving_licence_back_url') _uploadingBack = loading;
          if (fieldName == 'registration_certificate_url') _uploadingCert = loading;
          if (fieldName == 'business_premises_photo_url') _uploadingPremises = loading;
        });
      },
    );
    if (!mounted || url == null) return;
    setState(() {
      if (fieldName == 'driving_licence_front_url') _licenceFrontUrl = url;
      if (fieldName == 'driving_licence_back_url') _licenceBackUrl = url;
      if (fieldName == 'registration_certificate_url') _regCertUrl = url;
      if (fieldName == 'business_premises_photo_url') _premisesPhotoUrl = url;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploaded successfully!'), backgroundColor: AppColors.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = widget.regData['agent_type'] == 'VENDOR_AGENT';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepper(currentStep: 5),
            
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
                            _buildMascotSection(),
                            const SizedBox(height: 32),
                            
                            if (isVendor) ...[
                              // Vendor business details
                              _buildCardWithTitle(
                                "BUSINESS DETAILS",
                                [
                                  _buildLabel("PV Number (Business Registration)", isRequired: true),
                                  _buildInputField(_pvNumberController, placeholder: "Eg: PV-123456"),
                                  const SizedBox(height: 24),
                                  _buildLabel("BR Certificate", isRequired: true),
                                  _buildLargeUploadBox(
                                    "Upload Business Registration",
                                    "registration_certificate_url",
                                    () => _pickAndUpload("registration_certificate_url"),
                                    _uploadingCert,
                                    _regCertUrl,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildLabel("Business Premises Photo", isRequired: true),
                                  _buildLargeUploadBox(
                                    "Upload premises photo",
                                    "business_premises_photo_url",
                                    () => _pickAndUpload("business_premises_photo_url"),
                                    _uploadingPremises,
                                    _premisesPhotoUrl,
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Delivery license & vehicle
                              _buildCardWithTitle(
                                "DRIVING LICENSE & VEHICLE",
                                [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildUploadBox(
                                          "Front Side",
                                          "driving_licence_front_url",
                                          () => _pickAndUpload("driving_licence_front_url"),
                                          _uploadingFront,
                                          _licenceFrontUrl,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildUploadBox(
                                          "Back Side",
                                          "driving_licence_back_url",
                                          () => _pickAndUpload("driving_licence_back_url"),
                                          _uploadingBack,
                                          _licenceBackUrl,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  _buildLabel("Driving License Number", isRequired: true),
                                  _buildInputField(_licenceNumberController, placeholder: "Eg: B1234567"),
                                  const SizedBox(height: 20),
                                  _buildLabel("License Expiry Date", isRequired: true),
                                  _buildInputField(_expiryDateController, placeholder: "MM/DD/YYYY", suffixIcon: LucideIcons.calendar),
                                  const SizedBox(height: 12),
                                  _buildInfoText("Accepted: A valid driving license."),
                                  const SizedBox(height: 24),
                                  _buildLabel("Vehicle Type", isOptional: true),
                                  _buildVehicleDropdown(),
                                ],
                              ),
                            ],
                            
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
                  "Confirm Your Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
                Text(
                  "We use these details in your agent contract and for verification.",
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWithTitle(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
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

  Widget _buildLabel(String text, {bool isRequired = false, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          children: [
            if (isRequired)
              const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
            if (isOptional)
              TextSpan(text: " (Optional)", style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.5), fontWeight: FontWeight.normal, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, {IconData? suffixIcon, String? placeholder}) {
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
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.primaryGreen, size: 20) : null,
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
                        Text("Uploaded Successfully", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _uploadIcon(LucideIcons.upload),
                            const SizedBox(width: 16),
                            _uploadIcon(LucideIcons.camera),
                          ],
                        ),
                        const SizedBox(height: 12),
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
    return Text(
      text,
      style: TextStyle(fontSize: 11, color: AppColors.primaryGreen.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
    );
  }

  Widget _buildVehicleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(2, 2), blurRadius: 4),
          const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicle,
          isExpanded: true,
          hint: Text("Select Vehicle Type", style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.3), fontWeight: FontWeight.normal)),
          icon: const Icon(LucideIcons.chevronDown, color: AppColors.primaryGreen, size: 20),
          items: ["Bike", "Bicycle", "Tuk Tuk", "Car", "Other"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedVehicle = val),
        ),
      ),
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
                final isVendor = widget.regData['agent_type'] == 'VENDOR_AGENT';
                if (isVendor) {
                  widget.regData['pv_number'] = _pvNumberController.text.trim();
                  widget.regData['registration_certificate_url'] = _regCertUrl ?? '';
                  widget.regData['business_premises_photo_url'] = _premisesPhotoUrl ?? '';
                } else {
                  widget.regData['driving_licence_number'] = _licenceNumberController.text.trim();
                  widget.regData['driving_licence_expiry_raw'] = _expiryDateController.text.trim();
                  widget.regData['driving_licence_front_url'] = _licenceFrontUrl ?? '';
                  widget.regData['driving_licence_back_url'] = _licenceBackUrl ?? '';
                  widget.regData['vehicle_type'] = _selectedVehicle ?? '';
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainingScreen(regData: widget.regData)),
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
