import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';

class ImageSourceDialog extends StatelessWidget {
  final Function(ImageSource) onImageSourceSelected;

  const ImageSourceDialog({super.key, required this.onImageSourceSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardLight : AppColors.cardLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analyze with AI',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an image source',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSourceButton(
                context,
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                source: ImageSource.camera,
                isDark: isDark,
              ),
              _buildSourceButton(
                context,
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                source: ImageSource.gallery,
                isDark: isDark,
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildSourceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ImageSource source,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onImageSourceSelected(source);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
