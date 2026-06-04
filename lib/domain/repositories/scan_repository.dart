import '../entities/scan_result.dart';

abstract interface class ScanRepository {
  Future<void> save(ScanResult scan);
  Future<List<ScanResult>> getHistory();
  Future<List<ScanResult>> getFavorites();
  Future<void> delete(String id);
  Future<void> toggleFavorite(String id);
}
