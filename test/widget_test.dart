import 'package:flutter_test/flutter_test.dart';
import 'package:ocr/domain/entities/ocr_mode.dart';

void main() {
  test('OcrMode math prompt preserves LaTeX', () {
    expect(OcrMode.math.deepSeekPrompt, contains('LaTeX'));
  });

  test('OcrMode document uses grounding markdown', () {
    expect(
      OcrMode.document.deepSeekPrompt,
      contains('Convert the document to markdown'),
    );
  });
}
