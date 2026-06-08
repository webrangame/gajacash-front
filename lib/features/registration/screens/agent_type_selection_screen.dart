import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/registration/widgets/registration_stepper.dart';
import 'package:gajacash_sample/features/registration/screens/agent_details_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AgentTypeSelectionScreen extends StatefulWidget {
  const AgentTypeSelectionScreen({super.key});

  @override
  State<AgentTypeSelectionScreen> createState() => _AgentTypeSelectionScreenState();
}

class _AgentTypeSelectionScreenState extends State<AgentTypeSelectionScreen> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepper(currentStep: 1),
            
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildMascotSection(),
                        const SizedBox(height: 32),
                        
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildAgentCard(
                              id: "downgrade",
                              icon: LucideIcons.userMinus,
                              title: "Downgrade Account",
                            ),
                            _buildAgentCard(
                              id: "seettu",
                              icon: LucideIcons.briefcase,
                              title: "Seettu Agent",
                              isComingSoon: true,
                            ),
                            _buildAgentCard(
                              id: "vendor",
                              icon: LucideIcons.store,
                              title: "Vendor Agent",
                            ),
                            _buildAgentCard(
                              id: "delivery",
                              icon: LucideIcons.bike,
                              title: "Delivery Agent",
                            ),
                          ],
                        ),
                        
                        if (_selectedType != null) ...[
                          const SizedBox(height: 32),
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                final regData = {
                                  'user_id': ApiService.userId ?? '',
                                  'agent_type': _selectedType == 'delivery' ? 'DELIVERY_AGENT' : 'VENDOR_AGENT',
                                };
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AgentDetailsScreen(regData: regData)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFCC66),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 40),
                        _buildWhyJoinSection(),
                        const SizedBox(height: 40),
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


  Widget _buildMascotSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SafeNetworkImage(url:
          'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/46988f10-aac0-46de-95d1-0dea926ebd5e_800w.png?w=800&q=80',
          width: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hi! Join our network and start earning.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  "Flexible hours. Competitive pay. Select your option.",
                  style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard({
    required String id,
    required IconData icon,
    required String title,
    bool isComingSoon = false,
  }) {
    final isSelected = _selectedType == id;
    
    return GestureDetector(
      onTap: isComingSoon ? null : () => setState(() => _selectedType = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.phoneFrameBg,
          borderRadius: BorderRadius.circular(32),
          border: isSelected ? Border.all(color: AppColors.primaryGreen, width: 2) : null,
          boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 20)]
              : const [
                  BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                  BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
                ],
        ),
        child: Opacity(
          opacity: isComingSoon ? 0.5 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.phoneFrameBg,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                  ],
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
              ),
              if (isComingSoon) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "COMING SOON",
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black45),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhyJoinSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.info, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text("Why join?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            ],
          ),
          const SizedBox(height: 16),
          _whyJoinItem("Earn as you go. Set your own rates."),
          _whyJoinItem("Flexible schedule. Grow your earnings with trust tiers."),
          _whyJoinItem("Invest in yourself for bigger orders."),
          const SizedBox(height: 8),
          const Text(
            "Remember, trust is key!",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _whyJoinItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.primaryGreen.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
