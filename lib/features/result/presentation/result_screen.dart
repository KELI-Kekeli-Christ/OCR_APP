import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/export_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/scan_result.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, this.scan});

  final ScanResult? scan;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = widget.scan;
    if (scan == null) {
      return const Scaffold(
        body: Center(child: Text('Aucun résultat')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(scan.title ?? 'Résultat OCR'),
            Text(
              'Moteur: ${scan.providerId}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: scan.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Texte copié')),
              );
            },
          ),
          PopupMenuButton<ExportFormat>(
            icon: const Icon(Icons.download_outlined),
            onSelected: (f) => _export(scan, f),
            itemBuilder: (_) => const [
              PopupMenuItem(value: ExportFormat.txt, child: Text('TXT')),
              PopupMenuItem(
                value: ExportFormat.markdown,
                child: Text('Markdown'),
              ),
              PopupMenuItem(value: ExportFormat.pdf, child: Text('PDF')),
              PopupMenuItem(value: ExportFormat.docx, child: Text('DOCX')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            onPressed: () async {
              await ref.read(ttsServiceProvider).init();
              await ref.read(ttsServiceProvider).speak(scan.text);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () =>
                ref.read(exportServiceProvider).shareText(scan.markdown),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Markdown'),
            Tab(text: 'Math'),
            Tab(text: 'Brut'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          Markdown(
            data: scan.markdown,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          _MathTab(latex: scan.latex, markdown: scan.markdown),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(scan.text),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.push(AppRoutes.document, extra: scan),
                  child: const Text('Voir document'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      context.push(AppRoutes.aiChat, extra: scan),
                  child: const Text('AI Chat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export(ScanResult scan, ExportFormat format) async {
    try {
      final path = await ref.read(exportServiceProvider).export(scan, format);
      await ref.read(exportServiceProvider).shareFile(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export: $e')),
        );
      }
    }
  }
}

class _MathTab extends StatelessWidget {
  const _MathTab({this.latex, required this.markdown});

  final String? latex;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final equations = <String>[];
    if (latex != null) equations.add(latex!);
    final matches = RegExp(r'\$\$?([^$]+)\$\$?').allMatches(markdown);
    for (final m in matches) {
      if (m.group(0) != null) equations.add(m.group(0)!);
    }

    if (equations.isEmpty) {
      return const Center(
        child: Text('Aucune équation LaTeX détectée'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: equations.length,
      itemBuilder: (_, i) {
        final eq = equations[i].replaceAll(RegExp(r'^\$+|\$+$'), '');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Math.tex(
              eq,
              textStyle: const TextStyle(fontSize: 18),
              onErrorFallback: (_) => Text(equations[i]),
            ),
          ),
        );
      },
    );
  }
}
