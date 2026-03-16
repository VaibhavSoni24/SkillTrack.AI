import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/theme/app_colors.dart';

/// Avatar selection and upload widget.
class AvatarUploader extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final ValueChanged<String>? onImagePicked;
  final bool isLoading;

  const AvatarUploader({
    super.key,
    this.imageUrl,
    this.size = 100,
    this.onImagePicked,
    this.isLoading = false,
  });

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      onImagePicked?.call(result.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : _pickImage,
      child: Stack(
        children: [
          // Avatar image
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: imageUrl == null ? AppColors.primaryGradient : null,
              border: Border.all(
                color: AppColors.primaryLight,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _placeholder(),
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          // Edit overlay
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: size * 0.15,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.person,
        color: Colors.white.withValues(alpha: 0.7),
        size: size * 0.45,
      ),
    );
  }
}
