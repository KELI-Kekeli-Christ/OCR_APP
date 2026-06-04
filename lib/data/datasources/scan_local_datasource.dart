import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/scan_result_model.dart';

class ScanLocalDatasource {
  Box<dynamic>? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox(AppConstants.hiveBoxScans);
  }

  Future<void> save(ScanResultModel scan) async {
    await init();
    await _box!.put(scan.id, scan.toJson());
  }

  Future<List<ScanResultModel>> getAll() async {
    await init();
    return _box!.values
        .map((v) => ScanResultModel.fromJson(Map<dynamic, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<ScanResultModel>> getFavorites() async {
    final all = await getAll();
    return all.where((s) => s.isFavorite).toList();
  }

  Future<void> delete(String id) async {
    await init();
    await _box!.delete(id);
  }

  Future<void> toggleFavorite(String id) async {
    await init();
    final raw = _box!.get(id);
    if (raw == null) return;
    final model = ScanResultModel.fromJson(Map<dynamic, dynamic>.from(raw as Map));
    await save(
      ScanResultModel(
        id: model.id,
        text: model.text,
        markdown: model.markdown,
        latex: model.latex,
        tables: model.tables,
        mode: model.mode,
        createdAt: model.createdAt,
        imagePath: model.imagePath,
        confidence: model.confidence,
        isFavorite: !model.isFavorite,
        title: model.title,
        providerId: model.providerId,
      ),
    );
  }
}
