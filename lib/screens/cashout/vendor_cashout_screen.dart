import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:gajacash_sample/core/api_service.dart';

class VendorCashoutScreen extends StatefulWidget {
  const VendorCashoutScreen({super.key});

  @override
  State<VendorCashoutScreen> createState() => _VendorCashoutScreenState();
}

class _VendorCashoutScreenState extends State<VendorCashoutScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0=details, 1=review, 2=pin

  final _accountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedBank = 'Commercial Bank';
  bool _isLoading = false;

  // PIN
  final List<String> _pin = [];
  static const int _pinLength = 4;

  final List<String> _bankList = [
    'Commercial Bank',
    'Bank of Ceylon',
    'Peoples Bank',
    'Hatton National Bank',
    'Sampath Bank',
    'Nations Trust Bank',
    'Seylan Bank',
    'DFCC Bank',
  ];

  static const double _cashoutFeePercent = 1.0;

  @override
  void dispose() {
    _pageController.dispose();
    _accountController.dispose();
    _bankNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
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

  Future<void> _submitCashout() async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final response = await ApiService().vendorCashout(
        bankAccountId: _accountController.text.trim(),
        amount: double.tryParse(_amountController.text) ?? 0,
      );
      if (mounted) {
        if (response.statusCode == 200) {
          _showSuccessSheet();
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text(response.data['error'] ?? 'Cashout failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Cashout Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSheet() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = amount * _cashoutFeePercent / 100;
    final net = amount - fee;

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
            const SizedBox(height: 20),
            const Text(
              "Cashout Requested!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              "LKR ${net.toStringAsFixed(2)} will be credited to $_selectedBank",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.primaryGreen.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Processing time: 1–2 business days",
                style: TextStyle(fontSize: 12, color: AppColors.primaryGreen.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
              ),
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
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  _buildDetailsStep(),
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
              "Vendor Cashout",
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
    final labels = ['Details', 'Review', 'Confirm'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isDone = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDone || isActive ? AppColors.primaryGreen : const Color(0xFFDDE8E3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < labels.length - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Cashout Details ───────────────────────────────────────────────
  Widget _buildDetailsStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = amount * _cashoutFeePercent / 100;
    final net = amount - fee;

    return _stepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle("Cashout to Bank", "Enter the amount and your bank account details"),
          const SizedBox(height: 28),

          // Amount input
          _buildClayLabel("Cashout Amount"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                Text("LKR", style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.7), fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryText),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "0.00",
                      hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (amount > 0) ...[ 
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fee (${_cashoutFeePercent.toStringAsFixed(0)}%)", style: TextStyle(fontSize: 12, color: AppColors.primaryGreen.withValues(alpha: 0.6))),
                  Text("- LKR ${fee.toStringAsFixed(2)}", style: TextStyle(fontSize: 12, color: Colors.redAccent.withValues(alpha: 0.8), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("You'll receive", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  Text("LKR ${net.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryGreen)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Bank selector
          _buildClayLabel("Bank"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBank,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown, color: AppColors.primaryGreen, size: 20),
                items: _bankList.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)))).toList(),
                onChanged: (v) => setState(() => _selectedBank = v!),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Account number
          _buildClayLabel("Bank Account Number"),
          const SizedBox(height: 8),
          _buildClayField(
            controller: _accountController,
            hint: "Enter account number",
            keyboardType: TextInputType.number,
            prefixIcon: LucideIcons.creditCard,
          ),
          const SizedBox(height: 40),

          _primaryBtn("Review Cashout", () {
            final a = double.tryParse(_amountController.text) ?? 0;
            if (a > 0 && _accountController.text.trim().isNotEmpty) _nextStep();
          }),
        ],
      ),
    );
  }

  // ── Step 2: Review ────────────────────────────────────────────────────────
  Widget _buildReviewStep() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fee = amount * _cashoutFeePercent / 100;
    final net = amount - fee;

    return _stepWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle("Review Cashout", "Confirm your bank transfer details"),
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
                _reviewRow("Bank", _selectedBank, icon: LucideIcons.landmark),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("Account", _accountController.text, icon: LucideIcons.creditCard),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("Amount", "LKR ${amount.toStringAsFixed(2)}", icon: LucideIcons.banknote),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("Fee (${_cashoutFeePercent.toStringAsFixed(0)}%)", "- LKR ${fee.toStringAsFixed(2)}", icon: LucideIcons.percent),
                const Divider(height: 24, color: Color(0xFFDDE8E3)),
                _reviewRow("You Receive", "LKR ${net.toStringAsFixed(2)}", icon: LucideIcons.wallet, bold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCC66).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, color: Color(0xFFE6AC00), size: 18),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Funds credited in 1–2 business days after approval",
                    style: TextStyle(fontSize: 12, color: Color(0xFFB8860B), fontWeight: FontWeight.w500),
                  ),
                ),
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

  // ── Step 3: PIN ───────────────────────────────────────────────────────────
  Widget _buildPinStep() {
    return _stepWrapper(
      child: Column(
        children: [
          _stepTitle("Enter your PIN", "Authorize the cashout with your 4-digit PIN"),
          const SizedBox(height: 40),
          _buildPinDots(),
          const SizedBox(height: 48),
          _buildNumpad(),
          if (_isLoading) ...[ 
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.primaryGreen),
          ],
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
                Future.delayed(const Duration(milliseconds: 200), _submitCashout);
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
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen));
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
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
