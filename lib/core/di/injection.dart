import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

import 'injection.config.dart';
import '../barcode/barcode_scanner.dart';
import '../../features/scanning/data/clients/open_food_facts_client.dart';
import '../../features/scanning/data/repositories/barcode_repository_impl.dart';
import '../../features/scanning/domain/repositories/barcode_repository.dart';
import '../../features/scanning/data/cache/off_cache.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(generateForDir: ['lib'])
Future<void> configureDependencies() async {
  await getIt.init();
  // Manual registrations for new services when codegen is not run yet.
  if (!getIt.isRegistered<http.Client>()) {
    getIt.registerLazySingleton<http.Client>(() => http.Client());
  }
  if (!getIt.isRegistered<BarcodeScannerService>()) {
    getIt.registerLazySingleton<BarcodeScannerService>(
      () => MlKitBarcodeScannerService(),
    );
  }
  if (!getIt.isRegistered<OpenFoodFactsClient>()) {
    getIt.registerLazySingleton<OpenFoodFactsClient>(
      () => OpenFoodFactsClient(getIt<http.Client>()),
    );
  }
  if (!getIt.isRegistered<OffCache>()) {
    // SharedPreferences is pre-resolved elsewhere in DI; if not, this will fail early and be visible.
    getIt.registerLazySingleton<OffCache>(() => OffCache(getIt()));
  }
  if (!getIt.isRegistered<BarcodeRepository>()) {
    getIt.registerLazySingleton<BarcodeRepository>(
      () => BarcodeRepositoryImpl(getIt<OpenFoodFactsClient>(), getIt<OffCache>()),
    );
  }
}
