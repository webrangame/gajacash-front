import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/password_entry_screen.dart';
import 'package:gajacash_sample/features/onboarding/screens/information_entry1_screen.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String phoneNumber;
  const VerificationCodeScreen({super.key, required this.phoneNumber});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsLeft = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        setState(() => _canResend = true);
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mascot and Bubble
                        _buildMascotSection(),

                        const SizedBox(height: 16),

                        // Form Section
                        _buildFormSection(),

                        const SizedBox(height: 24),

                        // Countdown / Resend
                        _buildTimerSection(),

                        const SizedBox(height: 24),

                        // Continue Button
                        if (!_canResend)
                          PrimaryButton(
                            text: "Continue",
                            onPressed: () async {
                              String otp = _controllers.map((c) => c.text.trim()).join();
                              if (otp.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter the complete 6-digit code")),
                                );
                                return;
                              }

                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                              );

                              try {
                                final response = await ApiService().verifyOtp(widget.phoneNumber, otp);
                                if (mounted) {
                                  if (response.statusCode == 200) {
                                    try {
                                      final checkResp = await ApiService().checkUser(widget.phoneNumber);
                                      bool userExists = checkResp.data['exists'] ?? false;
                                      if (mounted) {
                                        navigator.pop(); // Pop loader
                                        if (userExists) {
                                          navigator.push(
                                            MaterialPageRoute(
                                              builder: (context) => PasswordEntryScreen(phoneNumber: widget.phoneNumber),
                                            ),
                                          );
                                        } else {
                                          navigator.push(
                                            MaterialPageRoute(
                                              builder: (context) => InformationEntry1Screen(phoneNumber: widget.phoneNumber),
                                            ),
                                          );
                                        }
                                      }
                                    } catch (checkErr) {
                                      if (mounted) {
                                        navigator.pop(); // Pop loader
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (context) => InformationEntry1Screen(phoneNumber: widget.phoneNumber),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    navigator.pop(); // Pop loader
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text("Invalid verification code. Please try again.")),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  navigator.pop(); // Pop loader
                                  messenger.showSnackBar(
                                    SnackBar(content: Text("Verification failed: ${e.toString()}")),
                                  );
                                }
                              }
                            },
                          )
                        else
                          _buildResendButton(),
                        
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

  Widget _buildMascotSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Speech Bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.clayShadowColor,
                offset: Offset(8, 8),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-8, -8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Text(
            "Please enter the 6-digit OTP sent to ${widget.phoneNumber}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Mascot
        SafeNetworkImage(url:
          'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/4180c46d-36ad-4905-8d2c-8f3365a4ea7d_3840w.png?w=800&q=80',
          width: 180,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Please enter the code we just sent you.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(3, (index) => _buildOtpBox(index)),
            Container(width: 12, height: 2, decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            ...List.generate(3, (index) => _buildOtpBox(index + 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 44,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.clayShadowColor,
            offset: Offset(4, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        obscureText: true,
        obscuringCharacter: '●',
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildTimerSection() {
    return Visibility(
      visible: !_canResend,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Text(
        "Didn't Receive OTP? Resend in $_secondsLeft seconds",
        style: TextStyle(
          color: AppColors.primaryGreen.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        );
        try {
          await ApiService().sendOtp(widget.phoneNumber);
          if (mounted) {
            navigator.pop(); // Pop loader
            messenger.showSnackBar(
              const SnackBar(content: Text("OTP resent successfully!"), backgroundColor: AppColors.primaryGreen),
            );
            _startTimer();
          }
        } catch (e) {
          if (mounted) {
            navigator.pop(); // Pop loader
            messenger.showSnackBar(
              SnackBar(content: Text("Failed to resend OTP: ${e.toString()}")),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(4, 4),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Text(
          "Re-send OTP",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}
