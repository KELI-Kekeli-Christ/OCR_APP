import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final FlutterSecureStorage _storage;

  Future<void> saveApiToken(String token) =>
      _storage.write(key: AppConstants.secureKeyApiToken, value: token);

  Future<String?> getApiToken() =>
      _storage.read(key: AppConstants.secureKeyApiToken);

  Future<void> saveBackendUrl(String url) =>
      _storage.write(key: AppConstants.secureKeyBackendUrl, value: url);

  Future<String?> getBackendUrl() =>
      _storage.read(key: AppConstants.secureKeyBackendUrl);

  Future<void> deleteAll() => _storage.deleteAll();
}
