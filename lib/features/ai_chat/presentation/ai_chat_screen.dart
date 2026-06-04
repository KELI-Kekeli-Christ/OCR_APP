import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ocr_mode.dart';
import '../../../domain/entities/scan_result.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, this.scan});

  final ScanResult? scan;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _messages = <({bool isUser, String text})>[];

  @override
  void initState() {
    super.initState();
    if (widget.scan != null) {
      _messages.add((
        isUser: false,
        text:
            'J\'ai analysé votre document (${widget.scan!.mode.label}). Posez-moi des questions sur le contenu extrait.',
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((isUser: true, text: text));
      _controller.clear();
    });

    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _messages.add((
          isUser: false,
          text: _generateReply(text),
        ));
      });
    });
  }

  String _generateReply(String question) {
    final doc = widget.scan?.text ?? '';
    if (doc.isEmpty) {
      return 'Scannez d\'abord un document pour activer le contexte IA.';
    }
    return 'Basé sur le document OCR (${doc.length} caractères) : '
        'voici une analyse concernant « $question ». '
        'Connectez un backend LLM pour des réponses complètes.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Chat'),
            if (widget.scan != null)
              Text(
                widget.scan!.title ?? 'Document actif',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AppColors.primary
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Posez une question sur le document...',
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
