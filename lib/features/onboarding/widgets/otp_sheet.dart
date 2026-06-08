import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:gajacash_sample/core/widgets/inset_neumorphic_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OtpSheet extends StatefulWidget {
  final bool isVisible;
  final String phoneNumber;
  final VoidCallback onClose;
  final VoidCallback onContinue;

  const OtpSheet({
    super.key,
    required this.isVisible,
    this.phoneNumber = "+94 777-XXX-XXX",
    required this.onClose,
    required this.onContinue,
  });

  @override
  State<OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
  // OTP Fields
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  final List<String> _otpActualValues = List.filled(6, '');
  final List<Timer?> _otpTimers = List.filled(6, null);
  Timer? _otpCountdownTimer;
  int _timeLeft = 60;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 6; i++) {
      // Focus listener to auto-select text and update focus highlights
      _otpFocusNodes[i].addListener(() {
        if (mounted) {
          setState(() {});
        }
        if (_otpFocusNodes[i].hasFocus && mounted) {
          _otpControllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[i].text.length,
          );
        }
      });

      // Key listener to intercept Backspace on empty fields
      _otpFocusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_otpControllers[i].text.isEmpty && i > 0) {
            _otpControllers[i - 1].clear();
            _otpActualValues[i - 1] = '';
            _otpTimers[i - 1]?.cancel();
            _otpFocusNodes[i - 1].requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }

    if (widget.isVisible) {
      _startOtpCountdown();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && widget.isVisible) {
          _otpFocusNodes[0].requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant OtpSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _startOtpCountdown();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && widget.isVisible) {
          _otpFocusNodes[0].requestFocus();
        }
      });
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _otpCountdownTimer?.cancel();
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].clear();
        _otpActualValues[i] = '';
        _otpTimers[i]?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _otpCountdownTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    for (var timer in _otpTimers) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _startOtpCountdown() {
    _otpCountdownTimer?.cancel();
    setState(() {
      _timeLeft = 60;
    });
    _otpCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _otpCountdownTimer?.cancel();
          }
        });
      }
    });
  }

  void _resendOtp() {
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].clear();
      _otpActualValues[i] = '';
      _otpTimers[i]?.cancel();
    }
    _startOtpCountdown();
    _otpFocusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: widget.isVisible ? 0 : -550,
      left: 0,
      right: 0,
      child: Container(
        height: 500,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -8)),
          ],
        ),
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 24,
              right: 24,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.phoneFrameBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.clayShadowColor, offset: Offset(2, 2), blurRadius: 4),
                      BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(LucideIcons.x, size: 16, color: AppColors.primaryText),
                ),
              ),
            ),
            
            // Sheet Content
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 24, right: 24, bottom: 48),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  Text(
                    "Please enter the 6-digit OTP sent to ${widget.phoneNumber}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // OTP Inputs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOtpBox(0),
                      _buildOtpBox(1),
                      _buildOtpBox(2),
                      Container(
                        width: 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      _buildOtpBox(3),
                      _buildOtpBox(4),
                      _buildOtpBox(5),
                    ],
                  ),
                  _buildOtpTimer(),
                  
                  const Spacer(),
                  
                  PrimaryButton(
                    text: "Continue",
                    onPressed: widget.onContinue,
                  ),
                  
                  _buildResendButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpTimer() {
    if (_timeLeft > 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 36),
        child: Center(
          child: Text(
            "Didn't Receive OTP? Resend in $_timeLeft seconds",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryGreen.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildResendButton() {
    if (_timeLeft == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GestureDetector(
          onTap: _resendOtp,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(4, 4),
                  blurRadius: 10,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              "Re-send OTP",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F1D1B),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOtpBox(int index) {
    final bool isFocused = _otpFocusNodes[index].hasFocus;
    
    return InsetNeumorphicContainer(
      width: 44,
      height: 56,
      borderRadius: 12,
      isFocused: isFocused,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryText,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value == '●') return;
          if (value == _otpActualValues[index]) return;
          
          if (value.length > 1) {
            String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
            for (int i = 0; i < digits.length; i++) {
              int targetIndex = index + i;
              if (targetIndex < 6) {
                String char = digits[i];
                _otpActualValues[targetIndex] = char;
                _otpControllers[targetIndex].text = char;
                _otpTimers[targetIndex]?.cancel();
                _otpTimers[targetIndex] = Timer(const Duration(seconds: 1), () {
                  if (mounted) {
                    _otpControllers[targetIndex].text = '●';
                  }
                });
              }
            }
            int focusIndex = (index + digits.length).clamp(0, 5);
            _otpFocusNodes[focusIndex].requestFocus();
            return;
          }
          
          if (value.isNotEmpty) {
            String char = value.characters.last;
            _otpActualValues[index] = char;
            _otpControllers[index].text = char;
            _otpControllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _otpControllers[index].text.length),
            );
            _otpTimers[index]?.cancel();
            _otpTimers[index] = Timer(const Duration(seconds: 1), () {
              if (mounted) {
                _otpControllers[index].text = '●';
              }
            });
            if (index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            }
          } else {
            _otpActualValues[index] = '';
            _otpTimers[index]?.cancel();
            if (index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
          }
        },
      ),
    );
  }
}
