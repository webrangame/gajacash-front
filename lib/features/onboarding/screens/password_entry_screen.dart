import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/home_screen.dart';
import 'package:gajacash_sample/core/widgets/primary_button.dart';
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

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
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
              content: Text(response.data['error'] ?? 'Incorrect PIN. Please try again.'),
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildIconButton(
                    LucideIcons.arrowLeft,
                    () => Navigator.of(context).pop(),
                  ),
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
                        // Mascot & Bubble
                        _buildMascotSection(),

                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          "Enter your 4-digit PIN",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "The PIN you created when you registered",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryGreen.withValues(alpha: 0.6),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // PIN Card
                        _buildPinCard(),

                        const SizedBox(height: 48),

                        PrimaryButton(
                          text: "Login",
                          onPressed: isReady ? _doLogin : null,
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

  Widget _buildMascotSection() {
    return Column(
      children: [
        // Speech Bubble
        Container(
          padding: const EdgeInsets.all(20),
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
          child: const Text(
            "Welcome back! 👋\nEnter your PIN to continue.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Mascot
        SafeNetworkImage(
          url: 'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/4180c46d-36ad-4905-8d2c-8f3365a4ea7d_800w.png',
          width: 180,
          fit: BoxFit.contain,
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
                      child: Container(
                        height: 64,
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
                          border: _showError
                              ? Border.all(
                                  color: Colors.red.withValues(alpha: 0.5),
                                  width: 2,
                                )
                              : null,
                        ),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                        _pinController.text[index],
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    width: 16,
                                    height: 16,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFilled
                                          ? (_showError
                                              ? Colors.red
                                              : AppColors.primaryGreen)
                                          : AppColors.primaryGreen
                                              .withValues(alpha: 0.1),
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
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.phoneFrameBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.clayShadowColor,
                          offset: Offset(4, 4),
                          blurRadius: 8),
                      BoxShadow(
                          color: Colors.white,
                          offset: Offset(-4, -4),
                          blurRadius: 8),
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
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 8),
              child: Row(
                children: [
                  Icon(LucideIcons.alertCircle, color: Colors.red, size: 14),
                  SizedBox(width: 8),
                  Text(
                    "Incorrect PIN. Please try again.",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
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
