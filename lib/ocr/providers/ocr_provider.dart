import '../../domain/entities/ocr_request.dart';
import '../../domain/entities/scan_result.dart';

/// Contrat SOLID — tous les moteurs OCR implémentent cette interface.
abstract interface class OcrProvider {
  String get providerId;
  String get displayName;
  bool get supportsStreaming;
  bool get supportsMath;

  Future<ScanResult> recognize(OcrRequest request);

  Stream<String> recognizeStream(OcrRequest request) {
    throw UnimplementedError('Streaming non supporté par $providerId');
  }

  Future<bool> healthCheck();
}
