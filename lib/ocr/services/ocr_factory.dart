import '../../core/network/dio_client.dart';
import '../../domain/entities/ocr_provider_type.dart';
import '../providers/deepseek_ocr_provider.dart';
import '../providers/mock_ocr_provider.dart';
import '../providers/ocr_provider.dart';

class OcrFactory {
  OcrFactory(this._dioClient);

  final DioClient _dioClient;
  final _mock = MockOcrProvider();

  OcrProvider getProvider(OcrProviderType type) {
    return switch (type) {
      OcrProviderType.deepseek => DeepSeekOcrProvider(_dioClient),
      OcrProviderType.mock => _mock,
      OcrProviderType.huggingface => DeepSeekOcrProvider(_dioClient),
    };
  }

  OcrProvider get defaultProvider => getProvider(OcrProviderType.deepseek);
}
