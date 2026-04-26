import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/image_compress.dart';

/// Profil fotoğrafı seçme ve yükleme widget'ı
class ProfilePhotoPicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File?) onImageSelected;
  final Function(Uint8List?, String?)? onImageBytesSelected; // Web için
  final double size;
  final bool enabled;

  const ProfilePhotoPicker({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.onImageBytesSelected,
    this.size = 120,
    this.enabled = true,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // Web için
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          children: [
            // Profil fotoğrafı container
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(child: _buildImageContent(scheme)),
            ),

            // Düzenleme butonu
            if (widget.enabled)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isLoading ? null : _showImageSourceDialog,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: scheme.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

            // Loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        if (widget.enabled) ...[
          const SizedBox(height: 8),
          Text(
            'Profil fotoğrafı ekle',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent(ColorScheme scheme) {
    // Web'de bytes varsa onu göster
    if (kIsWeb && _selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    // Mobile'da file varsa onu göster
    if (!kIsWeb && _selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    }

    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      return Image.network(
        widget.initialImageUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: scheme.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(scheme);
        },
      );
    }

    return _buildPlaceholder(scheme);
  }

  Widget _buildPlaceholder(ColorScheme scheme) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.secondaryContainer],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: widget.size * 0.5,
        color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceBottomSheet(
        onCameraSelected: kIsWeb ? null : () => _pickImage(ImageSource.camera),
        onGallerySelected: () =>
            kIsWeb ? _pickImageWeb() : _pickImage(ImageSource.gallery),
        onRemoveSelected:
            (_selectedImage != null ||
                _selectedImageBytes != null ||
                widget.initialImageUrl != null)
            ? _removeImage
            : null,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Bottom sheet'i kapat

    setState(() => _isLoading = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Resmi sıkıştır
        final compressedFile = await ImageCompress.compressImage(
          File(pickedFile.path),
          maxWidth: 512,
          maxHeight: 512,
          quality: 85,
        );

        setState(() {
          _selectedImage = compressedFile;
          _selectedImageBytes = null; // Web bytes'ı temizle
        });
        widget.onImageSelected(compressedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImageWeb() async {
    Navigator.pop(context); // Bottom sheet'i kapat

    setState(() => _isLoading = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          // Web'de resmi sıkıştır
          final compressedBytes = await ImageCompress.compressImageWeb(
            file.bytes!,
            file.extension == 'png' ? 'image/png' : 'image/jpeg',
            maxDimension: 512,
            quality: 0.85,
          );

          setState(() {
            _selectedImageBytes = compressedBytes;
            _selectedImage = null; // Mobile file'ı temizle
          });

          // Web callback'i çağır
          if (widget.onImageBytesSelected != null) {
            widget.onImageBytesSelected!(compressedBytes, file.name);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeImage() {
    Navigator.pop(context); // Bottom sheet'i kapat
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
    });
    widget.onImageSelected(null);
    if (widget.onImageBytesSelected != null) {
      widget.onImageBytesSelected!(null, null);
    }
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback? onCameraSelected; // Web'de null olabilir
  final VoidCallback onGallerySelected;
  final VoidCallback? onRemoveSelected;

  const _ImageSourceBottomSheet({
    this.onCameraSelected,
    required this.onGallerySelected,
    this.onRemoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Başlık
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Profil Fotoğrafı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
          ),

          // Seçenekler
          if (onCameraSelected != null)
            _buildOption(
              context,
              icon: Icons.camera_alt_rounded,
              title: 'Kamera',
              subtitle: 'Yeni fotoğraf çek',
              onTap: onCameraSelected!,
            ),

          _buildOption(
            context,
            icon: Icons.photo_library_rounded,
            title: 'Galeri',
            subtitle: 'Mevcut fotoğraflardan seç',
            onTap: onGallerySelected,
          ),

          if (onRemoveSelected != null)
            _buildOption(
              context,
              icon: Icons.delete_rounded,
              title: 'Kaldır',
              subtitle: 'Profil fotoğrafını kaldır',
              onTap: onRemoveSelected!,
              isDestructive: true,
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final color = isDestructive ? scheme.error : scheme.onSurface;

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDestructive
              ? scheme.errorContainer
              : scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? scheme.onErrorContainer
              : scheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
      ),
      onTap: onTap,
    );
  }
}
