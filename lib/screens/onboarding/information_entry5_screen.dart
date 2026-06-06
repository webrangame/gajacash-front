import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/onboarding/home_screen.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InformationEntry5Screen extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String email;
  final String idPhotoUrl;

  const InformationEntry5Screen({
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
    required this.idPhotoUrl,
  });

  @override
  State<InformationEntry5Screen> createState() => _InformationEntry5ScreenState();
}

class _InformationEntry5ScreenState extends State<InformationEntry5Screen> with SingleTickerProviderStateMixin {
  final TextEditingController _pin1Controller = TextEditingController();
  final TextEditingController _pin2Controller = TextEditingController();
  final FocusNode _pin1FocusNode = FocusNode();
  final FocusNode _pin2FocusNode = FocusNode();

  bool _pin1Visible = false;
  bool _pin2Visible = false;
  bool _isPromptVisible = false;
  bool _isConfirmStage = false;
  bool _showError = false;

  late AnimationController _shakeController;
  final LocalAuthentication _localAuth = LocalAuthentication();

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
      _pin1FocusNode.unfocus();
      setState(() => _isPromptVisible = true);
    }
    setState(() {});
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
                            const SizedBox(height: 120), // Space for sticky button
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom Button
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: PrimaryButton(
                    text: "Confirm & Continue",
                    onPressed: (_pin2Controller.text.length == 4 && _pin1Controller.text == _pin2Controller.text)
                        ? () {
                            _showBiometricsPrompt();
                          }
                        : null,
                  ),
                ),
              ),
            ),

            // Backdrop and Prompt
            if (_isPromptVisible) _buildBackdrop(),
            _buildPromptSheet(),
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
          // Background filled line
          Positioned(
            left: 0,
            right: 0,
            child: Container(height: 3, color: AppColors.primaryGreen),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) => _buildStep(index + 1, index == 4, index < 4)),
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
            color: (completed || active) ? AppColors.primaryGreen : AppColors.phoneFrameBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryGreen,
              width: active ? 3 : 2,
            ),
            boxShadow: active ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 15)] : null,
          ),
          child: Center(
            child: completed 
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text(
                  "$step",
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.primaryGreen.withValues(alpha: 0.6),
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

  Widget _buildBackdrop() {
    return GestureDetector(
      onTap: () => setState(() => _isPromptVisible = false),
      child: Container(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
    );
  }

  Widget _buildPromptSheet() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: _isPromptVisible ? 0 : -500,
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
            const SizedBox(height: 32),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF5FAF7),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12)],
              ),
              child: const Icon(Icons.check, size: 32, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 24),
            const Text("Confirm your PIN", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "Please enter the same 4-digit PIN again to confirm it. This helps make sure there are no typos.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xB2006633), fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: "Got it",
              onPressed: () {
                setState(() {
                  _isPromptVisible = false;
                  _isConfirmStage = true;
                });
                Future.delayed(const Duration(milliseconds: 300), () {
                  _pin2FocusNode.requestFocus();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBiometricsPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5FAF7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                      BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                    ],
                  ),
                  child: const Icon(LucideIcons.fingerprint, size: 40, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Enable Biometrics",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Use fingerprint or face recognition to unlock GajaCash quickly and securely without entering your PIN.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xB2006633), height: 1.5, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _registerAndNavigate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Text(
                              "Skip",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          // Attempt real biometric auth
                          try {
                            final canCheck = await _localAuth.canCheckBiometrics;
                            final isSupported = await _localAuth.isDeviceSupported();
                            if (canCheck && isSupported) {
                              final authenticated = await _localAuth.authenticate(
                                localizedReason: 'Verify your identity to enable biometric login for GajaCash',
                                options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
                              );
                              if (authenticated) {
                                debugPrint('Biometrics enabled for user');
                              }
                            }
                          } catch (e) {
                            debugPrint('Biometric error: $e');
                          }
                          _registerAndNavigate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Enable",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _registerAndNavigate() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
    );

    try {
      final response = await ApiService().register(
        phone: widget.phoneNumber,
        firstName: widget.firstName,
        lastName: widget.lastName,
        password: _pin1Controller.text,
        gender: widget.gender,
        dateOfBirth: widget.dateOfBirth,
        addressLine1: widget.addressLine1,
        addressLine2: widget.addressLine2,
        city: widget.city,
        email: widget.email,
        idPhotoUrl: widget.idPhotoUrl,
      );

      if (mounted) {
        Navigator.pop(context); // Pop loader
        if (response.statusCode == 201 || response.statusCode == 200) {
          // Store auth credentials
          final data = response.data;
          ApiService.token = data['access_token'];
          ApiService.userId = data['user_id'];

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data['error'] ?? "Registration failed. Please try again.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }
}
