import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/core/upload_helper.dart';
import 'package:gajacash_sample/features/registration/widgets/registration_stepper.dart';
import 'package:gajacash_sample/features/registration/screens/license_screen.dart';
import 'package:gajacash_sample/features/registration/widgets/requirements_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ComplianceScreen extends StatefulWidget {
  final Map<String, dynamic> regData;
  const ComplianceScreen({super.key, required this.regData});

  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> {
  final _policeReportDateController = TextEditingController();
  final _cribReportDateController = TextEditingController();

  String? _policeCertUrl;
  String? _cribReportUrl;

  bool _uploadingPolice = false;
  bool _uploadingCrib = false;

  @override
  void initState() {
    super.initState();
    _policeCertUrl = widget.regData['police_certificate_url'];
    _cribReportUrl = widget.regData['crib_report_url'];
    _policeReportDateController.text = widget.regData['police_certificate_date_raw'] ?? '';
    _cribReportDateController.text = widget.regData['crib_report_date_raw'] ?? '';
  }

  String _formatToBackendDate(String input) {
    // Convert MM/DD/YYYY to YYYY-MM-DD
    final parts = input.split('/');
    if (parts.length == 3) {
      final month = parts[0].padLeft(2, '0');
      final day = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    }
    return input;
  }

  Future<void> _pickAndUpload(String fieldName) async {
    final labels = {
      'police_certificate_url': 'Police Certificate',
      'crib_report_url': 'CRIB Report',
    };
    final url = await pickAndUploadDocument(
      context,
      label: labels[fieldName] ?? 'Document',
      setLoading: (loading) {
        if (!mounted) return;
        setState(() {
          if (fieldName == 'police_certificate_url') _uploadingPolice = loading;
          if (fieldName == 'crib_report_url') _uploadingCrib = loading;
        });
      },
    );
    if (!mounted || url == null) return;
    setState(() {
      if (fieldName == 'police_certificate_url') _policeCertUrl = url;
      if (fieldName == 'crib_report_url') _cribReportUrl = url;
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
            const RegistrationStepper(currentStep: 4),
            
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
                            
                            // Police Report Section
                            _buildCardWithTitle(
                              "POLICE REPORT",
                              [
                                _buildLargeUploadBox(
                                  "Tap to upload or take photo",
                                  "police_certificate_url",
                                  () => _pickAndUpload("police_certificate_url"),
                                  _uploadingPolice,
                                  _policeCertUrl,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoContainer("Accepted: Police report from your nearest police station."),
                                const SizedBox(height: 20),
                                _buildLabel("Issue Date", isRequired: true),
                                _buildInputField(_policeReportDateController, placeholder: "MM/DD/YYYY", suffixIcon: LucideIcons.calendar),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // CRIB Report Section
                            _buildCardWithTitle(
                              "CRIB REPORT",
                              [
                                _buildLargeUploadBox(
                                  "Tap to upload or take photo",
                                  "crib_report_url",
                                  () => _pickAndUpload("crib_report_url"),
                                  _uploadingCrib,
                                  _cribReportUrl,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoContainer("Can be obtained through the CRIB department, through a request letter to your bank, or through www.crib.lk"),
                                const SizedBox(height: 20),
                                _buildLabel("Issue Date", isRequired: true),
                                _buildInputField(_cribReportDateController, placeholder: "MM/DD/YYYY", suffixIcon: LucideIcons.calendar),
                              ],
                            ),
                            
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

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          children: [
            if (isRequired)
              const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
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

  Widget _buildInfoContainer(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: AppColors.primaryGreen.withValues(alpha: 0.8), height: 1.4, fontWeight: FontWeight.w500),
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
                final policeRaw = _policeReportDateController.text.trim();
                final cribRaw = _cribReportDateController.text.trim();

                widget.regData['police_certificate_date_raw'] = policeRaw;
                widget.regData['crib_report_date_raw'] = cribRaw;

                widget.regData['police_certificate_date'] = _formatToBackendDate(policeRaw);
                widget.regData['crib_report_date'] = _formatToBackendDate(cribRaw);

                widget.regData['police_certificate_url'] = _policeCertUrl ?? '';
                widget.regData['crib_report_url'] = _cribReportUrl ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LicenseScreen(regData: widget.regData)),
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
