import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/features/cashout/screens/vendor_cashout_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}
class _VaultScreenState extends State<VaultScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _name = "John Doe";
  String _phone = "@johndoe_gajatag";
  bool _isProfileLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchVaultData();
  }

  Future<void> _fetchVaultData() async {
    final userId = ApiService.userId;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
      _isProfileLoading = true;
    });
    
    try {
      final response = await _apiService.getUserProfile(userId);
      if (response.statusCode == 200) {
        final data = response.data;
        final fName = data['first_name'] ?? '';
        final lName = data['last_name'] ?? '';
        final phone = data['phone'] ?? '';
        setState(() {
          _name = "$fName $lName".trim();
          if (_name.isEmpty) _name = "GajaCash User";
          _phone = phone.isNotEmpty ? phone : "No Phone";
        });
      }
    } catch (e) {
      debugPrint("Error fetching vault data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProfileLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileSection(),
                            const SizedBox(height: 32),
                            _buildSectionTitle("Vault Actions"),
                            const SizedBox(height: 16),
                            _buildActionList(),
                            const SizedBox(height: 32),
                            _buildSectionTitle("Settings & Details"),
                            const SizedBox(height: 16),
                            _buildSettingsList(),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
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
            "Vault",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          const SizedBox(width: 44), // Spacer to center title
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              ],
            ),
            child: const Icon(LucideIcons.user, size: 48, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          _isProfileLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
              )
            : Column(
                children: [
                  Text(
                    _name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _phone,
                    style: TextStyle(fontSize: 16, color: AppColors.primaryGreen.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
    );
  }

  Widget _buildActionList() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          _buildListItem(LucideIcons.download, "Deposit Cash"),
          const Divider(height: 32, color: Color(0xFFC5D1CB)),
          _buildListItem(
            LucideIcons.upload, 
            "Withdraw to Bank",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VendorCashoutScreen()));
            },
          ),
          const Divider(height: 32, color: Color(0xFFC5D1CB)),
          _buildListItem(LucideIcons.history, "Transaction History"),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          _buildListItem(LucideIcons.lock, "Security & PIN"),
          const Divider(height: 32, color: Color(0xFFC5D1CB)),
          _buildListItem(LucideIcons.creditCard, "Linked Cards"),
          const Divider(height: 32, color: Color(0xFFC5D1CB)),
          _buildListItem(LucideIcons.helpCircle, "Help & Support"),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
          ),
          const Icon(LucideIcons.chevronRight, color: Color(0xFF90A49A), size: 20),
        ],
      ),
    );
  }
}
