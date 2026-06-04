import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../domain/entities/ocr_mode.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key, this.modeName});

  final String? modeName;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _processing = false;
  late OcrMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = OcrMode.values.firstWhere(
      (m) => m.name == widget.modeName,
      orElse: () => OcrMode.document,
    );
  }

  Future<void> _pickAndScan(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (file == null || !mounted) return;

    setState(() => _processing = true);
    try {
      final bytes = await file.readAsBytes();
      final result = await ref.read(ocrServiceProvider).scan(
            imageBytes: Uint8List.fromList(bytes),
            mode: _mode,
          );
      await ref.read(scanRepositoryProvider).save(
            result.copyWith(imagePath: file.path, title: _mode.label),
          );
      if (mounted) {
        context.push(AppRoutes.result, extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur OCR: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan — ${_mode.label}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1035), AppColors.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 280,
                  height: 360,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent, width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.document_scanner_outlined,
                      size: 80,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cadrez votre document',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'DeepSeek-OCR-2',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              children: [
                GradientButton(
                  label: 'Prendre une photo',
                  icon: Icons.camera_alt,
                  isLoading: _processing,
                  onPressed: _processing
                      ? null
                      : () => _pickAndScan(ImageSource.camera),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _processing
                      ? null
                      : () => _pickAndScan(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choisir depuis la galerie'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
