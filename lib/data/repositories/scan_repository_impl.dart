import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_local_datasource.dart';
import '../models/scan_result_model.dart';

class ScanRepositoryImpl implements ScanRepository {
  ScanRepositoryImpl(this._local);

  final ScanLocalDatasource _local;

  @override
  Future<void> save(ScanResult scan) =>
      _local.save(ScanResultModel.fromEntity(scan));

  @override
  Future<List<ScanResult>> getHistory() async {
    final models = await _local.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ScanResult>> getFavorites() async {
    final models = await _local.getFavorites();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> delete(String id) => _local.delete(id);

  @override
  Future<void> toggleFavorite(String id) => _local.toggleFavorite(id);
}
