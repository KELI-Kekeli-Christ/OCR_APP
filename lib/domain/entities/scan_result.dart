import 'package:equatable/equatable.dart';
import 'ocr_mode.dart';

class ScanResult extends Equatable {
  const ScanResult({
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
  final OcrMode mode;
  final DateTime createdAt;
  final String? imagePath;
  final double? confidence;
  final bool isFavorite;
  final String? title;
  final String providerId;

  ScanResult copyWith({
    String? text,
    String? markdown,
    String? latex,
    List<String>? tables,
    bool? isFavorite,
    String? title,
    String? imagePath,
  }) {
    return ScanResult(
      id: id,
      text: text ?? this.text,
      markdown: markdown ?? this.markdown,
      latex: latex ?? this.latex,
      tables: tables ?? this.tables,
      mode: mode,
      createdAt: createdAt,
      imagePath: imagePath ?? this.imagePath,
      confidence: confidence,
      isFavorite: isFavorite ?? this.isFavorite,
      title: title ?? this.title,
      providerId: providerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        markdown,
        mode,
        createdAt,
        isFavorite,
      ];
}
