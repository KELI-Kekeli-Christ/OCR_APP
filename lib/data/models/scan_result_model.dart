import '../../domain/entities/ocr_mode.dart';
import '../../domain/entities/scan_result.dart';

class ScanResultModel {
  ScanResultModel({
    required this.id,
    required this.text,
    required this.markdown,
    required this.mode,
    required this.createdAt,
    this.imagePath,
    this.latex,
    this.tables = const [],
    this.confidence,
    this.isFavorite = false,
    this.title,
    this.providerId = 'deepseek',
  });

  final String id;
  final String text;
  final String markdown;
  final String? latex;
  final List<String> tables;
  final String mode;
  final String createdAt;
  final String? imagePath;
  final double? confidence;
  final bool isFavorite;
  final String? title;
  final String providerId;

  factory ScanResultModel.fromEntity(ScanResult e) => ScanResultModel(
        id: e.id,
        text: e.text,
        markdown: e.markdown,
        latex: e.latex,
        tables: e.tables,
        mode: e.mode.name,
        createdAt: e.createdAt.toIso8601String(),
        imagePath: e.imagePath,
        confidence: e.confidence,
        isFavorite: e.isFavorite,
        title: e.title,
        providerId: e.providerId,
      );

  ScanResult toEntity() => ScanResult(
        id: id,
        text: text,
        markdown: markdown,
        latex: latex,
        tables: tables,
        mode: OcrMode.values.firstWhere(
          (m) => m.name == mode,
          orElse: () => OcrMode.document,
        ),
        createdAt: DateTime.parse(createdAt),
        imagePath: imagePath,
        confidence: confidence,
        isFavorite: isFavorite,
        title: title,
        providerId: providerId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'markdown': markdown,
        'latex': latex,
        'tables': tables,
        'mode': mode,
        'createdAt': createdAt,
        'imagePath': imagePath,
        'confidence': confidence,
        'isFavorite': isFavorite,
        'title': title,
        'providerId': providerId,
      };

  factory ScanResultModel.fromJson(Map<dynamic, dynamic> json) =>
      ScanResultModel(
        id: json['id'] as String,
        text: json['text'] as String,
        markdown: json['markdown'] as String,
        latex: json['latex'] as String?,
        tables: (json['tables'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        mode: json['mode'] as String,
        createdAt: json['createdAt'] as String,
        imagePath: json['imagePath'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble(),
        isFavorite: json['isFavorite'] as bool? ?? false,
        title: json['title'] as String?,
        providerId: json['providerId'] as String? ?? 'deepseek',
      );
}
