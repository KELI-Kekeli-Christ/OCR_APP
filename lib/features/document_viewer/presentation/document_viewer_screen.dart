import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/scan_result.dart';

class DocumentViewerScreen extends StatelessWidget {
  const DocumentViewerScreen({super.key, this.scan});

  final ScanResult? scan;

  @override
  Widget build(BuildContext context) {
    if (scan == null) {
      return const Scaffold(body: Center(child: Text('Document introuvable')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(scan!.title ?? 'Document')),
      body: Row(
        children: [
          if (scan!.imagePath != null)
            Expanded(
              flex: 2,
              child: Container(
                color: AppColors.surface,
                child: Image.file(
                  File(scan!.imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child: Markdown(
              data: scan!.markdown,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
