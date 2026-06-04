import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/ocr_request.dart';
import '../../domain/entities/scan_result.dart';
import 'ocr_provider.dart';

/// Provider principal — appelle le backend FastAPI hébergeant DeepSeek-OCR-2.
class DeepSeekOcrProvider implements OcrProvider {
  DeepSeekOcrProvider(this._client);

  final DioClient _client;
  static const _uuid = Uuid();

  @override
  String get providerId => 'deepseek';

  @override
  String get displayName => 'DeepSeek OCR-2';

  @override
  bool get supportsStreaming => true;

  @override
  bool get supportsMath => true;

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ScanResult> recognize(OcrRequest request) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/v1/ocr',
        data: {
          'image_base64': base64Encode(request.imageBytes),
          'prompt': request.prompt,
          'model': AppConstants.deepSeekModelId,
          'mode': request.mode.name,
        },
      );

      final data = response.data;
      if (data == null) {
        throw OcrException('Réponse vide du serveur OCR');
      }

      final markdown = data['markdown'] as String? ?? data['text'] as String? ?? '';
      final text = data['text'] as String? ?? _stripMarkdown(markdown);
      final latex = data['latex'] as String?;
      final tables = (data['tables'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          _extractTables(markdown);
      final engine = data['engine'] as String? ?? providerId;

      return ScanResult(
        id: _uuid.v4(),
        text: text,
        markdown: markdown,
        latex: latex ?? _extractLatex(markdown),
        tables: tables,
        mode: request.mode,
        createdAt: DateTime.now(),
        confidence: (data['confidence'] as num?)?.toDouble(),
        providerId: engine,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['detail']?.toString() ??
          e.message ??
          'Erreur DeepSeek OCR';
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw OcrException('Timeout — le document est peut-être trop volumineux');
      }
      throw OcrException(msg, statusCode: e.response?.statusCode);
    }
  }

  @override
  Stream<String> recognizeStream(OcrRequest request) async* {
    final response = await _client.dio.post<ResponseBody>(
      '/v1/ocr/stream',
      data: {
        'image_base64': base64Encode(request.imageBytes),
        'prompt': request.prompt,
        'model': AppConstants.deepSeekModelId,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data?.stream;
    if (stream == null) return;

    await for (final chunk in stream) {
      yield utf8.decode(chunk, allowMalformed: true);
    }
  }

  String _stripMarkdown(String md) {
    return md
        .replaceAll(RegExp(r'[#*_`~\[\]()]'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String? _extractLatex(String markdown) {
    final matches = RegExp(r'\$\$?([^$]+)\$\$?').allMatches(markdown);
    if (matches.isEmpty) return null;
    return matches.map((m) => m.group(0)).join('\n');
  }

  List<String> _extractTables(String markdown) {
    final tablePattern = RegExp(
      r'(\|[^\n]+\|\n\|[-:| ]+\|\n(?:\|[^\n]+\|\n?)+)',
      multiLine: true,
    );
    return tablePattern.allMatches(markdown).map((m) => m.group(0)!).toList();
  }
}
