import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gajacash_sample/core/api_service.dart';
import 'package:gajacash_sample/core/theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows a bottom-sheet with Camera / Gallery options, uploads the selected
/// file, and returns the remote URL string (or null if cancelled/failed).
/// [setLoading] is called with true/false only around the actual HTTP upload.
Future<String?> pickAndUploadDocument(BuildContext context, {String label = 'Document', ValueChanged<bool>? setLoading}) async {
  // Show picker source selection
  final ImageSource? source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.phoneFrameBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text(
                'Upload $label',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SourceTile(
                      icon: LucideIcons.camera,
                      label: 'Camera',
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SourceTile(
                      icon: LucideIcons.images,
                      label: 'Gallery',
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );

  if (source == null) return null; // User dismissed

  // Pick image
  final picker = ImagePicker();
  final XFile? file = await picker.pickImage(
    source: source,
    imageQuality: 85,
    maxWidth: 1920,
  );

  if (file == null) return null; // User cancelled camera/gallery

  // Upload to backend
  try {
    final response = await ApiService().uploadFile(file.path);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final url = response.data['url'] as String?;
      return url;
    }
  } catch (e) {
    debugPrint('Upload failed: $e');
  }
  return null;
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: AppColors.clayShadowColor, offset: Offset(6, 6), blurRadius: 12),
            BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
