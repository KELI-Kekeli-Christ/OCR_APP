enum OcrProviderType {
  deepseek,
  mock,
  huggingface,
}

extension OcrProviderTypeX on OcrProviderType {
  String get id => name;

  String get displayName => switch (this) {
        OcrProviderType.deepseek => 'DeepSeek OCR-2',
        OcrProviderType.mock => 'Démo (local)',
        OcrProviderType.huggingface => 'HuggingFace Inference',
      };
}
