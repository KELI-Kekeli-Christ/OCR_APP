abstract final class AppConstants {
  static const String appName = 'OCR';
  static const String appTagline = 'Intelligence visuelle premium';
  static const String deepSeekModelId = 'deepseek-ai/DeepSeek-OCR-2';
  static const Duration apiTimeout = Duration(seconds: 120);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const int maxImageDimension = 2048;
  static const int jpegQuality = 85;
  static const String hiveBoxScans = 'scans';
  static const String hiveBoxSettings = 'settings';
  static const String secureKeyApiToken = 'deepseek_api_token';
  static const String secureKeyBackendUrl = 'ocr_backend_url';
  static const String defaultBackendUrl = 'http://10.0.2.2:8000';
}
