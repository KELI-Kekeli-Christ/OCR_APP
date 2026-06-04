import 'package:flutter/foundation.dart';
import '../../core/cache/image_compressor.dart';
import '../../domain/entities/ocr_mode.dart';
import '../../domain/entities/ocr_provider_type.dart';
import '../../domain/entities/ocr_request.dart';
import '../../domain/entities/scan_result.dart';
import 'ocr_factory.dart';

class OcrService {
  OcrService(this._factory, {OcrProviderType? defaultType})
      : _providerType = defaultType ?? OcrProviderType.deepseek;

  final OcrFactory _factory;
  OcrProviderType _providerType;

  OcrProviderType get currentProvider => _providerType;

  void setProvider(OcrProviderType type) => _providerType = type;

  Future<ScanResult> scan({
    required Uint8List imageBytes,
    required OcrMode mode,
    bool compress = true,
  }) async {
    final processed = compress
        ? await compute(compressImageBytes, imageBytes)
        : imageBytes;

    final request = OcrRequest(imageBytes: processed, mode: mode);
    return _factory.getProvider(_providerType).recognize(request);
  }

  Stream<String> scanStream({
    required Uint8List imageBytes,
    required OcrMode mode,
  }) async* {
    final processed = await compute(compressImageBytes, imageBytes);
    final request = OcrRequest(imageBytes: processed, mode: mode, stream: true);
    final provider = _factory.getProvider(_providerType);
    yield* provider.recognizeStream(request);
  }

  Future<bool> checkHealth() =>
      _factory.getProvider(_providerType).healthCheck();
}
