import 'dart:io';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/widgets/requirements_modal.dart';
import 'package:gajacash_sample/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/widgets/registration_stepper.dart';
import 'package:gajacash_sample/screens/registration/identity_verification_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AgentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> regData;
  const AgentDetailsScreen({super.key, required this.regData});

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen> {
  final _firstNameController = TextEditingController(text: "Kasun");
  final _lastNameController = TextEditingController(text: "Perera");
  final _dobController = TextEditingController(text: "06/15/1994");
  final _mobileController = TextEditingController();
  final _address1Controller = TextEditingController(text: "42 Galle Road");
  final _address2Controller = TextEditingController(text: "Dehiwala");
  final _cityController = TextEditingController(text: "Colombo");
  String _selectedCountry = "Sri Lanka";

  // Profile photo
  XFile? _profileImageFile;
  String? _profilePhotoUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill mobile from registration data or logged-in user
    _mobileController.text = widget.regData['phone'] as String? ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (file == null || !mounted) return;
    setState(() {
      _profileImageFile = file;
      _isUploadingPhoto = true;
    });
    try {
      final response = await ApiService().uploadFile(file.path);
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        setState(() => _profilePhotoUrl = response.data['url'] as String?);
      }
    } catch (e) {
      debugPrint('Profile photo upload error: $e');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.phoneFrameBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Upload Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _sourceButton(
                      icon: LucideIcons.camera,
                      label: "Camera",
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickProfilePhoto(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _sourceButton(
                      icon: LucideIcons.image,
                      label: "Gallery",
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickProfilePhoto(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12),
            BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepper(currentStep: 2),
            
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
                            const SizedBox(height: 28),

                            // ── Profile Photo ──────────────────────────
                            Center(child: _buildProfilePhotoUpload()),
                            const SizedBox(height: 28),

                            // ── Personal Fields ────────────────────────
                            _buildLabel("First name", isRequired: true),
                            _buildInputField(_firstNameController),
                            const SizedBox(height: 20),

                            _buildLabel("Last name", isRequired: true),
                            _buildInputField(_lastNameController),
                            const SizedBox(height: 20),

                            _buildLabel("Mobile number", isRequired: true),
                            _buildInputField(
                              _mobileController,
                              keyboardType: TextInputType.phone,
                              prefixIcon: LucideIcons.phone,
                              placeholder: "e.g. 94771234567",
                            ),
                            const SizedBox(height: 20),

                            _buildLabel("Date of birth", isRequired: true),
                            _buildInputField(_dobController, suffixIcon: LucideIcons.calendar),
                            const SizedBox(height: 20),

                            _buildLabel("Address line 1", isRequired: true),
                            _buildInputField(_address1Controller),
                            const SizedBox(height: 20),

                            _buildLabel("Address line 2", isOptional: true),
                            _buildInputField(_address2Controller, placeholder: "Apartment, floor, landmark"),
                            const SizedBox(height: 20),

                            _buildLabel("City / Town", isRequired: true),
                            _buildInputField(_cityController),
                            const SizedBox(height: 20),

                            _buildLabel("Country", isRequired: true),
                            _buildCountryDropdown(),

                            const SizedBox(height: 120),
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

  // ── Profile Photo Upload Widget ────────────────────────────────────────────
  Widget _buildProfilePhotoUpload() {
    return GestureDetector(
      onTap: _showPhotoSourceSheet,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.phoneFrameBg,
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              ],
            ),
            child: ClipOval(
              child: _isUploadingPhoto
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : _profileImageFile != null
                      ? Image.file(File(_profileImageFile!.path), fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.user, color: AppColors.primaryGreen.withValues(alpha: 0.4), size: 36),
                            const SizedBox(height: 4),
                            Text(
                              "Photo",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryGreen.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          // Camera badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _profilePhotoUrl != null ? Colors.green : AppColors.primaryGreen,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(
              _profilePhotoUrl != null ? LucideIcons.check : LucideIcons.camera,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mascot Section ─────────────────────────────────────────────────────────
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
          SafeNetworkImage(
            url: 'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/46988f10-aac0-46de-95d1-0dea926ebd5e_800w.png?w=800&q=80',
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

  // ── Helpers ────────────────────────────────────────────────────────────────
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
              TextSpan(
                text: " (Optional)",
                style: TextStyle(
                  color: AppColors.primaryGreen.withValues(alpha: 0.5),
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller, {
    IconData? suffixIcon,
    IconData? prefixIcon,
    String? placeholder,
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.3), fontWeight: FontWeight.normal),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryGreen, size: 20) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.primaryGreen, size: 20) : null,
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
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
          value: _selectedCountry,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, color: AppColors.primaryGreen, size: 20),
          items: ["Sri Lanka", "India", "Japan"].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCountry = val!),
        ),
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
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
                widget.regData['first_name'] = _firstNameController.text.trim();
                widget.regData['last_name'] = _lastNameController.text.trim();
                widget.regData['phone'] = _mobileController.text.trim();
                widget.regData['date_of_birth'] = _dobController.text.trim();
                widget.regData['address_line1'] = _address1Controller.text.trim();
                widget.regData['address_line2'] = _address2Controller.text.trim();
                widget.regData['city'] = _cityController.text.trim();
                widget.regData['country'] = _selectedCountry;
                if (_profilePhotoUrl != null) {
                  widget.regData['profile_photo_url'] = _profilePhotoUrl;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IdentityVerificationScreen(regData: widget.regData)),
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
