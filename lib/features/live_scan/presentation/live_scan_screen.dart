import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ocr_mode.dart';

class LiveScanScreen extends ConsumerStatefulWidget {
  const LiveScanScreen({super.key});

  @override
  ConsumerState<LiveScanScreen> createState() => _LiveScanScreenState();
}

class _LiveScanScreenState extends ConsumerState<LiveScanScreen> {
  final _buffer = StringBuffer();
  bool _scanning = false;
  String _display = '';

  Future<void> _startLiveScan() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file == null) return;

    setState(() {
      _scanning = true;
      _buffer.clear();
      _display = '';
    });

    try {
      final bytes = await file.readAsBytes();
      await for (final chunk in ref.read(ocrServiceProvider).scanStream(
            imageBytes: Uint8List.fromList(bytes),
            mode: OcrMode.document,
          )) {
        _buffer.write(chunk);
        if (mounted) {
          setState(() => _display = _buffer.toString());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Streaming: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Scan'),
        actions: [
          if (_display.isNotEmpty)
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Terminer'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _scanning ? AppColors.accent : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: _scanning
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.accent),
                          SizedBox(height: 16),
                          Text('Reconnaissance en streaming...'),
                        ],
                      )
                    : const Icon(
                        Icons.radar,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _display.isEmpty
                      ? 'Le texte apparaîtra ici en temps réel...'
                      : _display,
                  style: TextStyle(
                    color: _display.isEmpty
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _scanning ? null : _startLiveScan,
              icon: const Icon(Icons.play_arrow),
              label: Text(_scanning ? 'Analyse...' : 'Démarrer Live Scan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
