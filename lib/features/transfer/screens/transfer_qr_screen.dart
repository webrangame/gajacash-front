import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gajacash_sample/core/api_service.dart';

class TransferQrScreen extends StatefulWidget {
  const TransferQrScreen({super.key});

  @override
  State<TransferQrScreen> createState() => _TransferQrScreenState();
}

class _TransferQrScreenState extends State<TransferQrScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController();
  bool _isScanning = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _simulateScan() {
    setState(() => _isScanning = false);
  }

  Future<void> _processPayment() async {
    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount'), backgroundColor: Colors.red),
      );
      return;
    }
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.processTransfer(
        recipientId: 'VENDOR_123',
        amount: amount,
        method: 'QR',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful!'), backgroundColor: AppColors.primaryGreen),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                Expanded(
                  child: _isScanning ? _buildScanner() : _buildPaymentDetails(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
              ],
            ),
            child: const Icon(LucideIcons.arrowLeft, color: AppColors.primaryGreen, size: 20),
          ),
        ),
        const Text(
          "Scan to Pay",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        ),
        const SizedBox(width: 44),
      ],
    );
  }

  Widget _buildScanner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _simulateScan,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.primaryGreen, width: 2),
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              ],
            ),
            child: const Center(
              child: Icon(LucideIcons.qrCode, size: 100, color: AppColors.primaryGreen),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text("Tap scanner to simulate successful scan", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Container(
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
                  const Icon(LucideIcons.store, size: 48, color: AppColors.primaryGreen),
                  const SizedBox(height: 16),
                  const Text("Pay to Merchant", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const Text("GajaCash Store", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixText: "LKR ",
                        hintText: "0.00",
                        hintStyle: TextStyle(fontSize: 24),
                        prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isLoading ? null : _processPayment,
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Confirm Payment", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
