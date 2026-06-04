import 'package:uuid/uuid.dart';
import '../../domain/entities/ocr_mode.dart';
import '../../domain/entities/ocr_request.dart';
import '../../domain/entities/scan_result.dart';
import 'ocr_provider.dart';

/// Provider de démonstration — fonctionne sans GPU ni backend.
class MockOcrProvider implements OcrProvider {
  static const _uuid = Uuid();

  @override
  String get providerId => 'mock';

  @override
  String get displayName => 'Démo locale';

  @override
  bool get supportsStreaming => true;

  @override
  bool get supportsMath => true;

  @override
  Future<bool> healthCheck() async => true;

  @override
  Future<ScanResult> recognize(OcrRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    final markdown = _demoMarkdown(request);
    return ScanResult(
      id: _uuid.v4(),
      text: markdown.replaceAll(RegExp(r'[#*$`\\]'), ''),
      markdown: markdown,
      latex: r'$$\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}$$',
      tables: const [
        '| Colonne A | Colonne B |\n|-----------|----------|\n| Donnée 1  | Donnée 2 |',
      ],
      mode: request.mode,
      createdAt: DateTime.now(),
      confidence: 0.97,
      providerId: providerId,
      title: 'Scan démo — ${request.mode.label}',
    );
  }

  @override
  Stream<String> recognizeStream(OcrRequest request) async* {
    const full = '# Document OCR\n\nTexte reconnu en **streaming**...\n';
    for (var i = 0; i < full.length; i += 8) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      yield full.substring(0, (i + 8).clamp(0, full.length));
    }
  }

  String _demoMarkdown(OcrRequest request) {
    return switch (request.mode) {
      _ => '''
# ${request.mode.label}

Contenu extrait par **DeepSeek-OCR-2** (mode démo).

## Équation

\$\$E = mc^2\$\$

## Tableau

| En-tête 1 | En-tête 2 |
|-----------|-----------|
| Valeur A  | Valeur B  |

> Configurez l'URL du backend dans **Paramètres** pour utiliser le vrai modèle.
''',
    };
  }
}
