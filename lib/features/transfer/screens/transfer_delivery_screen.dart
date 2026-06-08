import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gajacash_sample/core/api_service.dart';

class TransferDeliveryScreen extends StatefulWidget {
  const TransferDeliveryScreen({super.key});

  @override
  State<TransferDeliveryScreen> createState() => _TransferDeliveryScreenState();
}

class _TransferDeliveryScreenState extends State<TransferDeliveryScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0=phone, 1=amount, 2=method, 3=review, 4=pin

  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedMethod = '';
  bool _isLoading = false;

  // PIN input
  final List<String> _pin = [];
  static const int _pinLength = 4;

  final List<String> _steps = ['Recipient', 'Amount', 'Method', 'Review', 'Confirm'];

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitTransfer() async {
    setState(() => _isLoading = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await ApiService().processTransfer(
        recipientId: _phoneController.text.trim(),
        amount: double.tryParse(_amountController.text) ?? 0,
        method: _selectedMethod,
      );
      if (mounted) {
        if (response.statusCode == 200) {
          _showSuccessSheet();
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(response.data['error'] ?? 'Transfer failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Transfer Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    // ignore: unused_local_variable
    final _ = navigator;
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.phoneFrameBg,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(color: AppColors.clayShadowColor, blurRadius: 24, offset: Offset(0, -8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(LucideIcons.checkCircle, color: AppColors.primaryGreen, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "Transfer Sent!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              "LKR ${_amountController.text} sent via ${_selectedMethod == 'PICKUP' ? 'Pick-Up' : 'Delivery'}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.primaryGreen.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCC66),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text("Back to Home", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPhoneStep(),
                  _buildAmountStep(),
                  _buildMethodStep(),
                  _buildReviewStep(),
                  _buildPinStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          _iconBtn(LucideIcons.arrowLeft, _prevStep),
          const Expanded(
            child: Text(
              "Send Cash",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isDone = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone || isActive ? AppColors.primaryGreen : const Color(0xFFDDE8E3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < _steps.length - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Phone ─────────────────────────────────────────────────────────
  Widget _buildPhoneStep() {
    return _stepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle("Who are you sending to?", "Enter the recipient's phone number"),
          const SizedBox(height: 32),
          _buildClayLabel("Recipient Phone Number"),
          const SizedBox(height: 8),
          _buildClayField(
            controller: _phoneController,
            hint: "+94 7X XXX XXXX",
            keyboardType: TextInputType.phone,
            prefixIcon: LucideIcons.phone,
          ),
          const SizedBox(height: 40),
          _primaryBtn("Continue", () {
            if (_phoneController.text.trim().length >= 7) _nextStep();
          }),
        ],
      ),
    );
  }

  // ── Step 2: Amount ────────────────────────────────────────────────────────
  Widget _buildAmountStep() {
    return _stepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle("How much to send?", "Enter the amount in LKR"),
          const SizedBox(height: 32),
          _buildAmountInput(),
          const SizedBox(height: 16),
          _buildFeeNote(),
          const SizedBox(height: 40),
          _primaryBtn("Continue", () {
            final amount = double.tryParse(_amountController.text) ?? 0;
            if (amount > 0) _nextStep();
          }),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Column(
        children: [
          const Text("LKR", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryGreen, letterSpacing: 2)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primaryText),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "0.00",
              hintStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primaryGreen.withValues(alpha: 0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeNote() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = 10.0;
    final total = amount + fee;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _feeRow("Amount", "LKR ${amount.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _feeRow("Transfer Fee", "LKR ${fee.toStringAsFixed(2)}"),
          const Divider(height: 20, color: Color(0xFFDDE8E3)),
          _feeRow("Total", "LKR ${total.toStringAsFixed(2)}", bold: true),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.7), fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        Text(value, style: TextStyle(color: AppColors.primaryText, fontWeight: bold ? FontWeight.w900 : FontWeight.w600, fontSize: bold ? 16 : 14)),
      ],
    );
  }

  // ── Step 3: Method ────────────────────────────────────────────────────────
  Widget _buildMethodStep() {
    return _stepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle("Choose delivery method", "How should the recipient collect the cash?"),
          const SizedBox(height: 32),
          _buildMethodCard(
            id: 'PICKUP',
            icon: LucideIcons.mapPin,
            title: "Pick-Up",
            subtitle: "Recipient collects cash from a nearby GajaCash agent",
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            id: 'DELIVERY',
            icon: LucideIcons.bike,
            title: "Delivery",
            subtitle: "A delivery agent brings cash to recipient's doorstep",
          ),
          const SizedBox(height: 40),
          _primaryBtn("Continue", _selectedMethod.isNotEmpty ? _nextStep : null),
        ],
      ),
    );
  }

  Widget _buildMethodCard({required String id, required IconData icon, required String title, required String subtitle}) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.phoneFrameBg,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? null : Border.all(color: const Color(0xFFDDE8E3), width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))]
              : const [
                  BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12),
                  BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.primaryGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.primaryText)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : AppColors.primaryGreen.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (isSelected) const Icon(LucideIcons.checkCircle, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Step 4: Review ────────────────────────────────────────────────────────
  Widget _buildReviewStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _stepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle("Review Transfer", "Please confirm the details before sending"),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              ],
            ),
            child: Column(
              children: [
                _reviewRow("To", _phoneController.text, icon: LucideIcons.user),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("Method", _selectedMethod == 'PICKUP' ? "Pick-Up" : "Delivery",
                    icon: _selectedMethod == 'PICKUP' ? LucideIcons.mapPin : LucideIcons.bike),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("Amount", "LKR ${amount.toStringAsFixed(2)}", icon: LucideIcons.banknote),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("Fee", "LKR 10.00", icon: LucideIcons.info),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("Total", "LKR ${(amount + 10).toStringAsFixed(2)}", icon: LucideIcons.wallet, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _primaryBtn("Confirm & Enter PIN", _nextStep),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value, {required IconData icon, bool bold = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(color: AppColors.primaryText, fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontSize: bold ? 17 : 15)),
      ],
    );
  }

  // ── Step 5: PIN ───────────────────────────────────────────────────────────
  Widget _buildPinStep() {
    return _stepWrapper(
      child: Column(
        children: [
          _stepTitle("Enter your PIN", "Authorize this transfer with your 4-digit PIN"),
          const SizedBox(height: 40),
          _buildPinDots(),
          const SizedBox(height: 48),
          _buildNumpad(),
        ],
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (i) {
        final filled = i < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: filled ? 20 : 16,
          height: filled ? 20 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.15),
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: keys.map((k) {
        if (k.isEmpty) return const SizedBox();
        return GestureDetector(
          onTap: () {
            if (k == '⌫') {
              if (_pin.isNotEmpty) setState(() => _pin.removeLast());
            } else if (_pin.length < _pinLength) {
              setState(() => _pin.add(k));
              if (_pin.length == _pinLength) {
                Future.delayed(const Duration(milliseconds: 200), _submitTransfer);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
              ],
            ),
            child: Center(
              child: k == '⌫'
                  ? const Icon(LucideIcons.delete, color: AppColors.primaryGreen, size: 22)
                  : Text(k, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────
  Widget _stepWrapper({required Widget child}) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText, height: 1.2)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 14, color: AppColors.primaryGreen.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildClayLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
    );
  }

  Widget _buildClayField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.3), fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primaryGreen, size: 20) : null,
        ),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback? onTap) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap != null ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC66),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFCC66).withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: _isLoading
                ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryText)))
                : Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.phoneFrameBg,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
            BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 22),
      ),
    );
  }
}
