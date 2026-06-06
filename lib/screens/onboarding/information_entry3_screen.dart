import 'package:gajacash_sample/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/onboarding/information_entry4_screen.dart';
import 'package:gajacash_sample/widgets/primary_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InformationEntry3Screen extends StatefulWidget {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String addressLine1;
  final String addressLine2;
  final String city;

  const InformationEntry3Screen({
    super.key,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
  });

  @override
  State<InformationEntry3Screen> createState() => _InformationEntry3ScreenState();
}

class _InformationEntry3ScreenState extends State<InformationEntry3Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isConfirmationVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) return true;
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
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
                                "Add a recovery email",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Optional, but recommended. This helps you recover your account if you lose access to your phone or number. It can also be used to verify security alerts.",
                                style: TextStyle(color: Color(0xB2006633), fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 32),

                              _buildLabel("Email address"),
                              _buildEmailField(),
                              const SizedBox(height: 8),
                              Text(
                                "Optional",
                                style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.6), fontSize: 12, fontStyle: FontStyle.italic),
                              ),

                              const SizedBox(height: 48),
                              _buildMascotSection(),
                              const SizedBox(height: 120), // Space for sticky button
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // sticky Continue Button
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
                      if (_validateEmail(_emailController.text)) {
                        setState(() => _isConfirmationVisible = true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a valid email or leave it empty.")),
                        );
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
            children: List.generate(5, (index) => _buildStep(index + 1, index == 2, index < 2)),
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
              ? const Icon(Icons.check, color: Colors.white, size: 20)
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
    );
  }

  Widget _buildEmailField() {
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
        controller: _emailController,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: "e.g. sarah@example.com",
          hintStyle: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: Icon(LucideIcons.mail, color: AppColors.primaryGreen.withValues(alpha: 0.3), size: 20),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildMascotSection() {
    return Column(
      children: [
        Transform.scale(
          scale: 1.5,
          child: SafeNetworkImage(url:
            "https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/3a438595-7398-4051-a5dc-47f0f0cee7ab_3840w.png",
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5FAF7),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
              BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Text(
                "We’ll never share your email with third parties.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryGreen, fontSize: 15, fontWeight: FontWeight.w500),
              ),
              Positioned(
                top: -24,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomPaint(
                    size: const Size(20, 10),
                    painter: BubbleTrianglePainter(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
            const Text("Confirm recovery", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("You can always add or change this later in Settings.", style: TextStyle(color: Colors.black54, fontSize: 14)),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FAF7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12)],
              ),
              child: Column(
                children: [
                  Text("RECOVERY EMAIL", style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(
                    _emailController.text.isEmpty ? "Not added yet" : _emailController.text,
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: _emailController.text.isEmpty ? Colors.black26 : AppColors.primaryText,
                      fontStyle: _emailController.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
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
                          builder: (context) => InformationEntry4Screen(
                            phoneNumber: widget.phoneNumber,
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            gender: widget.gender,
                            dateOfBirth: widget.dateOfBirth,
                            addressLine1: widget.addressLine1,
                            addressLine2: widget.addressLine2,
                            city: widget.city,
                            email: _emailController.text,
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
}

class BubbleTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5FAF7)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
