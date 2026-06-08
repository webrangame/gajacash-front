import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/onboarding/information_entry3_screen.dart';
import 'package:gajacash_sample/screens/onboarding/map_picker_screen.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InformationEntry2Screen extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;

  const InformationEntry2Screen({
    super.key,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  State<InformationEntry2Screen> createState() => _InformationEntry2ScreenState();
}

class _InformationEntry2ScreenState extends State<InformationEntry2Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  LatLng? _pinnedLocation;
  bool _isConfirmationVisible = false;

  @override
  void dispose() {
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLocation: _pinnedLocation),
      ),
    );
    if (result != null && mounted) {
      setState(() => _pinnedLocation = result);
    }
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
                                "Where can we reach you?",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Add your main postal address so we can verify your location if needed.",
                                style: TextStyle(color: Color(0xB2006633), fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 32),

                              _buildLabel("Address line 1"),
                              _buildTextField(_address1Controller, "e.g. 123 Baker Street"),
                              const SizedBox(height: 24),

                              _buildLabel("Address line 2", isOptional: true),
                              _buildTextField(_address2Controller, "Apartment, floor, landmark", required: false),
                              const SizedBox(height: 24),

                              _buildLabel("City / Town"),
                              _buildTextField(_cityController, "e.g. Colombo"),
                              const SizedBox(height: 24),

                              _buildLabel("Pin your location"),
                              _buildMapPicker(),
                              const SizedBox(height: 120),
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
                      if (_formKey.currentState!.validate()) {
                        if (_pinnedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please pin your location on the map.")),
                          );
                          return;
                        }
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
            children: List.generate(5, (index) => _buildStep(index + 1, index == 1, index < 1)),
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

  Widget _buildLabel(String text, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            if (isOptional)
              TextSpan(text: " (Optional)", style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.normal))
            else
              const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool required = true}) {
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
        validator: required ? (value) => value == null || value.isEmpty ? "Required" : null : null,
      ),
    );
  }

  Widget _buildMapPicker() {
    final bool locationSet = _pinnedLocation != null;
    return GestureDetector(
      onTap: _openMapPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: locationSet
              ? AppColors.primaryGreen.withValues(alpha: 0.06)
              : AppColors.phoneFrameBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: locationSet
                ? AppColors.primaryGreen.withValues(alpha: 0.4)
                : AppColors.primaryGreen.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
            BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: locationSet
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                locationSet ? LucideIcons.mapPin : LucideIcons.map,
                color: locationSet ? Colors.white : AppColors.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationSet ? "Location pinned" : "Open map to drop a pin",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: locationSet ? AppColors.primaryGreen : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locationSet
                        ? '${_pinnedLocation!.latitude.toStringAsFixed(5)}, '
                          '${_pinnedLocation!.longitude.toStringAsFixed(5)}'
                        : "Tap to select on map",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: locationSet
                          ? AppColors.primaryGreen.withValues(alpha: 0.7)
                          : AppColors.primaryText.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.primaryGreen.withValues(alpha: 0.5),
              size: 20,
            ),
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
            const Text("Confirm your address", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Make sure we can find you.", style: TextStyle(color: Colors.black54, fontSize: 14)),
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
                          builder: (context) => InformationEntry3Screen(
                            phoneNumber: widget.phoneNumber,
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            gender: widget.gender,
                            dateOfBirth: widget.dateOfBirth,
                            addressLine1: _address1Controller.text,
                            addressLine2: _address2Controller.text,
                            city: _cityController.text,
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
          _summaryRow("Address", _address1Controller.text),
          if (_address2Controller.text.isNotEmpty)
            _summaryRow("", _address2Controller.text, isSub: true),
          const Divider(height: 24),
          _summaryRow("City", _cityController.text),
          const Divider(height: 24),
          _summaryRow("Location", "Pinned ✓", isIcon: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isSub = false, bool isIcon = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSub) Text(label, style: const TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w500)),
        if (isSub) const SizedBox(width: 1),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isIcon) const Icon(LucideIcons.mapPin, size: 12, color: AppColors.primaryGreen),
              if (isIcon) const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: isSub ? FontWeight.w600 : FontWeight.bold,
                    fontSize: 14,
                    color: isSub ? Colors.black54 : AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
