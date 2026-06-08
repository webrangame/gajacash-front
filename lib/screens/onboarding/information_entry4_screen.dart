import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';

import 'package:gajacash_sample/screens/onboarding/information_entry5_screen.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InformationEntry4Screen extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String email;

  const InformationEntry4Screen({
    super.key,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.email,
  });

  @override
  State<InformationEntry4Screen> createState() => _InformationEntry4ScreenState();
}

class _InformationEntry4ScreenState extends State<InformationEntry4Screen> {
  bool _isUploading = false;
  bool _isConfirmationVisible = false;
  bool _isSkipConfirmation = false;
  XFile? _capturedFile;     // local file picked by user
  String? _uploadedPhotoUrl; // remote URL after upload

  bool get _hasPhoto => _capturedFile != null;

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920);
    if (file == null || !mounted) return;
    setState(() {
      _capturedFile = file;
      _isUploading = true;
    });
    try {
      final response = await ApiService().uploadFile(file.path);
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        setState(() => _uploadedPhotoUrl = response.data['url'] as String?);
      }
    } catch (e) {
      debugPrint('Photo upload error: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildProgressBar(),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              "Verify your identity with a quick photo",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText, height: 1.2),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(LucideIcons.userX, "It won't be your profile picture."),
                            const SizedBox(height: 12),
                            _buildInfoRow(LucideIcons.shieldCheck, "Your photo is secure and only used for verification purposes."),
                            
                            const SizedBox(height: 48),
                            Center(child: _buildCameraViewfinder()),
                            const SizedBox(height: 120), // Space for sticky buttons
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom Buttons
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSkipConfirmation = true;
                              _isConfirmationVisible = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, offset: Offset(6, 6), blurRadius: 12),
                                BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Skip for now",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: "Continue",
                          onPressed: () {
                            setState(() {
                              _isSkipConfirmation = !_hasPhoto;
                              _isConfirmationVisible = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Backdrop and Confirmation Sheet
            if (_isConfirmationVisible) _buildBackdrop(),
            _buildConfirmationSheet(),
          ],
        ),
      ),
    );
  }


  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(height: 3, color: AppColors.primaryGreen.withValues(alpha: 0.1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) => _buildStep(index + 1, index == 3, index < 3)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step, bool active, bool completed) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: completed ? AppColors.primaryGreen : AppColors.phoneFrameBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: active || completed ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.3),
              width: active ? 3 : 2,
            ),
            boxShadow: active ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 15)] : null,
          ),
          child: Center(
            child: completed 
              ? const Icon(LucideIcons.check, color: Colors.white, size: 20)
              : Text(
                  "$step",
                  style: TextStyle(
                    color: active ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.6),
                    fontWeight: active ? FontWeight.w800 : FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          ["Profile", "Address", "Recovery", "Verify ID", "Set PIN"][step - 1],
          style: TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active || completed ? AppColors.primaryGreen : AppColors.primaryText.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryGreen.withValues(alpha: 0.6), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraViewfinder() {
    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            if (_hasPhoto && _capturedFile != null)
              Positioned.fill(
                child: _isUploading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : Image.file(File(_capturedFile!.path), fit: BoxFit.cover),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(LucideIcons.user, size: 120, color: AppColors.primaryGreen.withValues(alpha: 0.1)),
                        _buildViewfinderCorners(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Make sure your face is clearly visible, in good light, and not covered.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        // Show source picker then capture
                        final source = await showModalBottomSheet<ImageSource>(
                          context: context,
                          backgroundColor: AppColors.phoneFrameBg,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                          builder: (ctx) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Row(
                                children: [
                                  Expanded(child: _SourceOption(icon: LucideIcons.camera, label: 'Camera', onTap: () => Navigator.pop(ctx, ImageSource.camera))),
                                  const SizedBox(width: 16),
                                  Expanded(child: _SourceOption(icon: LucideIcons.images, label: 'Gallery', onTap: () => Navigator.pop(ctx, ImageSource.gallery))),
                                ],
                              ),
                            ),
                          ),
                        );
                        if (source != null) _pickPhoto(source);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.camera, size: 16, color: AppColors.primaryGreen),
                            SizedBox(width: 8),
                            Text("Take photo", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_hasPhoto)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFFFFCC66)),
                        SizedBox(width: 8),
                        Text("Ready for verification", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            
            if (_hasPhoto)
              Positioned(
                bottom: -60, // Relative to the viewfinder container, so we place it outside in the column
                child: Container(), // Dummy
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinderCorners() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, child: _corner(top: true, left: true)),
          Positioned(top: 0, right: 0, child: _corner(top: true, left: false)),
          Positioned(bottom: 0, left: 0, child: _corner(top: false, left: true)),
          Positioned(bottom: 0, right: 0, child: _corner(top: false, left: false)),
        ],
      ),
    );
  }

  Widget _corner({required bool top, required bool left}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 4) : BorderSide.none,
          bottom: !top ? BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 4) : BorderSide.none,
          left: left ? BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 4) : BorderSide.none,
          right: !left ? BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 4) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(12) : Radius.zero,
          topRight: top && !left ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(12) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    return GestureDetector(
      onTap: () => setState(() => _isConfirmationVisible = false),
      child: Container(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
    );
  }

  Widget _buildConfirmationSheet() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: _isConfirmationVisible ? 0 : -600,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.phoneFrameBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 24),
            Text(
              _isSkipConfirmation ? "Continue without a verification photo?" : "Confirm your verification photo",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 24),
            
            if (!_isSkipConfirmation && _capturedFile != null)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12)],
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: Image.file(
                    File(_capturedFile!.path),
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                  ),
                ),
              )
            else if (!_isSkipConfirmation)
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5FAF7),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12)],
                ),
                child: const Icon(LucideIcons.user, size: 40, color: AppColors.primaryGreen),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5FAF7),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12)],
                ),
                child: const Icon(LucideIcons.alertCircle, size: 40, color: Color(0xFFFB923C)),
              ),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FAF7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8)],
              ),
              child: Text(
                _isSkipConfirmation 
                    ? "You haven't taken a verification photo yet. You can skip this step for now, but we may ask you to verify your identity later."
                    : "We’ll use this photo only to verify your identity. It will not be shown as your profile picture.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isConfirmationVisible = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(32)),
                      child: const Center(child: Text("Go back", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    text: "Confirm",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InformationEntry5Screen(
                            phoneNumber: widget.phoneNumber,
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            gender: widget.gender,
                            dateOfBirth: widget.dateOfBirth,
                            addressLine1: widget.addressLine1,
                            addressLine2: widget.addressLine2,
                            city: widget.city,
                            email: widget.email,
                            idPhotoUrl: _uploadedPhotoUrl ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Simple source option tile used in the camera/gallery picker sheet
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
