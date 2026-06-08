import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/home_screen.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _pin1Controller = TextEditingController();
  final TextEditingController _pin2Controller = TextEditingController();
  final FocusNode _pin1FocusNode = FocusNode();
  final FocusNode _pin2FocusNode = FocusNode();

  bool _pin1Visible = false;
  bool _pin2Visible = false;
  bool _isConfirmStage = false;
  bool _showError = false;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
  }

  @override
  void dispose() {
    _pin1Controller.dispose();
    _pin2Controller.dispose();
    _pin1FocusNode.dispose();
    _pin2FocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePin1Change(String value) {
    if (value.length == 4) {
      setState(() => _isConfirmStage = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        _pin2FocusNode.requestFocus();
      });
    }
  }

  void _handlePin2Change(String value) {
    if (value.length == 4) {
      if (_pin1Controller.text == _pin2Controller.text) {
        setState(() => _showError = false);
      } else {
        setState(() => _showError = true);
        _shakeController.forward(from: 0);
      }
    } else {
      setState(() => _showError = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = _pin2Controller.text.length == 4 && _pin1Controller.text == _pin2Controller.text;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildIconButton(LucideIcons.arrowLeft, () => Navigator.of(context).pop()),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        const Text(
                          "Create your 4-digit transaction PIN",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText, height: 1.2),
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "You'll use this PIN to approve important actions and payments. Keep it private.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xB2006633), fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildPinCard(),
                        
                        const SizedBox(height: 32),
                        _buildBiometricInfo(),
                        const SizedBox(height: 48),

                        PrimaryButton(
                          text: "Confirm & Continue",
                          onPressed: isComplete
                              ? () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    (route) => false,
                                  );
                                }
                              : null,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.phoneFrameBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.clayShadowColor.withValues(alpha: 0.8),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-6, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 28),
      ),
    );
  }

  Widget _buildPinCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF7),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPinSection(
            label: "Enter 4-digit PIN",
            controller: _pin1Controller,
            focusNode: _pin1FocusNode,
            isVisible: _pin1Visible,
            onToggle: () => setState(() => _pin1Visible = !_pin1Visible),
            onChanged: _handlePin1Change,
            enabled: true,
          ),
          const SizedBox(height: 24),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isConfirmStage ? 1.0 : 0.4,
            child: IgnorePointer(
              ignoring: !_isConfirmStage,
              child: _buildPinSection(
                label: "Confirm PIN",
                controller: _pin2Controller,
                focusNode: _pin2FocusNode,
                isVisible: _pin2Visible,
                onToggle: () => setState(() => _pin2Visible = !_pin2Visible),
                onChanged: _handlePin2Change,
                enabled: _isConfirmStage,
                hasError: _showError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSection({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isVisible,
    required VoidCallback onToggle,
    required Function(String) onChanged,
    required bool enabled,
    bool hasError = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen, letterSpacing: 1)),
        ),
        Row(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = hasError ? (8 * (0.5 - (0.5 - _shakeController.value).abs()) * ( (_shakeController.value * 10).floor() % 2 == 0 ? 1 : -1)) : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.phoneFrameBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                        ],
                        border: hasError ? Border.all(color: Colors.red.withValues(alpha: 0.5), width: 2) : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: onChanged,
                            enabled: enabled,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            showCursor: false,
                            style: const TextStyle(color: Colors.transparent),
                            decoration: const InputDecoration(border: InputBorder.none, counterText: ""),
                          ),
                          IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                final isFilled = controller.text.length > index;
                                if (isVisible && isFilled) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      controller.text[index],
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                    ),
                                  );
                                }
                                return Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isFilled 
                                        ? (hasError ? Colors.red : AppColors.primaryGreen)
                                        : AppColors.primaryGreen.withValues(alpha: 0.1),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: enabled ? onToggle : null,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.phoneFrameBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                  ],
                ),
                child: Icon(isVisible ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.primaryGreen, size: 24),
              ),
            ),
          ],
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 8),
            child: Row(
              children: [
                Icon(LucideIcons.alertCircle, color: Colors.red, size: 14),
                SizedBox(width: 8),
                Text("PINs don't match. Please try again.", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBiometricInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(LucideIcons.fingerprint, color: AppColors.primaryGreen.withValues(alpha: 0.6), size: 20),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "After you set your PIN, we'll ask if you want to enable biometric login for faster, secure access.",
            style: TextStyle(color: Color(0xB2006633), fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
          ),
        ),
      ],
    );
  }
}
