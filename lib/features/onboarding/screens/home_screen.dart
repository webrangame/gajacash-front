import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/onboarding/screens/splash_screen.dart';
import 'package:gajacash_sample/features/registration/screens/agent_dashboard_selector_screen.dart';
import 'package:gajacash_sample/features/vault/screens/vault_screen.dart';
import 'package:gajacash_sample/features/transfer/screens/transfer_qr_screen.dart';
import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Vendor profile data model (replace with API call later) ───────────────
class _VendorProfile {
  final String name;
  final String gajaTag;
  final String location;
  final double rating;
  final String tier;
  final List<String> currencies;
  final bool cashEnabled;
  final bool giftCardEnabled;

  const _VendorProfile({
    required this.name,
    required this.gajaTag,
    required this.location,
    required this.rating,
    required this.tier,
    required this.currencies,
    required this.cashEnabled,
    required this.giftCardEnabled,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeNavIdx = 0;
  bool _isActionMode = false;
  int _msgIndex = 0;
  late Timer _bubbleTimer;
  double _balance = 0.0;
  bool _isBalanceLoading = false;

  // Vendor profile — populated from API in production
  final _VendorProfile _vendor = const _VendorProfile(
    name: 'Some kade',
    gajaTag: r'$GajaTag',
    location: 'Col 01',
    rating: 4.9,
    tier: 'Gold',
    currencies: ['LKR', 'USD'],
    cashEnabled: true,
    giftCardEnabled: false,
  );
  
  final List<String> _messages = [
    "What would you like to do today?",
    "Scan QR to pay instantly",
    "Send cash to friends",
    "Check your balance"
  ];

  @override
  void initState() {
    super.initState();
    _bubbleTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _msgIndex = (_msgIndex + 1) % _messages.length;
        });
      }
    });
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    final userId = ApiService.userId;
    if (userId == null) return;
    
    setState(() => _isBalanceLoading = true);
    try {
      final response = await ApiService().getBalance(userId);
      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _balance = (data['balance'] as num).toDouble();
        });
      }
    } catch (e) {
      debugPrint("Error fetching balance: $e");
    } finally {
      if (mounted) {
        setState(() => _isBalanceLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _bubbleTimer.cancel();
    super.dispose();
  }

  void _handleNavClick(int index) {
    if (index == 2) {
      if (!_isActionMode) {
        setState(() {
          _isActionMode = true;
          _activeNavIdx = 2;
        });
      }
    } else if (index == 0 || index == 1 || index == 3) {
      setState(() {
        _isActionMode = false;
        _activeNavIdx = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchBalance,
                        color: AppColors.primaryGreen,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                          child: Column(
                            children: [
                              _buildMascotSection(),
                              const SizedBox(height: 16),
                              _buildBalanceCard(),
                              const SizedBox(height: 20),
                              _buildVendorProfileCard(),
                              const SizedBox(height: 20),
                              _buildActionGrid(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Navigation
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: _buildBottomNav(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 32, right: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 32), // Spacer for balance
          const Text(
            "Home",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText),
          ),
          GestureDetector(
            onTap: _showLogoutDialog,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.phoneFrameBg,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                  BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                ],
              ),
              child: const Icon(LucideIcons.logOut, color: AppColors.primaryGreen, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.phoneFrameBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Logout",
          style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: AppColors.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotSection() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Speech Bubble
          Positioned(
            top: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 220,
                  height: 110,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.phoneFrameBg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
                      BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _messages[_msgIndex],
                      key: ValueKey(_msgIndex),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                // Bubble tail
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: CustomPaint(
                    size: const Size(20, 20),
                    painter: BubbleTailPainter(),
                  ),
                ),
              ],
            ),
          ),
          
          // Mascot Image
          Positioned(
            right: -20,
            bottom: 0,
            width: 230,
            child: SafeNetworkImage(
              url: "https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/46988f10-aac0-46de-95d1-0dea926ebd5e_3840w.png?w=800&q=80",
              height: 200,
              fit: BoxFit.contain,
              errorWidget: const SizedBox(height: 200, child: Icon(LucideIcons.smile, size: 80, color: AppColors.primaryGreen)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "GAJACASH BALANCE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              _isBalanceLoading
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryGreen),
                  )
                : Text(
                    "LKR ${_balance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryText,
                    ),
                  ),
            ],
          ),
          GestureDetector(
            onTap: _fetchBalance,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F4ED),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.white, offset: Offset(2, 2), blurRadius: 4),
                  BoxShadow(color: Colors.black12, offset: Offset(-2, -2), blurRadius: 4),
                ],
              ),
              child: const Icon(LucideIcons.refreshCw, color: AppColors.primaryGreen, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.phoneFrameBg,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Column(
        children: [
          // ── Shop icon + name + tag ──────────────────────────────────────
          Row(
            children: [
              // Store icon button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                  ],
                ),
                child: const Icon(LucideIcons.store, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _vendor.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _vendor.gajaTag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Location chip
              Row(
                children: [
                  Icon(LucideIcons.mapPin, size: 12,
                      color: AppColors.primaryText.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    _vendor.location,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Rating + Tier chips ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FAF7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                      BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _vendor.rating.toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star_rounded, color: Color(0xFFFBBC04), size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'RATING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen.withValues(alpha: 0.7),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FAF7),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: AppColors.clayShadowColor, offset: Offset(4, 4), blurRadius: 8),
                      BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _vendor.tier,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TIER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen.withValues(alpha: 0.7),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Divider ─────────────────────────────────────────────────────
          Divider(color: AppColors.primaryGreen.withValues(alpha: 0.08), height: 1),

          const SizedBox(height: 16),

          // ── Supported Currencies ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Supported Currencies',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText.withValues(alpha: 0.6),
                ),
              ),
              Row(
                children: _vendor.currencies.map((c) => Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    c,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Payout Methods ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout Methods',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText.withValues(alpha: 0.6),
                ),
              ),
              Row(
                children: [
                  _PayoutChip(
                    icon: LucideIcons.banknote,
                    label: 'Cash',
                    enabled: _vendor.cashEnabled,
                  ),
                  const SizedBox(width: 12),
                  _PayoutChip(
                    icon: LucideIcons.gift,
                    label: 'Gift Card',
                    enabled: _vendor.giftCardEnabled,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            icon: LucideIcons.scan,
            label: "Scan QR Code",
            bgColor: const Color(0xFFE8F4ED),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferQrScreen()));
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _ActionBtn(
            icon: LucideIcons.bike,
            label: "Agent Dashboard",
            bgColor: const Color(0xFFFFCC66),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AgentDashboardSelectorScreen()));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final navBgColor = _isActionMode ? AppColors.primaryGreen : AppColors.phoneFrameBg;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: navBgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: _isActionMode 
          ? [
              const BoxShadow(color: Color(0xFFB8C9C0), offset: Offset(8, 8), blurRadius: 16),
              const BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(4, 4), blurRadius: 12),
              BoxShadow(color: Colors.white.withValues(alpha: 0.1), offset: const Offset(-2, -2), blurRadius: 6),
            ]
          : const [
              BoxShadow(color: Color(0xFFC5D1CB), offset: Offset(8, 8), blurRadius: 16),
              BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
              BoxShadow(color: Colors.white, offset: Offset(4, 4), blurRadius: 8),
              BoxShadow(color: Colors.black12, offset: Offset(-4, -4), blurRadius: 8),
            ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavIcon(0, LucideIcons.home),
          _buildNavIcon(1, LucideIcons.pieChart),
          _buildMiddleActionNavIcon(),
          _buildNavIcon(3, LucideIcons.shield),
          _buildNavIcon(4, LucideIcons.chevronLeft),
        ],
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon) {
    bool isSelected = _activeNavIdx == index && !_isActionMode;
    
    Color iconColor;
    if (_isActionMode) {
      iconColor = const Color(0xFFE8F4ED);
    } else {
      iconColor = isSelected ? Colors.white : AppColors.primaryGreen;
    }

    return GestureDetector(
      onTap: () {
        if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgentDashboardSelectorScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VaultScreen()),
          );
        } else {
          _handleNavClick(index);
        }
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected ? const [
            BoxShadow(color: Colors.white24, offset: Offset(3, 3), blurRadius: 6),
            BoxShadow(color: Colors.black12, offset: Offset(-3, -3), blurRadius: 6),
          ] : null,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  Widget _buildMiddleActionNavIcon() {
    return GestureDetector(
      onTap: () => _handleNavClick(2),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _isActionMode ? AppColors.primaryGreen.withValues(alpha: 0.15) : AppColors.primaryGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
            const BoxShadow(color: Colors.white24, offset: Offset(4, 4), blurRadius: 8),
            const BoxShadow(color: Colors.black12, offset: Offset(-4, -4), blurRadius: 8),
          ],
        ),
        child: const Icon(LucideIcons.arrowUpDown, color: Colors.white, size: 32),
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC5D1CB),
                  offset: _isPressed ? const Offset(4, 4) : const Offset(8, 8),
                  blurRadius: _isPressed ? 8 : 16,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: _isPressed ? const Offset(-4, -4) : const Offset(-8, -8),
                  blurRadius: _isPressed ? 8 : 16,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4ED).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Carved look: light from top-left, so bottom-right is light, top-left is dark
                      const BoxShadow(color: Colors.white, offset: Offset(2, 2), blurRadius: 4),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: const Offset(-2, -2), blurRadius: 4),
                    ],
                  ),
                  child: Icon(widget.icon, color: AppColors.primaryGreen, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    height: 1.1,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PayoutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;

  const _PayoutChip({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: Row(
        children: [
          Icon(icon, size: 14,
              color: enabled ? AppColors.primaryGreen : AppColors.primaryText),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.phoneFrameBg
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
