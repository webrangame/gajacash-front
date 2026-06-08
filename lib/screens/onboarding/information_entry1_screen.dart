import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/onboarding/information_entry2_screen.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InformationEntry1Screen extends StatefulWidget {
  final String phoneNumber;
  const InformationEntry1Screen({super.key, required this.phoneNumber});

  @override
  State<InformationEntry1Screen> createState() => _InformationEntry1ScreenState();
}

class _InformationEntry1ScreenState extends State<InformationEntry1Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDob;
  bool _isConfirmationVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() => _selectedDob = picked);
    }
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.phoneFrameBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text("Select Gender", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _genderOption("Female"),
              _genderOption("Male"),
            ],
          ),
        );
      },
    );
  }

  Widget _genderOption(String value) {
    return ListTile(
      title: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        setState(() => _selectedGender = value);
        Navigator.pop(context);
      },
      trailing: _selectedGender == value ? const Icon(LucideIcons.check, color: AppColors.primaryGreen) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
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
                                "Let's get to know you",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "These details help us set up your secure account.",
                                style: TextStyle(color: Color(0xB2006633), fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 32),

                              _buildLabel("First name"),
                              _buildTextField(_firstNameController, "e.g. Sarah"),
                              const SizedBox(height: 24),

                              _buildLabel("Last name"),
                              _buildTextField(_lastNameController, "e.g. Connors"),
                              const SizedBox(height: 24),

                              _buildLabel("Gender"),
                              _buildPickerField(_selectedGender ?? "Select gender", _showGenderPicker),
                              const SizedBox(height: 24),

                              _buildLabel("Date of birth"),
                              _buildPickerField(
                                _selectedDob == null ? "Select date" : "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}",
                                () => _selectDate(context),
                                icon: LucideIcons.calendar,
                              ),
                              const SizedBox(height: 120), // More space for sticky button on small screens
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Continue Button
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: PrimaryButton(
                    text: "Continue",
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedGender != null && _selectedDob != null) {
                        setState(() => _isConfirmationVisible = true);
                      }
                    },
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
            children: List.generate(5, (index) => _buildStep(index + 1, index == 0)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step, bool active) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.phoneFrameBg,
            shape: BoxShape.circle,
            border: Border.all(color: active ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.3), width: active ? 3 : 2),
            boxShadow: active ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 15)] : null,
          ),
          child: Center(
            child: Text(
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
            color: active ? AppColors.primaryGreen : AppColors.primaryText.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildPickerField(String text, VoidCallback onTap, {IconData icon = LucideIcons.chevronDown}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.phoneFrameBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
            BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: TextStyle(color: text.startsWith("Select") ? AppColors.primaryGreen.withValues(alpha: 0.5) : AppColors.primaryText, fontWeight: FontWeight.w500)),
            Icon(icon, size: 20, color: AppColors.primaryGreen.withValues(alpha: 0.6)),
          ],
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
      bottom: _isConfirmationVisible ? 0 : -500,
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
            const Text("Confirm your details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Make sure everything is correct.", style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 24),
            _buildSummaryCard(),
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
                          builder: (context) => InformationEntry2Screen(
                            phoneNumber: widget.phoneNumber,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            gender: _selectedGender ?? "",
                            dateOfBirth: _selectedDob == null
                                ? ""
                                : "${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}",
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12)],
      ),
      child: Column(
        children: [
          _summaryRow("Full Name", "${_firstNameController.text} ${_lastNameController.text}"),
          const Divider(height: 24),
          _summaryRow("Gender", _selectedGender ?? ""),
          const Divider(height: 24),
          _summaryRow("Date of Birth", _selectedDob == null ? "" : "${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}"),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
