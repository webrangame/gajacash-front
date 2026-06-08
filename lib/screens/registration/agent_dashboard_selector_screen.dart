import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/screens/registration/agent_details_screen.dart';
import 'package:gajacash_sample/screens/vault/vault_screen.dart';
import 'package:gajacash_sample/widgets/safe_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Matches: vendoragent-registration/agent-dashboard-selector.html
///
/// Two cards:
///   1. Delivery Agent  → full registration flow
///   2. Vendor Agent    → vendor cashout / dashboard (already registered)
class AgentDashboardSelectorScreen extends StatefulWidget {
  const AgentDashboardSelectorScreen({super.key});

  @override
  State<AgentDashboardSelectorScreen> createState() =>
      _AgentDashboardSelectorScreenState();
}

class _AgentDashboardSelectorScreenState
    extends State<AgentDashboardSelectorScreen> {
  // ── helpers ─────────────────────────────────────────────────────────────────
  void _goDeliveryAgent() {
    final regData = {
      'user_id': ApiService.userId ?? '',
      'agent_type': 'DELIVERY_AGENT',
    };
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AgentDetailsScreen(regData: regData)),
    );
  }

  void _goVendorAgent() {
    final regData = {
      'user_id': ApiService.userId ?? '',
      'agent_type': 'VENDOR_AGENT',
    };
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AgentDetailsScreen(regData: regData)),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── scrollable body ──────────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMascotBubble(),
                      const SizedBox(height: 28),
                      _buildCardGrid(),
                    ],
                  ),
                ),
              ),
            ),

            // ── bottom nav ───────────────────────────────────────────────────
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mascot + Speech Bubble ───────────────────────────────────────────────────
  Widget _buildMascotBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SafeNetworkImage(
          url: 'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/6f68c9c3-89e5-4d65-89c8-ac7943ad2a0f_3840w.png',
          width: 64,
          height: 64,
          fit: BoxFit.contain,
          errorWidget: const Icon(LucideIcons.smile,
              color: AppColors.primaryGreen, size: 48),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.phoneFrameBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                    color: AppColors.clayShadowColor,
                    offset: Offset(8, 8),
                    blurRadius: 16),
                BoxShadow(
                    color: Colors.white,
                    offset: Offset(-8, -8),
                    blurRadius: 16),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose your agent role to continue.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 2×2 card grid ───────────────────────────────────────────────────────────
  Widget _buildCardGrid() {
    return Row(
      children: [
        Expanded(
          child: _AgentCard(
            icon: LucideIcons.bike,
            title: 'Delivery\nAgent',
            isActive: true,
            onTap: _goDeliveryAgent,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _AgentCard(
            icon: LucideIcons.store,
            title: 'Vendor\nAgent',
            isActive: true,
            onTap: _goVendorAgent,
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav (claymorphism) ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
              color: Color(0xFFC5D1CB), offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(LucideIcons.home, isActive: false,
              onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
          _navBtn(LucideIcons.pieChart, isActive: true, onTap: null),
          // Centre action button
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 10),
                    blurRadius: 20),
              ],
            ),
            child: const Icon(LucideIcons.arrowUpDown,
                color: Colors.white, size: 32),
          ),
          _navBtn(LucideIcons.shield, isActive: false,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const VaultScreen()))),
          _navBtn(LucideIcons.chevronLeft, isActive: false,
              onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon,
      {required bool isActive, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: isActive ? Colors.white : AppColors.primaryGreen, size: 24),
      ),
    );
  }
}

// ── Agent Card widget ────────────────────────────────────────────────────────
class _AgentCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const _AgentCard({
    required this.icon,
    required this.title,
    required this.isActive,
    this.onTap,
  });

  @override
  State<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends State<_AgentCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.isActive
          ? setState(() => _pressed = true)
          : null,
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AspectRatio(
          aspectRatio: 1,
          child: Opacity(
            opacity: widget.isActive ? 1.0 : 0.45,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.phoneFrameBg,
                borderRadius: BorderRadius.circular(40),
                boxShadow: widget.isActive
                    ? const [
                        BoxShadow(
                            color: AppColors.clayShadowColor,
                            offset: Offset(8, 8),
                            blurRadius: 16),
                        BoxShadow(
                            color: Colors.white,
                            offset: Offset(-8, -8),
                            blurRadius: 16),
                      ]
                    : null,
                border: widget.isActive
                    ? null
                    : Border.all(
                        color: const Color(0xFFB0B0B0),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Icon circle ──────────────────────────────────────────
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.phoneFrameBg,
                      shape: BoxShape.circle,
                      boxShadow: widget.isActive
                          ? const [
                              BoxShadow(
                                  color: AppColors.clayShadowColor,
                                  offset: Offset(4, 4),
                                  blurRadius: 8,
                                  spreadRadius: -2),
                              BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: -2),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isActive
                          ? AppColors.primaryGreen
                          : const Color(0xFFB0B0B0),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Label ────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isActive
                            ? AppColors.primaryText
                            : const Color(0xFFB0B0B0),
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

