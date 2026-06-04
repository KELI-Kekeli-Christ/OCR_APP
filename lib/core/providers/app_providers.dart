import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/scan_local_datasource.dart';
import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/entities/ocr_provider_type.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../ocr/services/ocr_factory.dart';
import '../../ocr/services/ocr_service.dart';
import '../network/dio_client.dart';
import '../security/secure_storage_service.dart';
import '../services/export_service.dart';
import '../services/tts_service.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final ocrFactoryProvider = Provider<OcrFactory>(
  (ref) => OcrFactory(ref.watch(dioClientProvider)),
);

final ocrProviderTypeProvider = StateProvider<OcrProviderType>(
  (ref) => OcrProviderType.deepseek,
);

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService(
    ref.watch(ocrFactoryProvider),
    defaultType: ref.watch(ocrProviderTypeProvider),
  );
  ref.listen(ocrProviderTypeProvider, (_, next) {
    service.setProvider(next);
  });
  return service;
});

final scanLocalDatasourceProvider = Provider<ScanLocalDatasource>(
  (ref) => ScanLocalDatasource(),
);

final scanRepositoryProvider = Provider<ScanRepository>(
  (ref) => ScanRepositoryImpl(ref.watch(scanLocalDatasourceProvider)),
);

final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(),
);

final ttsServiceProvider = Provider<TtsService>((ref) => TtsService());

final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

final studentModeProvider = StateProvider<bool>((ref) => false);

final cloudSyncEnabledProvider = StateProvider<bool>((ref) => false);
