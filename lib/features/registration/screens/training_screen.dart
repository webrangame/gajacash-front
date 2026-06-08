import 'package:gajacash_sample/core/widgets/safe_network_image.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:gajacash_sample/features/registration/screens/registration_review_screen.dart';
import 'package:gajacash_sample/features/registration/widgets/registration_stepper.dart';
import 'package:gajacash_sample/features/registration/widgets/requirements_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TrainingScreen extends StatefulWidget {
  final Map<String, dynamic> regData;
  const TrainingScreen({super.key, required this.regData});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String? _trainingUrl;
  String? _integrityUrl;
  bool _trainingCompleted = false;
  bool _integrityCompleted = false;
  bool _completingTraining = false;
  bool _completingIntegrity = false;

  @override
  void initState() {
    super.initState();
    _trainingUrl = widget.regData['training_completion_url'];
    _integrityUrl = widget.regData['integrity_test_url'];
    _trainingCompleted = _trainingUrl != null && _trainingUrl!.isNotEmpty;
    _integrityCompleted = _integrityUrl != null && _integrityUrl!.isNotEmpty;
  }

  Future<void> _simulateTrainingComplete(String fieldName) async {
    setState(() {
      if (fieldName == 'training_completion_url') _completingTraining = true;
      if (fieldName == 'integrity_test_url') _completingIntegrity = true;
    });

    try {
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/gajacash_dummy_$fieldName.jpg');
      await tempFile.writeAsString('gajacash_dummy_training_complete_content_for_$fieldName');

      final response = await ApiService().uploadFile(tempFile.path);
      if (response.statusCode == 200) {
        final url = response.data['url'];
        setState(() {
          if (fieldName == 'training_completion_url') {
            _trainingUrl = url;
            _trainingCompleted = true;
          }
          if (fieldName == 'integrity_test_url') {
            _integrityUrl = url;
            _integrityCompleted = true;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${fieldName == 'training_completion_url' ? 'Training' : 'Integrity test'} completed successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save completion status')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        if (fieldName == 'training_completion_url') _completingTraining = false;
        if (fieldName == 'integrity_test_url') _completingIntegrity = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationStepper(currentStep: 6),
            
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildMascotSection(),
                            const SizedBox(height: 32),
                            
                            // Agent Training Card
                            _buildTrainingCard(
                              title: "Agent Training",
                              subtitle: "Mandatory compliance & operational training.",
                              status: _completingTraining
                                  ? "COMPLETING..."
                                  : (_trainingCompleted ? "COMPLETED" : "NOT STARTED"),
                              isMandatory: true,
                              buttonLabel: _trainingCompleted ? "Completed" : "Start Training",
                              buttonIcon: _trainingCompleted ? LucideIcons.checkCircle : LucideIcons.play,
                              onTap: _trainingCompleted ? () {} : () => _simulateTrainingComplete("training_completion_url"),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Integrity Test Card
                            _buildTrainingCard(
                              title: "Integrity Test",
                              subtitle: "Completing this test helps us understand your decision-making and can improve your internal trust rating.",
                              status: _completingIntegrity
                                  ? "COMPLETING..."
                                  : (_integrityCompleted ? "COMPLETED" : "NOT STARTED"),
                              isMandatory: false,
                              buttonLabel: _integrityCompleted ? "Completed" : "Take Integrity Test",
                              buttonIcon: _integrityCompleted ? LucideIcons.checkCircle2 : LucideIcons.shieldCheck,
                              onTap: _integrityCompleted ? () {} : () => _simulateTrainingComplete("integrity_test_url"),
                              isOutlineButton: true,
                            ),
                            
                            const SizedBox(height: 120), // Space for bottom nav
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomNav(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMascotSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.clayShadowColor, offset: Offset(8, 8), blurRadius: 16),
          BoxShadow(color: Colors.white, offset: Offset(-8, -8), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          SafeNetworkImage(url:
            'https://hoirqrkdgbmvpwutwuwj.supabase.co/storage/v1/object/public/assets/assets/46988f10-aac0-46de-95d1-0dea926ebd5e_800w.png?w=800&q=80',
            width: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Training & Integrity",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                ),
                Text(
                  "Complete the mandatory training and optional integrity test.",
                  style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard({
    required String title,
    required String subtitle,
    required String status,
    required bool isMandatory,
    required String buttonLabel,
    required IconData buttonIcon,
    required VoidCallback onTap,
    bool isOutlineButton = false,
  }) {
    final completed = status == "COMPLETED";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: completed ? Colors.green.withValues(alpha: 0.1) : AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: completed ? Colors.green : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          if (!isMandatory)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Optional", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ),
            ),
          const SizedBox(height: 12),
          Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.primaryGreen.withValues(alpha: 0.7), height: 1.4)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: completed ? null : onTap,
              icon: Icon(buttonIcon, size: 20),
              label: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: completed
                    ? Colors.green
                    : (isOutlineButton ? Colors.white : AppColors.primaryGreen),
                foregroundColor: completed
                    ? Colors.white
                    : (isOutlineButton ? AppColors.primaryGreen : Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: (isOutlineButton && !completed)
                      ? const BorderSide(color: AppColors.primaryGreen)
                      : BorderSide.none,
                ),
                elevation: isOutlineButton ? 0 : 4,
                shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
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
            _navIconButton(LucideIcons.globe),
            const SizedBox(width: 8),
            _navIconButton(LucideIcons.arrowUpDown, isPrimary: true, onTap: () => showRequirementsModal(context)),
            const Expanded(child: SizedBox()),
            ElevatedButton(
              onPressed: () {
                widget.regData['training_completion_url'] = _trainingUrl ?? '';
                widget.regData['integrity_test_url'] = _integrityUrl ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationReviewScreen(regData: widget.regData)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC66),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
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
