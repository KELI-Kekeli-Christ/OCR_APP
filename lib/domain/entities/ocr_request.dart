import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'ocr_mode.dart';

class OcrRequest extends Equatable {
  const OcrRequest({
    required this.imageBytes,
    required this.mode,
    this.stream = false,
    this.customPrompt,
  });

  final Uint8List imageBytes;
  final OcrMode mode;
  final bool stream;
  final String? customPrompt;

  String get prompt => customPrompt ?? mode.deepSeekPrompt;

  @override
  List<Object?> get props => [imageBytes, mode, stream];
}
