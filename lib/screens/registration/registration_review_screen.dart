import 'package:gajacash_sample/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/widgets/registration_stepper.dart';
import 'package:gajacash_sample/widgets/requirements_modal.dart';
import 'package:gajacash_sample/screens/registration/esign_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegistrationReviewScreen extends StatefulWidget {
  final Map<String, dynamic> regData;
  const RegistrationReviewScreen({super.key, required this.regData});

  @override
  State<RegistrationReviewScreen> createState() => _RegistrationReviewScreenState();
}

class _RegistrationReviewScreenState extends State<RegistrationReviewScreen> {
  int _selectedBondIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default to what was in regData if set
    if (widget.regData['bond_50k_url'] != null && widget.regData['bond_50k_url'] != '') {
      _selectedBondIndex = 1;
    } else if (widget.regData['bond_100k_url'] != null && widget.regData['bond_100k_url'] != '') {
      _selectedBondIndex = 2;
    } else {
      _selectedBondIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVendor = widget.regData['agent_type'] == 'VENDOR_AGENT';

    // Form summary strings
    final personalDetails = "${widget.regData['first_name'] ?? ''} ${widget.regData['last_name'] ?? ''}\n"
        "DOB: ${widget.regData['date_of_birth'] ?? ''}\n"
        "${widget.regData['address_line1'] ?? ''}, ${widget.regData['address_line2'] ?? ''}, ${widget.regData['city'] ?? ''}";

    final identityDetails = "NIC: ${widget.regData['nic_number'] ?? ''}\n"
        "NIC Photos: ${widget.regData['nic_photo_front_url'] != '' ? 'Uploaded' : 'Missing'}\n"
        "Proof of Address: ${widget.regData['proof_of_address_url'] != '' ? 'Uploaded' : 'Missing'}";

    final complianceDetails = "Police Certificate: ${widget.regData['police_certificate_url'] != '' ? 'Uploaded' : 'Missing'} (${widget.regData['police_certificate_date_raw'] ?? ''})\n"
        "CRIB Report: ${widget.regData['crib_report_url'] != '' ? 'Uploaded' : 'Missing'} (${widget.regData['crib_report_date_raw'] ?? ''})";

    final businessOrLicence = isVendor
        ? "PV Number: ${widget.regData['pv_number'] ?? ''}\n"
            "BR Certificate: ${widget.regData['registration_certificate_url'] != '' ? 'Uploaded' : 'Missing'}\n"
            "Premises Photo: ${widget.regData['business_premises_photo_url'] != '' ? 'Uploaded' : 'Missing'}"
        : "Licence Number: ${widget.regData['driving_licence_number'] ?? ''}\n"
            "Expiry Date: ${widget.regData['driving_licence_expiry_raw'] ?? ''}\n"
            "Vehicle Type: ${widget.regData['vehicle_type'] ?? 'None'}";

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepper(currentStep: 7),
            
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
                            
                            // Bond Selection Section
                            _buildSectionHeader("Bond Selection", isOptional: true),
                            _buildBondCard(
                              index: 0,
                              icon: LucideIcons.shieldAlert,
                              title: "No bond for now",
                              description: "No upfront deposit. You can add a bond later to increase your trust tier.",
                            ),
                            const SizedBox(height: 16),
                            _buildBondCard(
                              index: 1,
                              icon: LucideIcons.shield,
                              title: "LKR 50,000 Bond",
                              description: "Higher transaction limits and priority assignments.",
                            ),
                            const SizedBox(height: 16),
                            _buildBondCard(
                              index: 2,
                              icon: LucideIcons.shieldCheck,
                              title: "LKR 100,000 Bond",
                              description: "No traction limits. Ability to increase commission up to 0.30%.",
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Application Summary Section
                            _buildSectionHeader("Application Summary"),
                            _buildSummarySection(
                              title: "Personal Details",
                              content: personalDetails,
                            ),
                            _buildSummarySection(
                              title: "Identity & Address",
                              content: identityDetails,
                            ),
                            _buildSummarySection(
                              title: "Compliance Docs",
                              content: complianceDetails,
                            ),
                            _buildSummarySection(
                              title: isVendor ? "Business Details" : "Driving Licence & Vehicle",
                              content: businessOrLicence,
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
                  "Review & Bond",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
                Text(
                  "Select optional bond and review your application details.",
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          if (isOptional) ...[
            const SizedBox(width: 8),
            Text(
              "(Optional)",
              style: TextStyle(fontSize: 12, color: AppColors.primaryGreen.withValues(alpha: 0.5), fontWeight: FontWeight.normal),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBondCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedBondIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBondIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.white),
          boxShadow: [
            if (!isSelected)
              const BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.phoneFrameBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.primaryGreen.withValues(alpha: 0.7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.white : AppColors.primaryGreen.withValues(alpha: 0.2), width: 2),
              ),
              child: isSelected
                  ? const Center(child: Icon(Icons.check, size: 16, color: Colors.white))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
      ),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        iconColor: AppColors.primaryGreen,
        collapsedIconColor: AppColors.primaryGreen,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(
            content,
            style: TextStyle(fontSize: 13, color: AppColors.primaryGreen.withValues(alpha: 0.8), height: 1.5),
          ),
        ],
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
                // Save bond choices
                if (_selectedBondIndex == 1) {
                  widget.regData['bond_50k_url'] = 'http://localhost:8000/uploads/dummy_bond_50k.jpg';
                  widget.regData['bond_100k_url'] = '';
                } else if (_selectedBondIndex == 2) {
                  widget.regData['bond_100k_url'] = 'http://localhost:8000/uploads/dummy_bond_100k.jpg';
                  widget.regData['bond_50k_url'] = '';
                } else {
                  widget.regData['bond_50k_url'] = '';
                  widget.regData['bond_100k_url'] = '';
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ESignScreen(regData: widget.regData)),
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
