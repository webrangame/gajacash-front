import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/password_entry_screen.dart';
import 'package:gajacash_sample/features/onboarding/screens/information_entry1_screen.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:gajacash_sample/core/widgets/custom_back_button.dart';
import 'package:gajacash_sample/core/widgets/speech_bubble.dart';
import 'package:gajacash_sample/core/widgets/inset_neumorphic_container.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String phoneNumber;
  const VerificationCodeScreen({super.key, required this.phoneNumber});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<bool> _isFocusedList = List.generate(6, (_) => false);
  int _secondsLeft = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(() {
        if (mounted) {
          setState(() {
            _isFocusedList[i] = _focusNodes[i].hasFocus;
          });
        }
      });
    }
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenHeight < 720;
    final bool isExtraSmallScreen = screenHeight < 600;
    final bool isExtraNarrow = screenWidth < 350;

    return Scaffold(
      backgroundColor: AppColors.phoneFrameBg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: isExtraSmallScreen ? 4 : 8,
                    ),
                    child: Row(
                      children: [
                        CustomBackButton(
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Mascot bubble takes remaining space
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMascotSection(isSmallScreen, isExtraSmallScreen),
                    ),
                  ),

                  SizedBox(height: isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 16)),

                  // Bottom Section: Inputs & Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: isExtraSmallScreen ? 10 : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormSection(isSmallScreen, isExtraNarrow),
                        SizedBox(height: isExtraSmallScreen ? 8 : (isSmallScreen ? 12 : 20)),

                        // Countdown Timer Section (only visible while ticking)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _canResend ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: _canResend,
                            child: _buildTimerSection(),
                          ),
                        ),

                        SizedBox(height: isExtraSmallScreen ? 8 : (isSmallScreen ? 12 : 20)),

                        // Continue Button (Always visible)
                        PrimaryButton(
                          text: "Continue",
                          onPressed: () async {
                            String otp = _controllers
                                .map((c) => c.text.trim())
                                .join();
                            if (otp.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please enter the complete 6-digit code",
                                  ),
                                ),
                              );
                              return;
                            }

                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            );

                            try {
                              final response = await ApiService().verifyOtp(
                                widget.phoneNumber,
                                otp,
                              );
                              if (mounted) {
                                if (response.statusCode == 200) {
                                  try {
                                    final checkResp = await ApiService()
                                        .checkUser(widget.phoneNumber);
                                    bool userExists =
                                        checkResp.data['exists'] ?? false;
                                    if (mounted) {
                                      navigator.pop(); // Pop loader
                                      if (userExists) {
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PasswordEntryScreen(
                                                  phoneNumber:
                                                      widget.phoneNumber,
                                                ),
                                          ),
                                        );
                                      } else {
                                        navigator.push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                InformationEntry1Screen(
                                                  phoneNumber:
                                                      widget.phoneNumber,
                                                ),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (checkErr) {
                                    if (mounted) {
                                      navigator.pop(); // Pop loader
                                      navigator.push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InformationEntry1Screen(
                                                phoneNumber:
                                                    widget.phoneNumber,
                                              ),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  navigator.pop(); // Pop loader
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Invalid verification code. Please try again.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                navigator.pop(); // Pop loader
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Verification failed: ${e.toString()}",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        // Re-send OTP Button (Always visible, disabled until timer expires)
                        _buildResendButton(),

                        SizedBox(height: isExtraSmallScreen ? 10 : (isSmallScreen ? 16 : 24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotSection(bool isSmallScreen, bool isExtraSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpeechBubble(
          text: "Please enter the 6-digit OTP sent to ${widget.phoneNumber}",
          padding: isExtraSmallScreen ? const EdgeInsets.all(12) : null,
          fontSize: isExtraSmallScreen ? 15 : null,
        ),
        SizedBox(height: isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -4),
            child: Transform.scale(
              scale: isExtraSmallScreen ? 0.75 : 0.85,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: isExtraSmallScreen ? 80 : (isSmallScreen ? 130 : 180),
                ),
                child: Image.asset(
                  'assets/images/mascot_verify.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(bool isSmallScreen, bool isExtraNarrow) {
    final double boxSpacing = isExtraNarrow ? 4 : (isSmallScreen ? 6 : 8);
    final double separatorWidth = isExtraNarrow ? 6 : (isSmallScreen ? 8 : 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Please enter the code we just sent you.",
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildOtpBox(0, isSmallScreen, isExtraNarrow),
                SizedBox(width: boxSpacing),
                _buildOtpBox(1, isSmallScreen, isExtraNarrow),
                SizedBox(width: boxSpacing),
                _buildOtpBox(2, isSmallScreen, isExtraNarrow),
              ],
            ),
            Container(
              width: separatorWidth,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                _buildOtpBox(3, isSmallScreen, isExtraNarrow),
                SizedBox(width: boxSpacing),
                _buildOtpBox(4, isSmallScreen, isExtraNarrow),
                SizedBox(width: boxSpacing),
                _buildOtpBox(5, isSmallScreen, isExtraNarrow),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index, bool isSmallScreen, bool isExtraNarrow) {
    final double boxWidth = isExtraNarrow ? 38 : (isSmallScreen ? 44 : 52);
    final double boxHeight = isExtraNarrow ? 48 : (isSmallScreen ? 56 : 64);
    final double fontSize = isExtraNarrow ? 20 : 24;

    return InsetNeumorphicContainer(
      width: boxWidth,
      height: boxHeight,
      borderRadius: 12,
      isFocused: _isFocusedList[index],
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        obscureText: true,
        obscuringCharacter: '●',
        cursorColor: AppColors.primaryGreen,
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
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
    return Center(
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
    return PrimaryButton(
      text: "Re-send OTP",
      backgroundColor: _canResend
          ? const Color(0xFFD9D9D9)
          : const Color(0xFFE5E5E5),
      textColor: _canResend
          ? AppColors.primaryText
          : AppColors.primaryText.withValues(alpha: 0.35),
      onPressed: _canResend
          ? () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
              try {
                await ApiService().sendOtp(widget.phoneNumber);
                if (mounted) {
                  navigator.pop(); // Pop loader
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("OTP resent successfully!"),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                  _startTimer();
                }
              } catch (e) {
                if (mounted) {
                  navigator.pop(); // Pop loader
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Failed to resend OTP: ${e.toString()}"),
                    ),
                  );
                }
              }
            }
          : null,
    );
  }
}
