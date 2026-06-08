import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ApplicationStatusScreen extends StatefulWidget {
  const ApplicationStatusScreen({super.key});

  @override
  State<ApplicationStatusScreen> createState() => _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState extends State<ApplicationStatusScreen> {
  Map<String, dynamic>? _kycData;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService().getAgentKYC(ApiService.userId ?? '');
      if (response.statusCode == 200) {
        setState(() {
          _kycData = response.data;
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load application status";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Application Status",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
              ),
            ),
            
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : (_errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchStatus,
                                child: const Text("Retry"),
                              )
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  _buildHeaderCard(),
                                  const SizedBox(height: 32),
                                  _buildStatusTrackingCard(),
                                  const SizedBox(height: 32),
                                  _buildCheckStatusButton(),
                                  const SizedBox(height: 120), // Space for bottom nav
                                ],
                              ),
                            ),
                          ),
                        )),
            ),
            
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }


  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0xFFC5D1CB), offset: Offset(8, 8), blurRadius: 24),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 24),
        ],
      ),
      child: Row(
        children: [
          SafeNetworkImage(url:
            'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/f5b4b9b6-fc99-41c2-b07a-7412e30826e0_3840w.png',
            width: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Application Tracking",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
                Text(
                  "Track the status of your application.",
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTrackingCard() {
    final kyc = _kycData;
    final statusStr = kyc != null ? kyc['status'] as String? ?? 'PENDING' : 'PENDING';
    final refNum = kyc != null && kyc['id'] != null ? "Ref: AG-${kyc['id'].toString().substring(0, 6).toUpperCase()}" : "Ref: AG-PENDING";

    Color statusColor = const Color(0xFFFFCC66);
    Color statusTextColor = const Color(0xFFB38F47);
    String statusLabel = "In Review";

    if (statusStr == "APPROVED") {
      statusColor = Colors.green;
      statusTextColor = Colors.green.shade800;
      statusLabel = "Approved";
    } else if (statusStr == "REJECTED") {
      statusColor = Colors.red;
      statusTextColor = Colors.red.shade800;
      statusLabel = "Rejected";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: const [
          BoxShadow(color: Color(0xFFC5D1CB), offset: Offset(4, 4), blurRadius: 12),
          BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Application Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                    Text(refNum, style: TextStyle(fontSize: 12, color: AppColors.primaryGreen.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.circle, size: 6, color: statusColor),
                    const SizedBox(width: 6),
                    Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusTextColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildTimelineStep(
            title: "Application Submitted",
            timestamp: kyc != null && kyc['created_at'] != null 
                ? kyc['created_at'].toString().split('T')[0] 
                : "Just now",
            isCompleted: true,
            isFirst: true,
          ),
          _buildTimelineStep(
            title: "Documents Verified",
            timestamp: statusStr == "APPROVED" || statusStr == "REJECTED" ? "Completed" : "In Progress",
            isCompleted: statusStr == "APPROVED" || statusStr == "REJECTED",
            isActive: statusStr == "PENDING",
          ),
          _buildTimelineStep(
            title: "Final Review",
            timestamp: statusStr == "APPROVED" ? "Completed" : (statusStr == "REJECTED" ? "Rejected" : "Pending"),
            description: statusStr == "REJECTED" ? "Verification failed." : "Background verification ongoing.",
            isCompleted: statusStr == "APPROVED",
            isActive: statusStr == "PENDING",
          ),
          _buildTimelineStep(
            title: "Activation",
            timestamp: statusStr == "APPROVED" ? "Active" : "Pending",
            isCompleted: statusStr == "APPROVED",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String timestamp,
    String? description,
    bool isCompleted = false,
    bool isActive = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primaryGreen : Colors.white,
                  shape: BoxShape.circle,
                  border: isCompleted ? null : Border.all(color: isActive ? const Color(0xFFFFCC66) : AppColors.primaryGreen.withValues(alpha: 0.1), width: 2),
                  boxShadow: isActive ? [
                    BoxShadow(color: const Color(0xFFFFCC66).withValues(alpha: 0.3), blurRadius: 8),
                  ] : null,
                ),
                child: isCompleted ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : (isActive ? const Center(child: Icon(LucideIcons.circle, size: 8, color: Color(0xFFFFCC66))) : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.primaryGreen : AppColors.primaryGreen.withValues(alpha: 0.1),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: (isCompleted || isActive) ? AppColors.primaryText : AppColors.primaryText.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive ? const Color(0xFFE6A700) : AppColors.primaryGreen.withValues(alpha: 0.4),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: AppColors.primaryGreen.withValues(alpha: 0.6)),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckStatusButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
            BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _fetchStatus,
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          label: const Text("Check Status", style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          _navIconButton(LucideIcons.chevronLeft, onTap: () => Navigator.pop(context)),
          const SizedBox(width: 8),
          _navIconButton(LucideIcons.pieChart),
          const SizedBox(width: 8),
          _navIconButton(LucideIcons.arrowUpDown, isPrimary: true),
          const Expanded(child: SizedBox()),
          ElevatedButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.phoneFrameBg,
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _navIconButton(IconData icon, {VoidCallback? onTap, bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : AppColors.primaryGreen, size: 22),
      ),
    );
  }
}
