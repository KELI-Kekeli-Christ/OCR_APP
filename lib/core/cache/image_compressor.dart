import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';

/// Compression d'images dans un isolate (appelé via compute).
Uint8List compressImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  var image = decoded;
  final maxDim = AppConstants.maxImageDimension;
  if (image.width > maxDim || image.height > maxDim) {
    if (image.width >= image.height) {
      image = img.copyResize(image, width: maxDim);
    } else {
      image = img.copyResize(image, height: maxDim);
    }
  }
  return Uint8List.fromList(
    img.encodeJpg(image, quality: AppConstants.jpegQuality),
  );
}
