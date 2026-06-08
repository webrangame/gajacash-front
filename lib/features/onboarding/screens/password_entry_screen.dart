import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/home_screen.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
import 'package:gajacash_sample/core/widgets/custom_back_button.dart';
import 'package:gajacash_sample/core/widgets/speech_bubble.dart';
import 'package:gajacash_sample/core/widgets/inset_neumorphic_container.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PasswordEntryScreen extends StatefulWidget {
  final String phoneNumber;

  const PasswordEntryScreen({super.key, required this.phoneNumber});

  @override
  State<PasswordEntryScreen> createState() => _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends State<PasswordEntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _pinVisible = false;
  bool _showError = false;
  bool _isFocused = false;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pinFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _pinFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePinChange(String value) {
    setState(() => _showError = false);
    if (value.length == 4) {
      _pinFocusNode.unfocus();
    }
  }

  Future<void> _doLogin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _showError = true);
      _shakeController.forward(from: 0);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      // The backend "password" field is actually the PIN
      final response = await ApiService().login(widget.phoneNumber, pin);

      if (mounted) {
        Navigator.pop(context); // Pop loader
        if (response.statusCode == 200) {
          final data = response.data;
          ApiService.token = data['access_token'];
          ApiService.userId = data['user_id'];

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          setState(() => _showError = true);
          _shakeController.forward(from: 0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.data['error'] ?? 'Incorrect PIN. Please try again.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loader
        setState(() => _showError = true);
        _shakeController.forward(from: 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isReady = _pinController.text.length == 4;
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
                      vertical: isExtraSmallScreen ? 6 : (isSmallScreen ? 10 : 0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          "Enter your 4-digit PIN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isExtraSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: isExtraSmallScreen ? 2 : 4),
                        Text(
                          "The PIN you created when you registered",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isExtraSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),

                        SizedBox(height: isExtraSmallScreen ? 8 : (isSmallScreen ? 16 : 32)),

                        // PIN Card
                        _buildPinCard(isSmallScreen, isExtraSmallScreen, isExtraNarrow),

                        SizedBox(height: isExtraSmallScreen ? 12 : (isSmallScreen ? 24 : 48)),

                        PrimaryButton(
                          text: "Login",
                          onPressed: isReady ? _doLogin : null,
                        ),

                        SizedBox(height: isExtraSmallScreen ? 8 : (isSmallScreen ? 16 : 32)),
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
        // Speech Bubble
        SpeechBubble(
          text: "Welcome back! 👋\nEnter your PIN to continue.",
          padding: isExtraSmallScreen ? const EdgeInsets.all(12) : null,
          fontSize: isExtraSmallScreen ? 15 : null,
        ),
        SizedBox(height: isExtraSmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
        // Mascot
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
                  'assets/images/mascot.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCard(bool isSmallScreen, bool isExtraSmallScreen, bool isExtraNarrow) {
    final double cardPadding = isExtraSmallScreen ? 16 : 24;
    final double elementHeight = isExtraSmallScreen ? 52 : 64;
    final double fontSize = isExtraSmallScreen ? 20 : 24;
    final double dotSize = isExtraSmallScreen ? 12 : 16;
    final double dotSpacing = isExtraSmallScreen ? 6 : 8;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF7),
        borderRadius: BorderRadius.circular(32),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "4-DIGIT PIN",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                letterSpacing: 1,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final offset = _showError
                        ? (8 *
                              (0.5 - (0.5 - _shakeController.value).abs()) *
                              ((_shakeController.value * 10).floor() % 2 == 0
                                  ? 1
                                  : -1))
                        : 0.0;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: InsetNeumorphicContainer(
                        height: elementHeight,
                        borderRadius: 16,
                        isFocused: _isFocused,
                        color: AppColors.phoneFrameBg,
                        borderColor: _showError ? Colors.red.withValues(alpha: 0.5) : null,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TextField(
                              controller: _pinController,
                              focusNode: _pinFocusNode,
                              onChanged: _handlePinChange,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              showCursor: false,
                              style: const TextStyle(color: Colors.transparent),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                              ),
                            ),
                            // PIN dot indicators overlay
                            IgnorePointer(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(4, (index) {
                                  final isFilled =
                                      _pinController.text.length > index;
                                  if (_pinVisible && isFilled) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: dotSpacing,
                                      ),
                                      child: Text(
                                        _pinController.text[index],
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: dotSize,
                                    height: dotSize,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: dotSpacing,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFilled
                                          ? (_showError
                                                ? Colors.red
                                                : AppColors.primaryGreen)
                                          : AppColors.primaryGreen.withValues(
                                              alpha: 0.1,
                                            ),
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
              // Show/hide toggle
              GestureDetector(
                onTap: () => setState(() => _pinVisible = !_pinVisible),
                child: Container(
                  width: elementHeight,
                  height: elementHeight,
                  decoration: BoxDecoration(
                    color: AppColors.phoneFrameBg,
                    borderRadius: BorderRadius.circular(16),
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
                  child: Icon(
                    _pinVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          if (_showError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: Colors.red, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    "Incorrect PIN. Please try again.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isExtraSmallScreen ? 11 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
